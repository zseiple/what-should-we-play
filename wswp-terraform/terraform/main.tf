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

locals {
  required_tags = {
    project = "wswp"
    env     = "dev"
  }
  tags = merge(local.required_tags, var.resource_tags)

  aws_account = "382376429664"
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


#resource "aws_instance" "app_server" {
#  ami           = "ami-097a2df4ac947655f"
#  instance_type = "t2.micro"

#  tags = merge(local.tags, {Name = var.instance_name})
#}