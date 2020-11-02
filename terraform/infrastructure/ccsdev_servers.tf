##############################################################
#
# CCSDEV Servers
#
# Defines:
#   Linux Basition host
#
##############################################################

##############################################################
# Bastion Host AZ A
##############################################################

resource "aws_instance" "CCSDEV_BASTION_a" {
  ami                         = "${var.bastion_ami}"
  availability_zone           = "eu-west-2a"
  ebs_optimized               = false
  instance_type               = "${var.bastion_instance_class}"
  monitoring                  = false
  key_name                    = "${var.bastion_key_name}"
  subnet_id                   = "${aws_subnet.CCSDEV-AZ-a-Management.id}"
  vpc_security_group_ids      = ["${aws_security_group.vpc-CCSDEV-external-ssh.id}"]
  associate_public_ip_address = true
  source_dest_check           = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.bastion_storage}"
    delete_on_termination = true
  }

  tags {
    Name = "CCSDEV_BASTION_a"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_cloudfront_distribution" "" {
  enabled = false
  default_cache_behavior {
    allowed_methods = []
    cached_methods = []
    target_origin_id = ""
    viewer_protocol_policy = ""
    forwarded_values {
      query_string = false
      cookies {
        forward = ""
      }
    }
  }
  origin {
    domain_name = ""
    origin_id = ""
  }
  restrictions {
    geo_restriction {
      restriction_type = ""
    }
  }
  viewer_certificate {}
}
