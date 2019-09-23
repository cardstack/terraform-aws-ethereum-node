resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  availability_zone = "${var.availability_zone}"
  tags = {
    Name = "Default subnet for availablity zone"
  }
}

resource "aws_security_group" "geth" {
  name        = "${var.label}-geth-${var.network}"
  description = "geth container ${var.network}"

  vpc_id = "${aws_default_vpc.default.id}"

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
    description = "geth node p2p port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "geth" {
  name = "${var.label}-geth-${var.network}"

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
  name = "${var.label}_geth_${var.network}"
  role = "${aws_iam_role.geth.name}"
}

resource "aws_key_pair" "geth" {
  key_name = "ethereum-geth-${var.network}-instance_key"
  public_key = "${var.public_key}"
}

data "aws_ami" "ubuntu" {
  # using the most recent ubuntu AMI is causing terraform to want to
  # destroy/recreate EC2 instances for no other reason than it has found
  # a more recent ubuntu AMI, which seems to happen frequently. Hardcoding
  # For resources that consume this data, they should ignore updates

  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  network_flag = (var.network != "mainnet") ? "--${var.network}" : ""
}


resource "aws_instance" "geth" {
  ami = "${data.aws_ami.ubuntu.id}"
  lifecycle {
    ignore_changes = [ami]
  }
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_default_subnet.default.id}"

  tags = {
    Name = "${var.label} geth ${var.network}"
  }

  vpc_security_group_ids = ["${aws_security_group.geth.id}"]
  associate_public_ip_address = true

  iam_instance_profile = "${aws_iam_instance_profile.geth.name}"
  key_name = "${aws_key_pair.geth.key_name}"

  user_data = <<EOF
#!/bin/bash
NETWORK_FLAG=${local.network_flag}
${file("${path.module}/provision-geth.sh")}
EOF
}






resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = "${aws_iam_role.geth.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_policy" "policy" {
  name = "${var.label}CloudwatchEC2Monitoring"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "ec2:DescribeTags",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

