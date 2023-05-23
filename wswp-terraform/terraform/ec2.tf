
resource "aws_instance" "test_instance" {
	ami = data.aws_ami.ubuntu.id
	instance_type = "t3a.nano"

	key_name = "ec2_access"

	depends_on = [
		data.aws_internet_gateway.default_gw
	]
}

#resource "aws_instance" "cluster_instances" {

#}
