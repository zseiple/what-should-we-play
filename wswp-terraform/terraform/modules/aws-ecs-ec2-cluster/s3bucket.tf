resource "aws_s3_bucket" "cert-bucket" {
	bucket = format("cert-bucket-%s", formatdate("DDMMYYYY", timestamp()))
}

#resource "aws_kms_key" "cert-encrypt-key" {
#	description = "Key used to encrypt SSL certs stored in S3"
#	key_usage = "ENCRYPT_DECRYPT"
#	deletion_window_in_days = 30
#}

#resource "aws_s3_bucket_server_side_encryption_configuration" "cert-encrypt" {
#	bucket = aws_s3_bucket.ecs-s3.id
#}