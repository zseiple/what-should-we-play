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

resource "aws_security_group" "ec2_security_group" {
	vpc_id = local.vpc_id

	ingress {
		cidr_blocks = ["140.177.227.122/32"]
		from_port = 22
		to_port = 22
		protocol = "tcp"
	}

	ingress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = 443
		to_port = 443
		protocol = "tcp"
	}

	ingress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = 80
		to_port = 80
		protocol = "tcp"
	}
}

#Need to create route tables for subnets
#Range 10.0.0.0 - 10.0.0.255
resource "aws_vpc" "main_vpc" {
	cidr_block = var.vpc_cidr_block

	enable_dns_support = true
	#Needed for vpc endpoints
	enable_dns_hostnames = true
}

#Gateway Endpoints (s3 and dynamodb)
resource "aws_vpc_endpoint" "gateway-endpoints" {
	for_each = var.vpc_endpoints.Gateway

	vpc_endpoint_type = "Gateway"
	vpc_id = local.vpc_id
	service_name = each.value

	route_table_ids = [aws_route_table.private_subnet_route_table.id]
}

#Interface endpoints (API GW, ECR, ECS)
resource "aws_vpc_endpoint" "interface-endpoints" {
	for_each = var.vpc_endpoints.Interface

	vpc_endpoint_type = "Interface"
	vpc_id = local.vpc_id
	service_name = each.value

	subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]
}

resource "aws_internet_gateway" "gw" {
	vpc_id = local.vpc_id
}

#Create a NAT Gateway for each EIP created (one for each public subnet)
#resource "aws_nat_gateway" "nat_gw" {
#	count = length([for ips in aws_eip.nat_gw_ips : ips])

#	allocation_id = [for ip in aws_eip.nat_gw_ips : ip.id][count.index]
#	subnet_id = [for subnet in aws_subnet.public_subnets : subnet.id][count.index]
#	connectivity_type = "public"

#	depends_on = [
#		aws_eip.nat_gw_ips,
#		aws_subnet.public_subnets
#	]

#	tags = {
#		"AvailabilityZone" = [for subnet in aws_subnet.public_subnets : subnet.id][count.index].availability_zone
#	}
#}

#Create an Elastic IP for each public subnet
#resource "aws_eip" "nat_gw_ips" {
#	count = length([for subnet in aws_subnet.public_subnets : subnet.id ])

#	vpc = true

#	depends_on = [
#		local.internet_gw_id,
#		aws_subnet.subnets
#	]
#}

resource "aws_subnet" "public_subnets" {
	for_each = var.subnets.public

	vpc_id = local.vpc_id
	cidr_block = each.value.cidr_block
	availability_zone = format("%s%s", var.aws_region, each.value.availability_zone)

	tags = { 
		"SubnetType" = "public",
	}
}

resource "aws_subnet" "private_subnets" {
	for_each = var.subnets.private

	vpc_id = local.vpc_id
	cidr_block = each.value.cidr_block
	availability_zone = format("%s%s", var.aws_region, each.value.availability_zone)

	tags = { 
		"SubnetType" = "private",
	}
}

#route tables
resource "aws_route_table" "public_subnet_route_table" {
	vpc_id = local.vpc_id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.gw.id
	}
}

resource "aws_route_table_association" "public_subnet_association" {
	count = length([for subnet in aws_subnet.public_subnets : subnet.id])
	subnet_id = [for subnet in aws_subnet.public_subnets : subnet.id][count.index]
	route_table_id = aws_route_table.public_subnet_route_table.id
}

resource "aws_route_table" "private_subnet_route_table" {
	vpc_id = local.vpc_id

	route = []
}

resource "aws_route_table_association" "private_subnet_association" {
	count = length([for subnet in aws_subnet.private_subnets : subnet.id])
	subnet_id = [for subnet in aws_subnet.private_subnets : subnet.id][count.index]
	route_table_id = aws_route_table.private_subnet_route_table.id
}