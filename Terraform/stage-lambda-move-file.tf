locals {
  lambda_zip_locationMF = "lambda/outputs/lambda_move_logs.zip"
}

resource "aws_lambda_function" "Move_Logs" {
  filename      = local.lambda_zip_locationMF
  function_name = "lambda_move_logsTF"
  role          = aws_iam_role.AmazonLambdaMoveLogs.arn
  handler       = "lambda_move_logs.lambda_handler"
  runtime       = "python3.8"
  timeout = 360
}

data "archive_file" "Move_Logs" {
  type        = "zip"
  source_file = "lambda/lambda_move_logs.py"
  output_path = local.lambda_zip_locationMF
}