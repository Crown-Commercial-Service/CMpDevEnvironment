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
# ElasticSearch Encryption key
##############################################################

resource "aws_kms_key" "ccsdev_es_key" {
  description             = "CCSDEV ES Key"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "ccsdev_es_key_alias" {
  name          = "alias/ccsdeves"
  target_key_id = "${aws_kms_key.ccsdev_es_key.key_id}"
}

##############################################################
# Default Elastic search domain
#
# Many settings are defaults at present.
# Security is based on private VPC access
#
##############################################################

resource "aws_elasticsearch_domain" "CCSDEV-internal-default-es" {
  # Only create if create_elasticsearch_domain is true (1) 
  count = "${var.create_elasticsearch_default_domain}"

  domain_name           = "${var.elasticsearch_default_domain}"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type = "${var.elasticsearch_default_instance_class}"
  }

  vpc_options {
    "security_group_ids" = ["${aws_security_group.vpc-CCSDEV-internal-ES.id}"]
    "subnet_ids"         = ["${aws_subnet.CCSDEV-AZ-a-Private-1.id}"]
  }

  encrypt_at_rest {
    "enabled"    = true
    "kms_key_id" = "${aws_kms_key.ccsdev_es_key.arn}"
  }

  ebs_options {
    "ebs_enabled" = true
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
       "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.elasticsearch_default_domain}/*"
    }
  ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    "Name" = "CCSDEV-internal-default-es"
  }
}

##############################################################
# Private VPC DNS zone CNAME to map to default elastic search
#
# NOTE: This is not currently very useful because AWS
#       generated an HTTPS certificate that includes their
#       domain.
#       HTTP will work is enabled in the security group
#
##############################################################

resource "aws_route53_record" "CCSDEV-internal-default-es-CNAME" {
  # Only create if create_elasticsearch_domain is true (1) 
  count = "${var.create_elasticsearch_default_domain}"

  zone_id = "${aws_route53_zone.ccsdev-internal-org-private.zone_id}"
  name    = "${var.elasticsearch_default_domain}.es.${aws_route53_zone.ccsdev-internal-org-private.name}"
  type    = "CNAME"
  records = ["${aws_elasticsearch_domain.CCSDEV-internal-default-es.endpoint}"]
  ttl     = "300"
}
