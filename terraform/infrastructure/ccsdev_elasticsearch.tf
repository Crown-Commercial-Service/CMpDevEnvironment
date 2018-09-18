##############################################################
#
# CCSDEV Services Elastic Search
#
# Defines:
#   Elastic Search Domain
#   Private (VPC) DNS Entry
#
##############################################################

##############################################################
# Default Elastic search domain
#
# Many settings are defaults at present.
# Security is based on private VPC access
#
##############################################################

resource "aws_elasticsearch_domain" "CCSDEV-internal-es" {
  domain_name           = "${var.elasticsearch_domain}"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type = "${var.elasticsearch_instance_class}"
  }

vpc_options {
  "security_group_ids" = ["${aws_security_group.vpc-CCSDEV-internal-ES.id}"]
  "subnet_ids" = ["${aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
}

ebs_options {
  "ebs_enabled" = true,
  "volume_size" = 10
}

advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
       "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.elasticsearch_domain}/*"
    }
  ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    "Name" = "CCSDEV-internal-es"
  }
}

##############################################################
# Private VPC DNS zone CNAME to map to elastic search
#
# NOTE: This is not currently very useful because AWS
#       generated an HTTPS certificate that includes their
#       domain.
#       HTTP will work is enabled in the security group
#
##############################################################

resource "aws_route53_record" "CCSDEV-internal-es-CNAME" {
  zone_id = "${aws_route53_zone.ccsdev-internal-org-private.zone_id}"
  name    = "${var.elasticsearch_domain}.${aws_route53_zone.ccsdev-internal-org-private.name}"
  type    = "CNAME"
  records = ["${aws_elasticsearch_domain.CCSDEV-internal-es.endpoint}"]
  ttl     = "300"
}

