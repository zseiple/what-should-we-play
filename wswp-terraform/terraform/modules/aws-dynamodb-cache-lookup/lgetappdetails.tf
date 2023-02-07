
locals {
    getappdetails-dirpath = "${path.module}/lambda/get_app_details/"
    getappdetails-payloadfilename = "get_app_details_payload.zip"
    getappdetails-sourcefilename = "index.js"
}

//GetAppDetails API
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "GetAppDetails"
  description = "API to get Steam App details (multiplayer support) from DynamoDB"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "getAppDetails"

}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamodb-lookup.invoke_arn

}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb-lookup.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

resource "aws_lambda_function" "dynamodb-lookup" {
  //filename      = format("%s%s", local.getappdetails-dirpath, local.getappdetails-payloadfilename)
  s3_bucket = var.s3-bucket-name
  s3_key = aws_s3_object.getappdetails-payload-upload.key
  function_name = "getAppDetails"
  source_code_hash = base64sha256(data.archive_file.getappdetails-payload.output_path)

  role    = aws_iam_role.Lambda-GetAppDetails-Role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"

  memory_size = 2048
  timeout = 10

  environment {
    variables = {
      aws_region               = var.aws_region
      dynamoEndpoint           = "https://dynamodb.${var.aws_region}.amazonaws.com"
      lambdaEndpoint           = "https://lambda.${var.aws_region}.amazonaws.com"
      tableName                = var.dynamodb.table_name
      primaryKeyName           = var.dynamodb.hash_key
      primaryKeyType           = var.dynamodb.attributes[index(var.dynamodb.attributes.*.name, var.dynamodb.hash_key)].type
      fetchStoreInfoFunctionName = aws_lambda_function.fetch-store-info.function_name
      writeToCacheFunctionName = aws_lambda_function.write-to-cache.function_name
    }
  }
}

data "archive_file" "getappdetails-payload" {
    type = "zip"
    source_file = format("%s%s", local.getappdetails-dirpath, local.getappdetails-sourcefilename)
    output_path = format("%s%s", local.getappdetails-dirpath, local.getappdetails-payloadfilename)
}

resource "aws_s3_object" "getappdetails-payload-upload" {
    bucket = var.s3-bucket-name
    key = "lambda/getappdetails/local.${local.getappdetails-payloadfilename}"
    source = data.archive_file.getappdetails-payload.output_path

    depends_on = [
        data.archive_file.fetchstoreinfo-payload,
        aws_s3_bucket.aws-dynamodb-cache-lookup-s3
    ]
 }