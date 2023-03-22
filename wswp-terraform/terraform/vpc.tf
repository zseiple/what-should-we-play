resource "aws_default_vpc" "default" {
  tags = merge(local.tags, { Name = "DefaultVPC" })
}

data "aws_internet_gateway" "default_gw" {
	filter {
		name = "attachment.vpc-id"
		values = [aws_default_vpc.default.id]
	}
}

data "dns_a_record_set" "home_network" {
	host = "zoeyhome.tplinkdns.com"
}

#resource "aws_internet_gateway" "internet_gw" {
#	vpc_id = aws_default_vpc.default.id
#}

resource "aws_default_security_group" "default_security" {
	vpc_id = aws_default_vpc.default.id

	ingress {
		cidr_blocks = [
			format("%s%s", data.dns_a_record_set.home_network.addrs[0], "/32")
		]
		from_port = 22
		to_port = 22
		protocol = "tcp"
	}

	depends_on = [
		data.dns_a_record_set.home_network
	]
}

#resource "aws_default_network_acl" "default_acl" {
#	vpc_id = aws_default_vpc.default.id
#}

#resource "aws_default_route_table" "default_route" {
#	default_route_table_id = aws_default_vpc.default_route_table_id

#	route {
#		cidr_block = "0.0.0.0/0"
#		gateway_id = aws_internet_gateway.internet_gw.id
#	}
#}