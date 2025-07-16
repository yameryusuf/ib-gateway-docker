terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "ib_gateway" {
  name_prefix = "ib-gateway-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 4001
    to_port     = 4002
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ssm_parameter" "ibg_creds" {
  name = var.ssm_parameter_name
  type = "SecureString"
  value = jsonencode({
    username = var.tws_userid
    password = var.tws_password
  })
}

resource "aws_instance" "ib_gateway" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ib_gateway.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    region       = var.region,
    ssm_param    = aws_ssm_parameter.ibg_creds.name,
    trading_mode = var.trading_mode
  })

  tags = {
    Name = "ib-gateway"
  }
}

output "instance_id" {
  value = aws_instance.ib_gateway.id
}

output "public_ip" {
  value = aws_instance.ib_gateway.public_ip
}
