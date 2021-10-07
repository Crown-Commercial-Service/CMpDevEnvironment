data "aws_security_group" "CCSDEV-internal-ssh" {
  name = "CCSDEV-internal-ssh"
}

data "aws_security_group" "CCSDEV-internal-api" {
  name = "CCSDEV-internal-api"
}


resource "aws_autoscaling_group" "CLAMAV_autoscaling_group" {
    desired_capacity = var.clamav_desired_capacity
    max_size = var.clamav_maximum_capacity
    min_size = var.clamav_minimum_capacity

    name = var.clamav_asg_name
    protect_from_scale_in = false
    vpc_zone_identifier = ["${aws_subnet.CCSDEV-AZ-b-Private-1.id}"]

    launch_template {
        id = aws_launch_template.CLAMAV_launch_template.id
        version = "$Latest"
    }
}

resource "aws_launch_template" "CLAMAV_launch_template" {
    image_id = var.clamav_ami_id
    instance_type = var.clamav_instance_type
    key_name = var.clamav_key_name
    name = var.clamav_launch_template_name
    
    block_device_mappings {
        device_name = var.clamav_device_name
        ebs {
            delete_on_termination = true
            encrypted = true
            volume_size = var.clamav_volume_size
            volume_type = var.clamav_volume_type
        }
    }

    network_interfaces {
        associate_public_ip_address = false
        security_groups = [data.aws_security_group.CCSDEV-internal-ssh.id, data.aws_security_group.CCSDEV-internal-api.id]
    }
}