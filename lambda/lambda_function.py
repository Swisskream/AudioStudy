import boto3
import os
import urllib.parse

s3 = boto3.client('s3')
polly = boto3.client('polly')

def lambda_handler(event, context):
    # Get bucket and file key from S3 event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    #Skip non-text files
    if not file_key.endswith('.txt'):
        print(f"Skipping non-text file: {file_key}")
        return

    try:
        #Get uploaded txt file
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        text = response['Body'].read().decode('utf-8')

        #Synthesize speech with Polly
        polly_response = polly.synthesize_speech(
            Text=text,
            OutputFormat='mp3',
            VoiceId='Matthew'
        )

        #Output file name
        base_filename = os.path.splitext(os.path.basename(file_key))[0]
        output_key = f'output/{base_filename}.mp3'

        #Save audio stream back to S3
        s3.upload_fileobj(
            polly_response['AudioStream'],
            Bucket=bucket_name,
            Key=output_key
        )

        print(f"Audio file saved to: s3://{bucket_name}/{output_key}")
        return {"status": "success", "output_key": output_key}

    except Exception as e:
        print(f"Error processing file {file_key}: {str(e)}")
        raise e