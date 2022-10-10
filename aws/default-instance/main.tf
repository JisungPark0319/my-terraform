provider "aws" {
  region  = "ap-northeast-2"
  profile = "jisung"
}

locals {
  instance_name = format("%s-%s", var.workspace, var.instance_name)
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-northeast-2a"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = local.instance_name

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = element([for s in data.aws_subnet.default : s.id], 0)

  tags = merge(
    { Name : local.instance_name },
    var.tags,
    var.instance_tags
  )
}

locals {
  security_group = format("%s-%s", var.workspace, var.security_group_name)
}

resource "aws_security_group" "this" {
  name        = local.security_group
  description = var.security_group_description
  vpc_id      = data.aws_vpc.default.id

  tags = merge(
    { Name = local.security_group },
    var.tags,
    var.security_group_tags
  )
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_vpc.default.cidr_block]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  to_port           = 22
  from_port         = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
