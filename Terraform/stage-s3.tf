resource "aws_s3_bucket" "bucketLogs" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucketLogs.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.Register_DynamoDB.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "Logs/"
    filter_suffix       = ".log"
  }
}