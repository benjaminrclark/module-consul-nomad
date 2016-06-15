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
   bind_address           = "${cidrhost(element(split(",",var.subnet_cidrs), count.index),4)}"
  }
}

resource "aws_instance" "consul" {
  count                   = "${var.servers_count}"
  instance_type           = "${var.instance_type}"
  ami                     = "${var.ami}"
  availability_zone       = "${element(split(",",var.subnet_availability_zones), count.index)}"
  key_name                = "${var.key_name}"
  subnet_id               = "${element(split(",",var.subnet_ids), count.index)}"
  private_ip              = "${cidrhost(element(split(",",var.subnet_cidrs), count.index),4)}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  user_data               = "${element(template_file.user_data.*.rendered, count.index)}"
  tags {
    Name = "consul-nomad-${count.index}"
  }
}

resource "null_resource" "configure_consul_server" {

  connection {
    user = "${var.ami_user}"
    host = "${element(aws_instance.consul.*.public_ip, 0)}"
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
    description = "Security group for Consul"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 1
        to_port = 65535
        protocol = "udp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    ingress {
        from_port = 1
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
