output "bucket_name" {
    value = aws_s3_bucket.notes_bucket.bucket_name
}

output "lambda_function_name" {
    value = aws_lambda_function.text_to_speech.function_name
}