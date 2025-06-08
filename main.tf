provider "aws" {
    region = "us-west-1"
}

resource "aws_s3_bucket" "notes_bucket" {
    bucket = "my-study-notes-speech-to-text"

}