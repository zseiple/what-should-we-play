terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    dns = {
        source = "hashicorp/dns"
        version = "~> 3.2.4"
    }
  }

    

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
locals {
  required_tags = {
    project = "wswp"
    env     = "dev"
  }
  tags = merge(local.required_tags, var.resource_tags)

  aws_account = data.aws_caller_identity.current.account_id

  vpc_id = aws_vpc.main_vpc.id
  internet_gw_id = aws_internet_gateway.gw.id
}

module "dynamodb-lookup-cache" {
  source = "./modules/aws-dynamodb-cache-lookup"

  dynamodb = {
    attributes            = var.dynamodb-config.attributes
    local_secondary_index = var.dynamodb-config.local-indexes
    hash_key              = "app_id"
    table_name            = format("dynamodb-lookup-cache-%s", formatdate("DDMMYYYY", timestamp()))
  }

  aws_account = local.aws_account
}

module "ecs-cluster" {
    source = "./modules/aws-ecs-ec2-cluster"

    vpc_id = local.vpc_id

    load_balancer = {
    name = aws_lb.app-lb.name,
    target_groups = {
        "http" = {
            target_group_arn = aws_lb_target_group.wswp_http_group.arn,
            container_name = "wswp-server",
            container_port = 9796
        },
        "https" = {
            target_group_arn = aws_lb_target_group.wswp_https_group.arn,
            container_name = "wswp-server",
            container_port = 9797
        }
      }
    }

    security_group_ids = [aws_security_group.ec2_security_group.id]

    launch_subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]

    instance = {
        image_id = data.aws_ami.ubuntu.image_id
        type = "t3a.nano"
        key_pair = {
            name = aws_key_pair.ec2_access.key_name
            public_key = aws_key_pair.ec2_access.public_key
        }
    }

    depends_on = [
    aws_security_group.ec2_security_group
    ]
}

data "aws_ami" "ubuntu" {
	owners = ["amazon"]
	most_recent = true

	filter {
		name = "image-id"
		values = ["ami-0ddb5a74386eb6091"]
	}
}

resource "aws_key_pair" "ec2_access" {
	key_name = "ec2_access"
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDI5LKIpx+FI6N0U18/vh3OHO7WD434HaLErHGy0EWYgQ8mSYwjvbsozR6nPsmPncJ7qe0sHLS1KlbvSiWCoXEdHV1Dlg+/2Kn1Gww7HdJuH+ZgxMGSPwWzH43Nt03IgzvhCm/Eg6Wy2mw6HjTaXmcLJn404uL761pWP8Zpll0XwCOlWweyxakF2Cb5g4suxscKyleq6I/klkb7/+QHC1+K/9LA2qUvHVVAlpN6mRYcH7zWvFwfSm9H/hpJ6/V92vuxF1TQW1M1Op22RCQEhsDXgfEEFts1cemD2wpDKiotVJ084r5cnRjVSI7QQTE6MmG0AE6D3ZbNlV9tW9CDc2pHat2fp9oRi2u1Ub6srlQMr+27adhAiDY+ROQrSQcJvO+YLvlHqcOHLwXKUVsage6vASkp59vQmdkdZThTKcuq52qjn1SrC6BIRaqyjJJC7txnitCUyZuFxRf6/iA4y2xFhGW2W5adDdQajrjJRb/jFRa4Brgwr6joBDWGYNlUFOE= ubuntu@ec2"
}
#resource "aws_instance" "app_server" {
#  ami           = "ami-097a2df4ac947655f"
#  instance_type = "t2.micro"

#  tags = merge(local.tags, {Name = var.instance_name})
#}