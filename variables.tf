variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}

# CoreOS
variable "aws_amis" {
  default = {
    "ap-northeast-1" = "ami-ce90f2a9"
    "eu-central-1" = "ami-ed0ec882"
    "eu-central-2" = "ami-11b14b7e"
  }
}

variable "availability_zones" {
  default     = "eu-central-1a,eu-central-1b"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "key_name" {
  description = "aws key"
  default = "etcd-key"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "3"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "5"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "3"
}
variable "environment" {
  description = "environment"
  default     = "test"
}
variable "name" {
  description = "environment name"
  default     = "etcdtest"
}
variable "kubernetes_version" {
  default = "1.2.2"
}
variable "service_ip_range" {
  default = "10.5.0.0/16"
}
variable "api_secure_port" {
  default = "443"
}
variable "dns_service_ip" {
  default = "10.5.0.10"
}
variable "s3_bucket" {
  default = "k8tlsbucket"
}
variable "pod_network" {
    default = "10.5.0.0/16"
}
variable "kubelet_version" {
    default = "v1.5.1_coreos.0"
}
variable "cluster_name" {
  default = "kube-cluster"
}
variable "master_node_count" {
  default = "1"
}
variable "master_ins_type" {
  default = "m4.large"
}
variable "worker_node_count" {
  default = "3"
}
variable "idle_timeout" {
  default = "3600"
}
