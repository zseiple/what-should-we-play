terraform {
  experiments = [module_variable_optional_attrs]
}

variable "aws_region" {
  description = "The AWS region to deploy the lambda and dynamoDB instance"
  type        = string
  default     = "us-east-2"
}

variable "s3-bucket-name" {
    description = "The name of the s3 bucket to be used by this module"
    type = string
    default = "aws-dynamodb-cache-lookup-bucket"
}

variable "dynamodb" {
  description = "Information needed to create a DynamoDB instance"
  type = object({
    #Required
    attributes = list(object({
      name = string
      type = string
    }))
    hash_key   = string
    table_name = string

    #Optional
    billing_mode = optional(string)
    global_secondary_index = optional(list(object({
      hash_key           = string
      name               = string
      non_key_attributes = optional(list(string))
      projection_type    = string
      range_key          = optional(string)
      read_capacity      = optional(number)
      write_capacity     = optional(number)
    })))
    local_secondary_index = optional(list(object({
      name               = string
      non_key_attributes = optional(list(string))
      projection_type    = string
      range_key          = string
    })))
    point_in_time_recovery = optional(object({
      enabled = bool
    }))
    range_key     = optional(string)
    read_capacity = optional(number)
    replica = optional(object({
      kms_key_arn = optional(string)
      point_in_time_recovery = optional(object({
        enabled = bool
      }))
      propagate_tags = optional(bool)
      region_name    = string
    }))
    restore_date_time      = optional(string)
    restore_source_name    = optional(string)
    restore_to_latest_time = optional(bool)
    server_side_encryption = optional(object({
      enabled     = bool
      kms_key_arn = optional(string)
    }))
    stream_enabled   = optional(bool)
    stream_view_type = optional(string)
    table_class      = optional(string)
    tags             = optional(map(string))
    ttl = optional(object({
      enabled        = bool
      attribute_name = string
    }))
    write_capacity = optional(number)
  })

  #VALIDATIONS
  #attributes
  validation {
    condition     = length(var.dynamodb.attributes) > 0
    error_message = "At least one attribute is needed to create a DynamoDB instance"
  }

  #hash_key
  validation {
    condition     = contains(var.dynamodb.attributes[*].name, var.dynamodb.hash_key)
    error_message = "Hash Key must be the name of an existing attribute"
  }
}

variable "getappdetails-role-arn" {
  description = "ARN of the role for lambda to use for dynamodb access"
  type        = string
}

variable "fetchstoreinfo-role-arn" {
    description = "ARN of the role for fetchStoreInfo Lambda"
    type = string
}