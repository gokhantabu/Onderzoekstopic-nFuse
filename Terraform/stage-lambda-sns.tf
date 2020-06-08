locals {
  lambda_zip_locationSNS = "lambda/outputs/lambda_sns_publish.zip"
}

resource "aws_lambda_function" "SNS_Publish" {
  filename      = local.lambda_zip_locationSNS
  function_name = "lambda_sns_publishTF"
  role          = aws_iam_role.AmazonLambdaPublishSNS.arn
  handler       = "lambda_sns_publish.lambda_handler"
  runtime       = "python3.8"
  timeout = 360
}

data "archive_file" "SNS_Publish" {
  type        = "zip"
  source_file = "lambda/lambda_sns_publish.py"
  output_path = local.lambda_zip_locationSNS
}