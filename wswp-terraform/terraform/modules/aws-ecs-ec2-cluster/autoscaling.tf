resource "aws_launch_template" "app-host" {
	name = "wswp-instance"
	description = "Describes configuration for one host of WSWP"

	image_id = var.instance.image_id
	instance_type = var.instance.type
	key_name = var.instance.key_pair.name

	vpc_security_group_ids = var.security_group_ids
}

resource "aws_autoscaling_group" "app-group" {	
	name = "wswp-asgroup"

	target_group_arns = [for group in var.load_balancer.target_groups : group.target_group_arn]
	vpc_zone_identifier = var.launch_subnet_ids

	launch_template { 
		id = aws_launch_template.app-host.id
	}

	desired_capacity = 1
	max_size = 2
	min_size = 1

	health_check_type = "EC2"
	health_check_grace_period = 300
}

resource "aws_autoscaling_policy" "autoscaling-rules" {
	name = "wswp-aspolicy"
	autoscaling_group_name = aws_autoscaling_group.app-group.name

	policy_type = "SimpleScaling"
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = 1
}