resource "aws_iam_instance_profile" "etcd" {
  name = "etcd-${var.environment}"

  roles = [
    "${aws_iam_role.etcd.name}"
  ]

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

// data "aws_iam_policy_document" "etcd_role" {

//   statement {

//     actions = [ "sts:AssumeRole" ]

//     principals {

//       type = "AWS"

//       identifiers = "*"

//     }

//   }

// }

resource "aws_iam_role" "etcd" {
  name = "etcd-${var.environment}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {"AWS": "*"},
        "Effect": "Allow",
        "Sid": ""
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "autoscaling.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}

data "aws_iam_policy_document" "etcd_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListObjects",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::etcd-backup-ami/*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListObjects",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::etcd-backup-ami",
      "arn:aws:s3:::etcd-backup-ami/*"
    ]
  }

  statement {
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:Describe*",
      "ec2:AssociateAddress",
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateVolume",
      "ec2:CreateTags",
      "ec2:CopySnapshot",
      "ec2:ImportSnapshot",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLifecycleHooks",
      "autoscaling:CompleteLifecycleAction"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]

    resources = ["*"]
  }

}

resource "aws_iam_policy_attachment" "etcd" {
  name       = "${var.name}-${var.environment}"
  roles      = ["${aws_iam_role.etcd.name}"]
  policy_arn = "${aws_iam_policy.etcd.arn}"
}

resource "aws_iam_policy" "etcd" {
  name   = "${var.name}-${var.environment}-policy"
  policy = "${data.aws_iam_policy_document.etcd_policy.json}"
}

resource "aws_iam_role" "master" {
    name = "k8s-master"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "master" {
    name = "k8s-master"
    roles = ["${aws_iam_role.master.name}"]
}

resource "aws_iam_role_policy" "master" {
    name = "k8s-master"
    role = "${aws_iam_role.master.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]


}
EOF
}


#worker
resource "aws_iam_role" "worker" {
    name = "k8s-worker"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "worker" {
    name = "k8s-worker"
    roles = ["${aws_iam_role.worker.name}"]
}

resource "aws_iam_role_policy" "worker" {
    name = "k8s-worker"
    role = "${aws_iam_role.worker.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]


}
EOF
}

