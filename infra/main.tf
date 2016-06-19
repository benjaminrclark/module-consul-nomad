provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "template_file" "user_data" {
  count    = "${var.servers_count}"
  template = "${file("${path.module}/consul_update.sh.tpl")}"

  vars {
   region                 = "${var.aws_region}"
   availability_zone      = "${element(split(",",var.subnet_availability_zones), count.index)}"
   bootstrap_expect       = "${var.servers_count}"
   bind_address           = "${cidrhost(element(split(",",var.subnet_cidrs), count.index),6)}"
  }
}

resource "aws_instance" "consul" {
  count                   = "${var.servers_count}"
  instance_type           = "${var.instance_type}"
  ami                     = "${var.ami}"
  availability_zone       = "${element(split(",",var.subnet_availability_zones), count.index)}"
  key_name                = "${var.key_name}"
  subnet_id               = "${element(split(",",var.subnet_ids), count.index)}"
  private_ip              = "${cidrhost(element(split(",",var.subnet_cidrs), count.index),6)}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  user_data               = "${element(template_file.user_data.*.rendered, count.index)}"
  tags {
    Name = "consul-nomad-${count.index}"
  }
}

resource "null_resource" "configure_consul_server" {

  connection {
    user = "${var.ami_user}"
    host = "${element(aws_instance.consul.*.private_ip, 0)}"
    bastion_host = "${element(split(",",var.bastion_hosts), 0)}"
  }

  provisioner "remote-exec" {
    inline = [
        "echo 'sleeping for 20 seconds'",
        "sleep 20",
        "echo 'consul join ${join(" ", aws_instance.consul.*.private_ip)}'",
        "consul join ${join(" ", aws_instance.consul.*.private_ip)}",
        "echo 'export NOMAD_ADDR=http://${element(aws_instance.consul.*.private_ip,0)}:4646'",
        "export NOMAD_ADDR=http://${element(aws_instance.consul.*.private_ip,0)}:4646",
        "echo 'nomad server-join ${join(" ", formatlist("%s:4648",aws_instance.consul.*.private_ip))}'",
        "nomad server-join ${join(" ", aws_instance.consul.*.private_ip)}"
    ]
  }
}

resource "aws_security_group" "consul" {
    name = "consul_security_group"
    description = "Security group for Consul Servers"
    vpc_id = "${var.vpc_id}"

}

resource "aws_security_group_rule" "consul_cluster_udp_ingress" {
    type = "ingress"
    from_port = 1
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
    security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_cluster_tcp_ingress" {
    type = "ingress"
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_cluster_ssh_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.consul.id}"
    source_security_group_id = "${var.bastion_security_group}"
}

resource "aws_security_group_rule" "consul_cluster_http_egress" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_cluster_https_egress" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.consul.id}"
}
