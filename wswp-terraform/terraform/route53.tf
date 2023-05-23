resource "aws_route53_zone" "primary" {
	name = "whatshouldweplay.net"

	force_destroy = false
}

resource "aws_route53_record" "lb" {
	name = "whatshouldweplay.net"
	type = "A"
	zone_id = aws_route53_zone.primary.id

	allow_overwrite = true

	alias {
		name = aws_lb.app-lb.dns_name
		zone_id = aws_lb.app-lb.zone_id
		evaluate_target_health = false
	}

	depends_on = [
		aws_lb.app-lb
	]
}

resource "aws_route53_record" "www" {
	name = "www.whatshouldweplay.net"
	type = "A"
	zone_id = aws_route53_zone.primary.id

	allow_overwrite = true

	alias {
		name = aws_lb.app-lb.dns_name
		zone_id = aws_lb.app-lb.zone_id
		evaluate_target_health = false
	}

	depends_on = [
		aws_lb.app-lb
	]
}

resource "aws_route53_record" "validation_record" {
	count = length(aws_acm_certificate.wswp_cert.subject_alternative_names) + 1
	
	allow_overwrite = true

	name = element(aws_acm_certificate.wswp_cert.domain_validation_options[*].resource_record_name, count.index)
	type = element(aws_acm_certificate.wswp_cert.domain_validation_options[*].resource_record_type, count.index)
	zone_id = aws_route53_zone.primary.id
	ttl = 300

	records = [element(aws_acm_certificate.wswp_cert.domain_validation_options[*].resource_record_value, count.index)]

depends_on = [
	aws_acm_certificate.wswp_cert
]
}

resource "aws_acm_certificate" "wswp_cert" {
	domain_name = "whatshouldweplay.net"
	subject_alternative_names = ["*.whatshouldweplay.net"]
	validation_method = "DNS"

}

resource "aws_acm_certificate_validation" "cert_validation" {
	certificate_arn = aws_acm_certificate.wswp_cert.arn
	validation_record_fqdns = aws_route53_record.validation_record[*].fqdn
}