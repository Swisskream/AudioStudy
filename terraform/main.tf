provider "aws" {
    region = "us-west-1"
}

resource "aws_s3_bucket" "notes_bucket" {
    bucket = "my-study-notes-speech-to-text"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
    name = "lambda_polly_s3_policy"
    description = "Policy for Lambda to access Polly and S3"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "s3:GetObject",
                    "s3:PutObject"
                ],
                Resource = "${aws_s3_bucket.notes_bucket.arn}/*"
            },
            {
                Effect = "Allow",
                Action = [
                    "polly:SynthesizeSpeech",
                    "polly:DescribeVoices"
                ],
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
    role = aws_iam_role.lambda_exec_role.name
    policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "text_to_speech" {
    filename = "lambda_function.zip"
    function_name = "TextToSpeech"
    role = aws_iam_role.lambda_exec_role.arn
    handler = "lambda_function.lambda_handler"
    runtime = "python3.11"
    source_code_hash = filebase64sha256("lambda_function.zip")

    environment {
        variables = {
            BUCKET_NAME = aws_s3_bucket.notes_bucket.bucket
        }
    }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
    statement_id = "AllowS3Invoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.text_to_speech.arn
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.notes_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = aws_s3_bucket.notes_bucket.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.text_to_speech.arn
        events = ["s3:ObjectCreated:*"]
        filter_suffix = ".txt"
    }

    depends_on = [
        aws_lambda_permission.allow_s3_invoke
    ]
}