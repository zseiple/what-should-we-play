output "dynamodb-table_name" {
  description = "The table name of the dynamodb lookup cache table"
  value       = var.dynamodb.table_name
}

output "dynamodb-hash_key" {
  description = "The hash key of the dynamodb lookup cache table"
  value       = var.dynamodb.hash_key
}

output "lambda-get-app-details-functionname" {
  description = "The function name of the lambda function that performs dynamodb lookup"
  value       = aws_lambda_function.dynamodb-lookup.function_name
}

output "lambda-fetch-store-info-functionname" {
  description = "The function name of the lambda function that fetches store info for apps not yet added to the dynamodb cache"
  value       = aws_lambda_function.fetch-store-info.function_name
}

output "lambda-write-to-cache-functionname" {
	description = "The function name of the lambda function that writes to the DB"
	value = aws_lambda_function.write-to-cache.function_name
}