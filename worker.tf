resource "aws_autoscaling_group" "worker" {
  availability_zones   = ["${split(",", var.availability_zones)}"]
  name                      = "k8-worker-asg-${var.cluster_name}"
  max_size                  = 3
  min_size                  = "${var.worker_node_count}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = "${var.worker_node_count}"
  force_delete              = false
  launch_configuration      = "${aws_launch_configuration.worker.name}"

  tag {
    key                 = "Name"
    value               = "worker-${var.cluster_name}"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "apptype"
    value               = "k8-worker"
    propagate_at_launch = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_launch_configuration" "worker" {
  name                 = "k8-worker-lc-${var.cluster_name}"
  image_id             = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type        = "${var.worker_ins_type}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.default_kube.id}"]
  user_data            = "${template_file.worker-user-data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.worker.id}"


  lifecycle {
    create_before_destroy = true
  }
}
