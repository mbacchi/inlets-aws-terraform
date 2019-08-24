# Instance public IP address
output "public_ip_address" {
  value = "${aws_instance.inlets.public_ip}"
}

# Inlets token
output "inlets_token" {
  value = "${var.token}"
}
