resource "aws_api_gateway_rest_api" "MyAPI" {
  name = "LogsApiTF"
  description = "Retrieve records from DynamoDB"

  endpoint_configuration {
    types = [
      "REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "MyResourceLogs" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  parent_id = aws_api_gateway_rest_api.MyAPI.root_resource_id
  path_part = "logs"
}

resource "aws_api_gateway_resource" "MyResourcesFilename" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  parent_id = aws_api_gateway_resource.MyResourceLogs.id
  path_part = "{filename}"
}

resource "aws_api_gateway_resource" "MyResourceLogsD" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  parent_id = aws_api_gateway_rest_api.MyAPI.root_resource_id
  path_part = "logsd"
}

resource "aws_api_gateway_resource" "MyResourcesDate" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  parent_id = aws_api_gateway_resource.MyResourceLogsD.id
  path_part = "{date}"
}

resource "aws_api_gateway_method" "MyGetMethod" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesFilename.id
  http_method = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "MyGetMethodD" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesDate.id
  http_method = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "MyIntegration" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesFilename.id
  http_method = aws_api_gateway_method.MyGetMethod.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:eu-west-1:dynamodb:action/Query"
  credentials = aws_iam_role.AmazonAPIGatewayQueryDynamoDB.arn
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
{
    "TableName": "RegistrationLogsTF",
    "IndexName": "fileName-index",
    "KeyConditionExpression": "fileName = :v1",
    "ExpressionAttributeValues": {
        ":v1": {
            "S": "$input.params('filename')"
        }
    }
}
EOF
  }
}

resource "aws_api_gateway_integration" "MyIntegrationD" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesDate.id
  http_method = aws_api_gateway_method.MyGetMethodD.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:eu-west-1:dynamodb:action/Query"
  credentials = aws_iam_role.AmazonAPIGatewayQueryDynamoDB.arn
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
{
    "TableName": "RegistrationLogsTF",
    "IndexName": "registrationDate-index",
    "KeyConditionExpression": "registrationDate = :v1",
    "ExpressionAttributeValues": {
        ":v1": {
            "S": "$input.params('date')"
        }
    }
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesFilename.id
  http_method = aws_api_gateway_method.MyGetMethod.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "response_200D" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesDate.id
  http_method = aws_api_gateway_method.MyGetMethodD.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}
resource "aws_api_gateway_integration_response" "MyIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesFilename.id
  http_method = aws_api_gateway_method.MyGetMethod.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
    "found logs by filename": [
        #foreach($elem in $inputRoot.Items) {
            "Registration date": "$elem.registrationDate.S",
            "Registration time": "$elem.registrationTime.S",
            "Filename": "$elem.fileName.S"
        }#if($foreach.hasNext),#end
#end
    ]
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "MyIntegrationResponseD" {
  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  resource_id = aws_api_gateway_resource.MyResourcesDate.id
  http_method = aws_api_gateway_method.MyGetMethodD.http_method
  status_code = aws_api_gateway_method_response.response_200D.status_code

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
    "found logs by date": [
        #foreach($elem in $inputRoot.Items) {
            "Registration date": "$elem.registrationDate.S",
            "Registration time": "$elem.registrationTime.S",
            "Filename": "$elem.fileName.S"
        }#if($foreach.hasNext),#end
#end
    ]
}
EOF
  }
}

resource "aws_api_gateway_deployment" "MyDeployment" {
  depends_on = [aws_api_gateway_integration.MyIntegration, aws_api_gateway_integration.MyIntegrationD]

  rest_api_id = aws_api_gateway_rest_api.MyAPI.id
  stage_name  = "Production"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_api_key" "MyApiKey" {
  name = "MY_API_KEY_TF"
  description = "API key to allow retrieve records from DynamoDB"
}

resource "aws_api_gateway_usage_plan" "MyUsagePlan" {
  name         = "Plan_DynamoDBTF"

  api_stages {
    api_id = aws_api_gateway_rest_api.MyAPI.id
    stage  = aws_api_gateway_deployment.MyDeployment.stage_name
  }

  quota_settings {
    limit  = 5000
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 200
    rate_limit  = 100
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.MyApiKey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.MyUsagePlan.id
}