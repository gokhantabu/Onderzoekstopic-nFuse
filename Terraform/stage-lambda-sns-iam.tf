resource "aws_iam_role" "AmazonLambdaPublishSNS" {
  name = "AmazonLambdaPublishSNSTF"

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

resource "aws_iam_role_policy" "AllowS3PutItemSNS" {
  name = "AllowS3PutItemTF"
  role = aws_iam_role.AmazonLambdaPublishSNS.id

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

resource "aws_iam_role_policy" "AllowSNSPublishSNS" {
  name = "AllowSNSPublishTF"
  role = aws_iam_role.AmazonLambdaPublishSNS.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "arn:aws:sns:*:*:*"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy" "AllowInvokeLambdaSNS" {
  name = "AllowInvokeLambdaTF"
  role = aws_iam_role.AmazonLambdaPublishSNS.id

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