provider "aws" {
  region = "us-east-2"
}

variable "token" {
}

resource "aws_security_group" "inlets" {
  name        = "inlets"
  description = "Allow inbound traffic for inlets"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_8090" {
    type            = "ingress"
    from_port       = 8090
    to_port         = 8090
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.inlets.id
}

resource "aws_security_group_rule" "allow_ssh" {
    type            = "ingress"
    from_port   = 22
    to_port     = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.inlets.id
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.inlets.id
}

data "aws_ami" "ubuntu_cosmic" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-cosmic-18.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "inlets" {
  ami           = data.aws_ami.ubuntu_cosmic.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.inlets.id}" ]
  key_name = "KEYPAIR_NAME_HERE"   					# <- NOTE USE YOUR OWN KEYPAIR HERE
  subnet_id = module.vpc.public_subnets[0]
  user_data = "${data.template_file.user_data.rendered}"

  tags = {
    Name = "demo-inlets-ec2-instance"
  }
}

data "template_file" "user_data" {
  template = "${file("templates/inlets.tpl")}"

  vars = {
    token = "${var.token}"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "demo-inlets-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Automation = "true"
    Terraform = "true"
    Environment = "dev"
  }

    vpc_tags = {
    Name = "demo-inlets-vpc"
  }
}
