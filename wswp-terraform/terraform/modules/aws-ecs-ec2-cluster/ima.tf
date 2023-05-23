data "aws_caller_identity" "current" { }
locals {
	account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "ECSTaskExecutionRole" {
	name = "ECSTaskExecutionRole"
	assume_role_policy = jsonencode(
		{
			"Version": "2012-10-17",
			"Statement": [
				{
					"Action": "sts:AssumeRole",
					"Effect": "Allow",
					"Sid": "",
					"Principal": {
						"Service": ["ecs-tasks.amazonaws.com"]
					}
					"Condition": {
						"StringEquals": {
							"aws:SourceAccount": local.account_id
						}
					}
				}
			]
		}
	)

}

#Policy for the ECS Execution Role: ECS agent that manages the containers
resource "aws_iam_policy" "ECSTaskExecutionPolicy" {
	name = "ECSTaskExecutionPolicy"
	
	policy = jsonencode({
		"Version": "2012-10-17"
		"Statement": [
			{
				"Action": [
					"ecr:BatchGetImage",
					"ecr:GetAuthorizationToken",
					"ecr:GetDownloadUrlForLayer",
					"ecr:BatchCheckLayerAvailability",
					"logs:CreateLogStream",
					"logs:PutLogEvents"
				],
				"Resource": "*",
				"Effect": "Allow"
			},
			{
				"Action": [
					"s3:GetObject",
					"s3:ListBucket"
				],
				"Resource": "arn:aws:s3:::${aws_s3_bucket.cert-bucket.bucket}",
				"Effect": "Allow"
			}
		]
	})
}