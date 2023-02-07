#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 4.16"
#    }
#  }

#  required_version = ">= 1.2.0"
#}

resource "aws_iam_role" "Lambda-GetAppDetails-Role" {
  name = "Lambda-GetAppDetails"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Sid" : "",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "Lambda-GetAppDetails-Policy" {
  name        = "Lambda-DynamoReadLambdaInvoke"
  description = "Lambda Access to Read to DynamoDB, log, and invoke lambda"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:BatchGetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "lambda:InvokeFunction",
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ]
          "Resource" : [
            "arn:aws:dynamodb:${var.aws_region}:${var.aws_account}:table/${var.dynamodb.table_name}",
            "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/${aws_lambda_function.dynamodb-lookup.function_name}:*",
            "arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${aws_lambda_function.fetch-store-info.function_name}",
            "arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${aws_lambda_function.write-to-cache.function_name}"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "Lambda-GetAppDetails-PolicyAttachment" {
  role       = aws_iam_role.Lambda-GetAppDetails-Role.name
  policy_arn = aws_iam_policy.Lambda-GetAppDetails-Policy.arn
}

//Lambda role for fetching store page
resource "aws_iam_role" "Lambda-FetchStoreInfo-Role" {
  name = "Lambda-FetchStoreInfo"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Sid" : "",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "Lambda-FetchStoreInfo-Policy" {
 name = "Lambda-LoggingOnly"
 description = "Policy that only allows logging for lambda functions"

 policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ]
          "Resource" : [
            "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/${aws_lambda_function.fetch-store-info.function_name}:*",
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "Lambda-FetchStoreInfo-PolicyAttachment" {
  role       = aws_iam_role.Lambda-FetchStoreInfo-Role.name
  policy_arn = aws_iam_policy.Lambda-FetchStoreInfo-Policy.arn
}

//WriteToCache
resource "aws_iam_role" "Lambda-WriteToCache-Role" {
  name = "Lambda-WriteToCache"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Sid" : "",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "Lambda-WriteToCache-Policy" {
  name        = "Lambda-DynamoWrite"
  description = "Lambda Access to Write to DynamoDB, log"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:BatchWriteItem",
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ]
          "Resource" : [
            "arn:aws:dynamodb:${var.aws_region}:${var.aws_account}:table/${var.dynamodb.table_name}",
            "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/${aws_lambda_function.write-to-cache.function_name}:*",
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "Lambda-WriteToCache-PolicyAttachment" {
  role       = aws_iam_role.Lambda-WriteToCache-Role.name
  policy_arn = aws_iam_policy.Lambda-WriteToCache-Policy.arn
}