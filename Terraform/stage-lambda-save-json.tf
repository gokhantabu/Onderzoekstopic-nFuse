locals {
  lambda_zip_locationSJ = "lambda/outputs/lambda_save_json.zip"
}

resource "aws_lambda_function" "Save_JSON" {
  filename      = local.lambda_zip_locationSJ
  function_name = "lambda_save_jsonTF"
  role          = aws_iam_role.AmazonLambdaSaveJSON.arn
  handler       = "lambda_save_json.lambda_handler"
  runtime       = "python3.8"
  timeout = 360
}

data "archive_file" "Save_JSON" {
  type        = "zip"
  source_file = "lambda/lambda_save_json.py"
  output_path = local.lambda_zip_locationSJ
}