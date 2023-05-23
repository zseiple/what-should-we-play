
vpc_cidr_block = "10.0.0.0/24"

#subnets
subnets = {
   "public" = {
          "a" = {
            cidr_block = "10.0.0.0/26",
            availability_zone = "a"
          },
          "b" = {
            cidr_block = "10.0.0.64/26",
            availability_zone = "b"
          }
   },
   "private" = {
          "a" = {
            cidr_block = "10.0.0.128/26",
            availability_zone = "a"
          },
          "b" = {
            cidr_block = "10.0.0.192/26",
            availability_zone = "b"
          }
   }
}


#vpc_endpoints
vpc_endpoints = {
    "Gateway" = {
    "s3" = "com.amazonaws.us-east-2.s3",
    "dynamodb" = "com.amazonaws.us-east-2.dynamodb"
    },
    "Interface" = {
        "APIGateway" = "com.amazonaws.us-east-2.execute-api"
        "ECR1" = "com.amazonaws.us-east-2.ecr.api"
        "ECR2" = "com.amazonaws.us-east-2.ecr.dkr"
        "ECS" = "com.amazonaws.us-east-2.ecs"
        "ECSAgent" = "com.amazonaws.us-east-2.ecs-agent"
        "ECSTelemetry" = "com.amazonaws.us-east-2.ecs-telemetry"
    }
}

#User-defined resource tags
resource_tags = {
}

#DynamoDB config
dynamodb-config = {
  attributes = [{
    name = "app_id"
    type = "S"
  }]

}
