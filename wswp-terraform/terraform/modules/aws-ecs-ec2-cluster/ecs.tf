resource "aws_ecr_repository" "image-repo" {
	name = "wswp-images"
}

resource "aws_ecs_cluster" "cluster" {
	name="app-cluster"
}

resource "aws_ecs_service" "app-service" {
	name = "wswp"
	cluster = aws_ecs_cluster.cluster.id
	task_definition = aws_ecs_task_definition.wswp-task.arn


	dynamic "load_balancer" {
		for_each = var.load_balancer.target_groups

		content {
			target_group_arn = load_balancer.value.target_group_arn
			container_name = load_balancer.value.container_name
			container_port = load_balancer.value.container_port
		}
	}

	capacity_provider_strategy {
		capacity_provider = aws_ecs_capacity_provider.provider.name
		weight = 100.0
	}
}

resource "aws_ecs_capacity_provider" "provider" {
name = "capacity-provider-ecs"

auto_scaling_group_provider {
	auto_scaling_group_arn = aws_autoscaling_group.app-group.arn
	managed_scaling {
		minimum_scaling_step_size = 1
		maximum_scaling_step_size = 1
	}
}	

}

data "template_file" "container-def-json" {
	template = file("${path.module}/container/task.json")

	vars = {
		bucket_name = aws_s3_bucket.cert-bucket.bucket
	}
}

resource "aws_ecs_task_definition" "wswp-task" {
	family = "app"
	container_definitions = data.template_file.container-def-json.rendered

	volume {
		name = "certs"
		host_path = "/https/"
	}
}