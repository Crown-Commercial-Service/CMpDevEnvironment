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

data "aws_security_group" "CCSDEV_external_ssh" {
  name = "CCSDEV-external-ssh"
}

data "template_file" "CCSDEV_bastion_cluster_user_data" {
  template = "${file("./bastion_userdata.sh")}"

  vars = {
    ssh_ciphers = "${var.bastion_ssh_ciphers}"
  }
}

resource "aws_autoscaling_group" "CCSDEV_bastion_cluster_autoscaling_group" {
  desired_capacity     = "${var.bastion_desired_instance_count}"
  max_size             = "${var.bastion_max_instance_count}"
  min_size             = "${var.bastion_min_instance_count}"
  termination_policies = ["OldestInstance"]

  name                  = "CCSDEV_bastion_cluster_scaling"
  protect_from_scale_in = false
  vpc_zone_identifier   = ["${aws_subnet.CCSDEV-AZ-a-Management.id}"]

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

resource "aws_iam_role" "CCSDEV_bastion_cluster_instance_role" {
  name               = "CCSDEV-bastion-cluster-instance-role"
  assume_role_policy = "${data.aws_iam_policy_document.CCSDEV_bastion_cluster_instance_policy.json}"
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
