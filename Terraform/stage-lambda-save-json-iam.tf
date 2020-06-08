resource "aws_iam_role" "AmazonLambdaSaveJSON" {
  name = "AmazonLambdaSaveJSONTF"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy" "AllowS3PutItemSJ" {
  name = "AllowS3PutItemTF"
  role = aws_iam_role.AmazonLambdaSaveJSON.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy" "AllowS3MoveLogsSJ" {
  name = "AllowS3MoveLogsTF"
  role = aws_iam_role.AmazonLambdaSaveJSON.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::*/*"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy" "AllowInvokeLambdaSJ" {
  name = "AllowInvokeLambdaTF"
  role = aws_iam_role.AmazonLambdaSaveJSON.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "*"
        }
    ]
}
  EOF
}