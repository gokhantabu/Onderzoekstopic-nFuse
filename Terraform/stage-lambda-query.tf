locals {
  lambda_zip_locationQ = "lambda/outputs/lambda_query.zip"
}

resource "aws_lambda_function" "Query" {
  filename      = local.lambda_zip_locationQ
  function_name = "lambda_queryTF"
  role          = aws_iam_role.AmazonLambdaQuery.arn
  handler       = "lambda_query.lambda_handler"
  runtime       = "python3.8"
  timeout = 360
}

data "archive_file" "Query" {
  type        = "zip"
  source_file = "lambda/lambda_query.py"
  output_path = local.lambda_zip_locationQ
}