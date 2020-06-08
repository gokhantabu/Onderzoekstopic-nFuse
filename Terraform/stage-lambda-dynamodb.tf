locals {
  lambda_zip_locationDDB = "lambda/outputs/lambda_register_dynamodb.zip"
}


resource "aws_lambda_function" "Register_DynamoDB" {
  filename      = local.lambda_zip_locationDDB
  function_name = "lambda_register_dynamodbTF"
  role          = aws_iam_role.AmazonLambdaRegistrationLogs.arn
  handler       = "lambda_register_dynamodb.lambda_handler"
  runtime       = "python3.8"
  timeout = 360
}

data "archive_file" "Register_DynamoDB" {
  type        = "zip"
  source_file = "lambda/lambda_register_dynamodb.py"
  output_path = local.lambda_zip_locationDDB
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Register_DynamoDB.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucketLogs.arn
}