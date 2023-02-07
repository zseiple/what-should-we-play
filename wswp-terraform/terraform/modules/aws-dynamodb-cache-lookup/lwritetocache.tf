//fetchStoreInfo Lambda Function
locals {
    writetocache-dirpath = "${path.module}/lambda/write_to_cache/"
    writetocache-payloadfilename = "write_to_cache_payload.zip"
    writetocache-sourcefilename = "index.js"
}


resource "aws_lambda_function" "write-to-cache" {
  //filename      = format("%s%s", local.fetchstoreinfo-dirpath, local.fetchstoreinfo-payloadfilename)
  s3_bucket = var.s3-bucket-name
  s3_key = aws_s3_object.writetocache-payload-upload.key
  function_name = "writeToCache"
  source_code_hash = base64sha256(data.archive_file.writetocache-payload.output_path)

  role    = aws_iam_role.Lambda-WriteToCache-Role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"

  memory_size = 1024
  timeout = 10

  environment {
    variables = {
       aws_region               = var.aws_region
      dynamoEndpoint           = "https://dynamodb.${var.aws_region}.amazonaws.com"
      tableName                = var.dynamodb.table_name
      primaryKeyName           = var.dynamodb.hash_key
      primaryKeyType           = var.dynamodb.attributes[index(var.dynamodb.attributes.*.name, var.dynamodb.hash_key)].type
    }
  }
}

data "archive_file" "writetocache-payload" {
    type = "zip"
    source_file = format("%s%s",local.writetocache-dirpath, local.writetocache-sourcefilename)
    output_path = format("%s%s", local.writetocache-dirpath, local.writetocache-payloadfilename)
}

resource "aws_s3_object" "writetocache-payload-upload" {
    bucket = var.s3-bucket-name
    key = "lambda/writetocache/local.${local.writetocache-payloadfilename}"
    source = data.archive_file.writetocache-payload.output_path

    depends_on = [
        data.archive_file.writetocache-payload,
        aws_s3_bucket.aws-dynamodb-cache-lookup-s3
    ]
}