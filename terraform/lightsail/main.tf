provider "aws" {
  region = "us-east-2"
}

variable "token" {
}

resource "aws_lightsail_instance" "inlets" {
  name              = "inlets"
  availability_zone = "us-east-2a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "nano_2_0"
  key_pair_name     = "lightsail_keypair"
  tags = {
    purpose = "inlets"
  }
  user_data = "${data.template_file.user_data.rendered}"
}

data "template_file" "user_data" {
  template = "${file("templates/inlets.tpl")}"

  vars = {
    token = "${var.token}"
  }
}

# Import ssh public key created using command:
#  `ssh-keygen -t rsa -b 4096 -N '' -f lightsail_keypair`
resource "aws_lightsail_key_pair" "lightsail_keypair" {
  name       = "lightsail_keypair"
  public_key = "${file("./lightsail_keypair.pub")}"
}