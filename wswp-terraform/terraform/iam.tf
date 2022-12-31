#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 4.16"
#    }
#  }

#  required_version = ">= 1.2.0"
#}

resource "aws_iam_role" "Lambda-DynamoLookupCache-Role" {
  name = "Lambda-DynamoLookupCache"
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

resource "aws_iam_policy" "Lambda-DynamoReadWrite" {
  name        = "Lambda-DynamoReadWrite"
  description = "Lambda Access to Read/Write to DynamoDB"

  depends_on = [
    module.dynamodb-lookup-cache
  ]

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:PutItem",
            "dynamodb:GetItem",
            "dynamodb:BatchPutItem",
            "dynamodb:BatchGetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "lambda:InvokeFunction",
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ]
          "Resource" : [
            "arn:aws:dynamodb:${var.aws_region}:${local.aws_account}:table/${module.dynamodb-lookup-cache.dynamodb-table_name}",
            "arn:aws:logs:${var.aws_region}:${local.aws_account}:log-group:/aws/lambda/${module.dynamodb-lookup-cache.lambda-dynamodb-lookup-functionname}:*",
            "arn:aws:lambda:${var.aws_region}:${local.aws_account}:function:${module.dynamodb-lookup-cache.lambda-fetch-store-info-functionname}"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "Lambda-DynamoLookupCache-PolicyAttachment" {
  role       = aws_iam_role.Lambda-DynamoLookupCache-Role.name
  policy_arn = aws_iam_policy.Lambda-DynamoReadWrite.arn
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

resource "aws_iam_policy" "Lambda-LoggingOnly" {
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
            "arn:aws:logs:${var.aws_region}:${local.aws_account}:log-group:/aws/lambda/${module.dynamodb-lookup-cache.lambda-fetch-store-info-functionname}:*",
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "Lambda-FetchStoreInfo-PolicyAttachment" {
  role       = aws_iam_role.Lambda-FetchStoreInfo-Role.name
  policy_arn = aws_iam_policy.Lambda-LoggingOnly.arn
}