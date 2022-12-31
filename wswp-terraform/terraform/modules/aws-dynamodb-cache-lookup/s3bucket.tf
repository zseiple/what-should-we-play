locals {
	lambda_payload_dir = "lambda/payloads/"
	lambda_config_dir = "lambda/config/"
}

resource "aws_s3_bucket" "aws-dynamodb-cache-lookup-s3" {
	bucket = var.s3-bucket-name
}

resource "aws_s3_object" "fetchstoreinfo_config_object" {
	bucket = var.s3-bucket-name
	key = local.fetchstoreinfo_config_key
	source = "${path.module}/lambda/fetch_store_info/config.json"

	content_type = "text/plain"

	depends_on = [
		aws_s3_bucket.aws-dynamodb-cache-lookup-s3
	]
}

