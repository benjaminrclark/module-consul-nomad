output "server_addresses" {
    value = "${join(",",aws_instance.consul.*.private_ip)}"
}

output "server_public_addresses" {
    value = "${join(",",aws_instance.consul.*.public_ip)}"
}

output "security_group_id" {
    value = "${aws_security_group.consul.id}"
}
