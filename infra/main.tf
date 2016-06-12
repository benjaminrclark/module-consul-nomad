
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "template_file" "user_data" {
  template = "${file("${path.module}/consul_update.sh.tpl")}"
  vars {
   region                 = "${var.aws_region}"
   server_addresses       = "${join(",",formatlist("#%s#",split(",",var.consul_servers)))}" 
  }
}

resource "aws_security_group" "nomad_worker" {
    name = "nomad_worker_security_group"
    description = "Security group for Nomad Workers"
    vpc_id = "${var.vpc_id}"
}

resource "aws_security_group" "frontend" {
    name = "frontend_security_group"
    description = "Security group for ELB"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 80 
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      security_groups = ["${aws_security_group.nomad_worker.id}"]
   }
    egress {
      from_port = 8081
      to_port = 8081
      protocol = "tcp"
      security_groups = ["${aws_security_group.nomad_worker.id}"]
   }
}

resource "aws_launch_configuration" "nomad_worker" {
  instance_type          = "${var.instance_type}"
  image_id               = "${var.ami}"
  key_name               = "${var.key_name}"
  security_groups        = ["${var.consul_security_group}","${aws_security_group.nomad_worker.id}"]
  user_data              = "${template_file.user_data.rendered}"
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_elb" "frontend" {
  name = "nomad-elb"
  subnets =  ["${split(",", var.subnet_ids)}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.frontend.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8081/health"
    interval = 30
  }
  tags {
    Name = "frontend-elb"
  }
}

resource "aws_autoscaling_group" "nomad_workers" {
  name                 = "nomad_worker_asg"
  launch_configuration = "${aws_launch_configuration.nomad_worker.name}"
  load_balancers = ["${aws_elb.frontend.name}"]
  min_size         = "${var.servers_count}"
  max_size         = "${var.servers_count}"
  vpc_zone_identifier  = ["${split(",", var.subnet_ids)}"]
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${var.route53_zone_id}"
  name = "${var.route53_domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.frontend.dns_name}"
    zone_id = "${aws_elb.frontend.zone_id}"
    evaluate_target_health = true
  }
}
