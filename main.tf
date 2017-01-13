# Specify the provider and access details

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_elb" "etcd-elb" {
  name = "etcd-example-elb"

  # The same availability zone as our instances
  availability_zones = ["${split(",", var.availability_zones)}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]

  listener {
    instance_port     = 2379
    instance_protocol = "http"
    lb_port           = 2379
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 2380
    instance_protocol = "http"
    lb_port           = 2380
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:2379"
    interval            = 30
  }

}

resource "aws_autoscaling_group" "etcd-asg" {
  availability_zones   = ["${split(",", var.availability_zones)}"]
  name                 = "etcd-example-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.etcd-lc.name}"
  load_balancers       = ["${aws_elb.etcd-elb.name}"]

  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  tag {
    key                 = "Name"
    value               = "etcd-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "etcd-lc" {
  name          = "etcd-example-lc"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.etcd.id}"

  # Security group
  security_groups = ["${aws_security_group.default_kube.id}"]
  user_data       = "${template_file.etcd-user-data.rendered}"
  key_name        = "${var.key_name}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default_kube" {
  name        = "etcd_example_sg"
  description = "Used in the etcd"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb_sg" {
  name        = "kube-elb-sg"
  description = "Security group for elbs exposed to outside"

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}



