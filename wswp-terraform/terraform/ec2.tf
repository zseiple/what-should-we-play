data "aws_ami" "ubuntu" {
	owners = ["amazon"]
	most_recent = true

	filter {
		name = "image-id"
		values = ["ami-0ddb5a74386eb6091"]
	}
}

resource "aws_instance" "test_instance" {
	ami = data.aws_ami.ubuntu.id
	instance_type = "t3a.nano"

	key_name = "ec2_access"

	depends_on = [
		data.aws_internet_gateway.default_gw
	]
}

resource "aws_key_pair" "ec2_access" {
	key_name = "ec2_access"
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDI5LKIpx+FI6N0U18/vh3OHO7WD434HaLErHGy0EWYgQ8mSYwjvbsozR6nPsmPncJ7qe0sHLS1KlbvSiWCoXEdHV1Dlg+/2Kn1Gww7HdJuH+ZgxMGSPwWzH43Nt03IgzvhCm/Eg6Wy2mw6HjTaXmcLJn404uL761pWP8Zpll0XwCOlWweyxakF2Cb5g4suxscKyleq6I/klkb7/+QHC1+K/9LA2qUvHVVAlpN6mRYcH7zWvFwfSm9H/hpJ6/V92vuxF1TQW1M1Op22RCQEhsDXgfEEFts1cemD2wpDKiotVJ084r5cnRjVSI7QQTE6MmG0AE6D3ZbNlV9tW9CDc2pHat2fp9oRi2u1Ub6srlQMr+27adhAiDY+ROQrSQcJvO+YLvlHqcOHLwXKUVsage6vASkp59vQmdkdZThTKcuq52qjn1SrC6BIRaqyjJJC7txnitCUyZuFxRf6/iA4y2xFhGW2W5adDdQajrjJRb/jFRa4Brgwr6joBDWGYNlUFOE= ubuntu@ec2"
}

#resource "aws_instance" "cluster_instances" {

#}
