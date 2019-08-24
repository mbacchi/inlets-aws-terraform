# Instance public IP address
output "public_ip_address" {
  value = "${aws_lightsail_instance.inlets.public_ip_address}"
}

# Inlets token
output "inlets_token" {
  value = "${var.token}"
}
