//fetchStoreInfo Lambda Function
locals {
    fetchstoreinfo-dirpath = "${path.module}/lambda/fetch_store_info/"
    fetchstoreinfo-payloadfilename = "fetch_store_info_payload.zip"
    fetchstoreinfo-sourcefilename = "index.js"
    fetchstoreinfo_config_key = "config/lambda/fetch_store_info/config.json"

    config_file = jsondecode(data.aws_s3_object.fetchstoreinfo_config_file.body)
}


resource "aws_lambda_function" "fetch-store-info" {
  //filename      = format("%s%s", local.fetchstoreinfo-dirpath, local.fetchstoreinfo-payloadfilename)
  s3_bucket = var.s3-bucket-name
  s3_key = aws_s3_object.fetchstoreinfo-payload-upload.key
  function_name = "fetchStoreInfo"
  source_code_hash = base64sha256(data.archive_file.fetchstoreinfo-payload.output_path)

  role    = aws_iam_role.Lambda-FetchStoreInfo-Role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"

  memory_size = 2048
  timeout = 10

  layers = [aws_lambda_layer_version.jsdom_layer.arn]

  environment {
    variables = {
      //The base URL to look for missing values at
      searchURL = local.config_file.search_url_base
      //The string values to search for on the page
      searchStrings = join("," ,local.config_file.search_strings)
    }
  }
}

resource "aws_lambda_layer_version" "jsdom_layer" {
  filename   = "${path.module}/lambda/packages/jsdom.zip"
  layer_name = "jsdom-layer"

  compatible_runtimes = ["nodejs16.x"]

}

//Config file for this lambda
data "aws_s3_object" "fetchstoreinfo_config_file" {
	bucket = var.s3-bucket-name
	key = local.fetchstoreinfo_config_key

	depends_on = [
		aws_s3_object.fetchstoreinfo_config_object
	]
}

data "archive_file" "fetchstoreinfo-payload" {
    type = "zip"
    source_file = format("%s%s",local.fetchstoreinfo-dirpath, local.fetchstoreinfo-sourcefilename)
    output_path = format("%s%s", local.fetchstoreinfo-dirpath, local.fetchstoreinfo-payloadfilename)
}

resource "aws_s3_object" "fetchstoreinfo-payload-upload" {
    bucket = var.s3-bucket-name
    key = "lambda/fetchstoreinfo/local.${local.fetchstoreinfo-payloadfilename}"
    source = data.archive_file.fetchstoreinfo-payload.output_path

    depends_on = [
        data.archive_file.fetchstoreinfo-payload,
        aws_s3_bucket.aws-dynamodb-cache-lookup-s3
    ]
}