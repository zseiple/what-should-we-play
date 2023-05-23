resource "aws_lb" "app-lb" {
	name = "wswp-lb"

	subnets = [for subnet in aws_subnet.public_subnets : subnet.id]
	load_balancer_type = "application"
	internal = false
	ip_address_type = "ipv4"

}

#resource "aws_eip" "lb_ips" {
#	count = length(aws_subnet.public_subnets)

#	vpc = true
#}

resource "aws_lb_listener" "http_listener" {
	load_balancer_arn = aws_lb.app-lb.arn
	port = 80
	protocol = "HTTP"

	default_action {
		target_group_arn = aws_lb_target_group.wswp_http_group.id
		type = "forward"
	}

	depends_on = [
		aws_lb_target_group.wswp_http_group
	]
}

resource "aws_lb_listener" "https_listener" {
	load_balancer_arn = aws_lb.app-lb.arn
	port = 443
	protocol = "HTTPS"
	#ssl_policy: need to add here
	certificate_arn = aws_acm_certificate.wswp_cert.arn

	default_action {
		target_group_arn = aws_lb_target_group.wswp_https_group.id
		type = "forward"
	}

	depends_on = [
		aws_lb_target_group.wswp_https_group,
		aws_acm_certificate_validation.cert_validation
	]
}

#//////////////////////////Need network LB for this\\\\\\\\\\\\\\\\\\\\\\\\\\
#resource "aws_lb_listener" "ssh_listener" {
#	load_balancer_arn = aws_lb.app-lb.arn
#	port = 22
#	protocol = "TCP"

#	default_action {
#		target_group_arn = aws_lb_target_group.wswp_https_group.id
#		type = "forward"
#	}

#	depends_on = [
#		aws_lb_target_group.wswp_https_group
#	]
#}

resource "aws_lb_target_group" "wswp_http_group" {
	name = "wswp-http-group"
	port = 9796
	protocol = "HTTP"

	vpc_id = local.vpc_id
}

resource "aws_lb_target_group" "wswp_https_group" {
	name = "wswp-https-group"
	port = 9797
	protocol = "HTTPS"

	vpc_id = local.vpc_id
}

#///////////////////////Need Network lb for this\\\\\\\\\\\\\\\\\\\\\\\\\\
#resource "aws_lb_target_group" "wswp_ssh_group" {
#	name = "wswp-ssh-group"
#	port = 22
#	protocol = "TCP"

#	vpc_id = local.vpc_id
#}