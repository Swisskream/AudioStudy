# 📚 AudioStudy – Text-to-Speech Cloud App

This project converts your written study notes into spoken audio using AWS services. Upload a `.txt` file to an S3 bucket, and AWS Lambda + Polly will generate a spoken version automatically.

## 🚀 Tech Stack

- **AWS S3** – stores uploaded notes
- **AWS Lambda** – triggers on file upload
- **AWS Polly** – converts text to speech
- **Terraform** – infrastructure as code