locals {
  billing_mode = coalesce(var.dynamodb.billing_mode, "PROVISIONED")
}

resource "aws_dynamodb_table" "dynamodb-instance" {

  lifecycle {
    ignore_changes = [
      name
    ]
  }

  dynamic "attribute" {
    for_each = var.dynamodb.attributes
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  hash_key = var.dynamodb.attributes[index(var.dynamodb.attributes.*.name, var.dynamodb.hash_key)].name
  name     = var.dynamodb.table_name

  #optional params
  billing_mode   = local.billing_mode
  read_capacity  = var.dynamodb.read_capacity != null ? var.dynamodb.read_capacity : (local.billing_mode == "PROVISIONED" ? 1 : null)
  write_capacity = var.dynamodb.write_capacity != null ? var.dynamodb.write_capacity : (local.billing_mode == "PROVISIONED" ? 1 : null)

  dynamic "global_secondary_index" {
    for_each = var.dynamodb.global_secondary_index != null ? var.dynamodb.global_secondary_index : []
    content {
      hash_key           = global_secondary_index.value["hash_key"]
      name               = global_secondary_index.value["name"]
      non_key_attributes = global_secondary_index.value["non_key_attributes"]
      projection_type    = global_secondary_index.value["projection_type"]
      range_key          = global_secondary_index.value["range_key"]
      read_capacity      = global_secondary_index.value["read_capacity"]
      write_capacity     = global_secondary_index.value["write_capacity"]
    }
  }
  # global_secondary_index = var.dynamodb.global_secondary_index
  #local_secondary_index = var.dynamodb.local_secondary_index
  dynamic "local_secondary_index" {
    for_each = var.dynamodb.local_secondary_index != null ? var.dynamodb.local_secondary_index : []
    content {
      name               = local_secondary_index.value["name"]
      non_key_attributes = local_secondary_index.value["non_key_attributes"]
      projection_type    = local_secondary_index.value["projection_type"]
      range_key          = local_secondary_index.value["range_key"]
    }
  }

  dynamic "point_in_time_recovery" {
    for_each = var.dynamodb.point_in_time_recovery != null ? [0] : []
    content {
      enabled = point_in_time_recovery.enabled
    }
  }

  range_key = var.dynamodb.range_key

  dynamic "replica" {
    for_each = var.dynamodb.replica != null ? range(length(var.dynamodb.replica)) : []
    content {
      kms_key_arn            = replica.value["kms_key_arn"]
      point_in_time_recovery = replica.value["point_in_time_recovery"]
      propagate_tags         = replica.value["propagate_tags"]
      region_name            = replica.value["region_name"]
    }
  }
  restore_date_time      = var.dynamodb.restore_date_time
  restore_source_name    = var.dynamodb.restore_source_name
  restore_to_latest_time = var.dynamodb.restore_to_latest_time
  dynamic "server_side_encryption" {
    for_each = var.dynamodb.server_side_encryption != null ? [0] : []
    content {
      enabled     = server_side_encryption.value["enabled"]
      kms_key_arn = server_side_encryption.value["kms_key_arn"]
    }
  }
  stream_enabled   = var.dynamodb.stream_enabled
  stream_view_type = var.dynamodb.stream_view_type
  table_class      = var.dynamodb.table_class
  tags             = var.dynamodb.tags
  dynamic "ttl" {
    for_each = var.dynamodb.ttl != null ? [0] : []
    content {
      enabled        = ttl.value["enabled"]
      attribute_name = ttl.value["attribute_name"]
    }
  }

}

