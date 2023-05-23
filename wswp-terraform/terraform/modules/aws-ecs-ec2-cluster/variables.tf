variable "aws_region" {
	description = "The AWS region in which instances will be launched"
	type = string
	default = "us-east-2"
}

variable "vpc_id" {
	description = "The VPC ID to be used by ECS"
	type = string
}

variable "load_balancer" {
	description = "Name of the LB used for this cluster"
	type = object({
		name = string
		target_groups = map(object({
			target_group_arn = string
			container_name = string
			container_port = number
		}))
	})
}

variable "security_group_ids" {
	description = "List of security group ids to be associated with the ec2 instances on launch"
	type = list(string)
}

variable "launch_subnet_ids" {
	description = "List of subnet ids in which cluster instances will be launched"
	type = list(string)
}

variable "instance" {
	description = "Instance details for the autoscaling group"
	type = object({
		image_id = string
		type = string
		key_pair = object({
			name = string
			public_key = string
		})
	})
}