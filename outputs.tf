output "security_group" {
  value = "${aws_security_group.default_kube.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.etcd-lc.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.etcd-asg.id}"
}

output "elb_name" {
  value = "${aws_elb.etcd-elb.dns_name}"
}
