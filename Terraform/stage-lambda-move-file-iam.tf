resource "aws_iam_role" "AmazonLambdaMoveLogs" {
  name = "AmazonLambdaMoveLogsTF"

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

resource "aws_iam_role_policy" "AWSLambdaBasicExecutionRoleML" {
  name = "AWSLambdaBasicExecutionRoleTF"
  role = aws_iam_role.AmazonLambdaMoveLogs.id

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

resource "aws_iam_role_policy" "AllowS3MoveLogsML" {
  name = "AllowS3MoveLogsTF"
  role = aws_iam_role.AmazonLambdaMoveLogs.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObjectTagging",
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectTagging",
                "s3:PutObjectTagging",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::*/*"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy" "AllowInvokeLambdaML" {
  name = "AllowInvokeLambdaTF"
  role = aws_iam_role.AmazonLambdaMoveLogs.id

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