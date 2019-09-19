resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  availability_zone = "${var.availability_zone}"
    tags = {
      Name = "Default subnet for availablity zone ${var.availability_zone}"
    }
}

resource "aws_security_group" "geth" {
  name        = "ethereum-geth-${var.network}"
  description = "Ethereum geth container"

  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    from_port   = 8545
    to_port     = 8545
    protocol    = "tcp"
    description = "web3 http port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8546
    to_port     = 8546
    protocol    = "tcp"
    description = "web3 websocket port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    description = "Ethereum geth node p2p port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "geth" {
  name = "ethereum-geth-${var.network}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "geth" {
  name  = "ethereum-geth-${var.network}"
  role = "${aws_iam_role.geth.name}"
}

resource "aws_key_pair" "geth" {
  key_name   = "ethereum-geth-${var.network}-instance_key"
  public_key = "${var.public_key}"
}

data "aws_ami" "ubuntu" {
  # using the most recent ubuntu AMI is causing terraform to want to
  # destroy/recreate EC2 instances for no other reason than it has found
  # a more recent ubuntu AMI, which seems to happen frequently. Hardcoding
  # For resources that consume this data, they should ignore updates

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "geth" {
  ami           = "${data.aws_ami.ubuntu.id}"
  lifecycle {
    ignore_changes = [ami]
  }

  instance_type = "${var.instance_type}"
  subnet_id = "${aws_default_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.geth.id}"]
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.geth.name}"
  key_name = "${aws_key_pair.geth.key_name}"

  tags = {
    Name = "Ethereum geth ${var.network}"
  }

  # Storage must be SSD, otherwise blocks are mined faster than they can be written to storage
  root_block_device {
    volume_type = "io1"
    iops = "32000"
    volume_size = "${var.volume_size}"
  }

  user_data = <<EOF
#!/bin/bash
ETH_NETWORK=${var.network}
DEVICE_NAME=${var.volume_device_name}
${file("${path.module}/provision-geth.sh")}
EOF
}
