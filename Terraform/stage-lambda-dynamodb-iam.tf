resource "aws_iam_role" "AmazonLambdaRegistrationLogs" {
  name = "AmazonLambdaRegistrationLogsTF"

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

resource "aws_iam_role_policy" "AWSLambdaBasicExecutionRoleDB" {
  name = "AWSLambdaBasicExecutionRoleTF"
  role = aws_iam_role.AmazonLambdaRegistrationLogs.id

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

resource "aws_iam_role_policy" "AllowPutItemDynamoDB" {
  name = "AllowPutItemDynamoDBTF"
  role = aws_iam_role.AmazonLambdaRegistrationLogs.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "dynamodb:PutItem",
            "Resource": "arn:aws:dynamodb:*:*:table/*"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy" "AllowInvokeLambdaDB" {
  name = "AllowInvokeLambdaTF"
  role = aws_iam_role.AmazonLambdaRegistrationLogs.id

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