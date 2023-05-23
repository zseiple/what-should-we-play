terraform {
  experiments = [module_variable_optional_attrs]
}

variable "vpc_cidr_block" {
    type = string
}

variable "subnets" {
    type = object({
        public = map(object({
        cidr_block = string,
        availability_zone = string
        })),
        private = map(object({
        cidr_block = string,
        availability_zone = string
        }))
    })
}

variable "vpc_endpoints" {
    description = "A map of AWS endpoints to be used for VPC endpoint"
    type = object({
        Gateway = map(string),
        Interface = map(string)
    })
}

variable "aws_region" {
  description = "AWS Region where configuration will be applied"
  type        = string
  default     = "us-east-2"
}

variable "resource_tags" {
  description = "General resource tags to be applied to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = (length(lookup(var.resource_tags, "project", "")) <= 4) && (length(regexall("[^[:alpha:]-]", lookup(var.resource_tags, "project", ""))) == 0)
    error_message = "Project Name must be 4 or less characters and contain only letters or hyphens"
  }

  validation {
    condition     = length(regexall("(prod)|(dev)|(^$)", lookup(var.resource_tags, "env", ""))) > 0
    error_message = "Project environment must be 'prod' or 'dev'"
  }
}

variable "dynamodb-config" {
  description = "Configuration options for the dynamodb instance"
  type = object({
    attributes = list(object({
      name = string
      type = string
    }))
    local-indexes = optional(list(object({
      name               = string
      non_key_attributes = optional(list(string))
      projection_type    = string
      range_key          = string
    })))
  })
}
