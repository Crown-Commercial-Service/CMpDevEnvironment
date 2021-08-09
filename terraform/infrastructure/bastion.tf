data "aws_iam_policy_document" "CCSDEV_bastion_cluster_instance_policy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "CCSDEV_bastion_cluster_secrets_manager_policy" {
  version = "2012-10-17"
  statement {
    sid = ""
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
}

data "aws_secretsmanager_secret_version" "ssh_ciphers" {
  secret_id = "${aws_secretsmanager_secret.ssh_ciphers.id}"
}

data "aws_security_group" "CCSDEV_external_ssh" {
  name = "CCSDEV-external-ssh"
}

data "template_file" "CCSDEV_bastion_cluster_user_data" {
  template = "${file("./bastion_userdata.tpl")}"

  vars {
    ssh_ciphers = "${data.aws_secretsmanager_secret_version.ssh_ciphers.secret_string}"
  }
}

resource "aws_autoscaling_group" "CCSDEV_bastion_cluster_autoscaling_group" {
  desired_capacity      = "${var.bastion_desired_instance_count}"
  max_size              = "${var.bastion_max_instance_count}"
  min_size              = "${var.bastion_min_instance_count}"

  name                  = "CCSDEV_app_cluster_scaling"
  protect_from_scale_in = true
  vpc_zone_identifier   = ["${aws_subnet.CCSDEV-AZ-a-Public-1.id}"]

  launch_template {
    id      = "${aws_launch_template.CCSDEV_bastion_cluster_launch_template.id}"
    version = "$Latest"
  }

  tags = [
    {
      key                 = "Name"
      value               = "CCSDEV_bastion_cluster_host"
      propagate_at_launch = true
    },
    {
      key                 = "CCSRole"
      value               = "Bastion"
      propagate_at_launch = true
    },
    {
      key                 = "CCSEnvironment"
      value               = "${var.environment_name}"
      propagate_at_launch = true
    },
  ]

  enabled_metrics = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity",
  ]
}

resource "aws_iam_instance_profile" "CCSDEV_bastion_cluster_instance_profile" {
  name = "CCSDEV-bastion-cluster-instance-profile"
  role = "${aws_iam_role.CCSDEV_app_cluster_instance_role.name}"
}

resource "aws_iam_policy" "CCSDEV_bastion_cluster_secrets_manager_policy" {
  name   = "CCSDEV_bastion_cluster_secrets_manager_policy"
  policy = "${data.aws_iam_policy_document.CCSDEV_bastion_cluster_secrets_manager_policy.json}"
}

resource "aws_iam_role" "CCSDEV_bastion_cluster_instance_role" {
  name               = "CCSDEV-bastion-cluster-instance-role"
  assume_role_policy = "${data.aws_iam_policy_document.CCSDEV_bastion_cluster_instance_policy.json}"
}

resource "aws_iam_role_policy_attachment" "CCSDEV_bastion_cluster_secrets_manager_policy" {
  policy_arn = "${aws_iam_policy.CCSDEV_bastion_cluster_secrets_manager_policy.arn}"
  role       = "${aws_iam_role.CCSDEV_bastion_cluster_instance_role.name}"
}

resource "aws_launch_template" "CCSDEV_bastion_cluster_launch_template" {
  image_id      = "${var.bastion_ami}"
  instance_type = "${var.bastion_instance_class}"
  key_name      = "${var.bastion_key_name}"
  name          = "CCSDEV_bastion_launch_config_"
  user_data     = "${base64encode(data.template_file.CCSDEV_bastion_cluster_user_data.rendered)}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_size           = 8
      volume_type           = "gp2"
    }
  }

  iam_instance_profile {
    name = "${aws_iam_instance_profile.CCSDEV_bastion_cluster_instance_profile.name}"
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${data.aws_security_group.CCSDEV_external_ssh.id}"]
  }
}

resource "aws_secretsmanager_secret" "ssh_ciphers" {
  name                      = "ssh_ciphers"
  recovery_window_in_days   = 7
}
