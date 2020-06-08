resource "aws_iam_role" "AmazonAPIGatewayQueryDynamoDB" {
  name = "AmazonAPIGatewayQueryDynamoDBTF"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy" "AmazonAPIGatewayPushToCloudWatchLogs" {
  name = "AmazonAPIGatewayPushToCloudWatchLogsTF"
  role = aws_iam_role.AmazonAPIGatewayQueryDynamoDB.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
  EOF
}
resource "aws_iam_role_policy" "AllowDynamoDBQuery" {
  name = "AllowDynamoDBQueryTF"
  role = aws_iam_role.AmazonAPIGatewayQueryDynamoDB.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "dynamodb:Query",
            "Resource": "arn:aws:dynamodb:*:*:table/*/index/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "dynamodb:Query",
            "Resource": "arn:aws:dynamodb:*:*:table/*"
        }
    ]
}
  EOF
}