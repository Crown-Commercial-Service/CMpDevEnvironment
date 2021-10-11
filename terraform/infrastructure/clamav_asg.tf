data "aws_iam_role" "CCSDEV_clamav_instance_role" {
  name = "${var.clamav_instance_role}"
}

data "aws_subnet" "CCSDEV_clamav_subnet" {
    id = "${var.CCSDEV_clamv_subnet_id}"
}

data "aws_iam_policy_document" "CCSDEV_clamav_instance_policy" {
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

data "aws_security_group" "CCSDEV_internal_ssh" {
  name = "${var.clamav_internal_ssh_sg_name}"
}

data "aws_security_group" "CCSDEV_internal_app" {
  name = "${var.clamav_internal_app_sg_name}"
}

data "template_file" "CCSDEV_clamav_user_data" {
    template = "${file("./clamav_userdata.sh")}"
}


resource "aws_autoscaling_group" "CLAMAV_autoscaling_group" {
    desired_capacity = "${var.clamav_desired_capacity}"
    max_size = "${var.clamav_maximum_capacity}"
    min_size = "${var.clamav_minimum_capacity}"
    termination_policies = ["OldestInstance"]

    name = "${var.clamav_asg_name}"
    protect_from_scale_in = false
    vpc_zone_identifier = ["${data.aws_subnet.CCSDEV_clamav_subnet.id}"]

    launch_template {
        id = "${aws_launch_template.CLAMAV_launch_template.id}"
        version = "$Latest"
    }
    tags = {
        key = "Name"
        value = "${var.clamav_name_tag}"
        propagate_at_launch = true
    }
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

resource "aws_iam_instance_profile" "CCSDEV_clamav_instance_profile" {
    name = "${var.clamav_instance_profile_name}"
    role = "${data.aws_iam_role.CCSDEV_clamav_instance_role.name}"
}

resource "aws_launch_template" "CLAMAV_launch_template" {
    image_id = "${var.clamav_ami_id}"
    instance_type = "${var.clamav_instance_type}"
    key_name = "${var.clamav_key_name}"
    name = "${var.clamav_launch_template_name}"
    user_data = "${base64encode(data.template_file.CCSDEV_clamav_user_data.rendered)}"

    block_device_mappings {
        device_name = "${var.clamav_device_name}"
        ebs {
            delete_on_termination = true
            encrypted = true
            volume_size = "${var.clamav_volume_size}"
            volume_type = "${var.clamav_volume_type}"
        }
    }

    iam_instance_profile {
        name = "${aws_iam_instance_profile.CCSDEV_clamav_instance_profile.name}"
    }

    network_interfaces {
        associate_public_ip_address = false
        security_groups = ["${data.aws_security_group.CCSDEV_internal_ssh.id}", "${data.aws_security_group.CCSDEV_internal_api.id}"]
    }
}
