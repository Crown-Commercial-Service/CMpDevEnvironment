##############################################################
#
# CCSDEV Services Database
#
# Defines:
#   PostgreSQL Database instances
#   PostgreSQL Subnets
#   PostgreSQL Parameter groups
#
##############################################################

##############################################################
# PostgreSQL Database instances
#
# Note use of timestamp to create unique final snapshot id
##############################################################

##############################################################
# Subnet groups
#
# Note access from public subnet granted for initial 
# development work.
#
##############################################################

resource "aws_db_subnet_group" "ccsdev-legacy-database-subnet-group" {
  name        = "ccsdev-legacy-database-subnet-group"
  description = "Access to CCSDEV legacy databases from private and management subnets"
  subnet_ids  = ["${aws_subnet.CCSDEV-AZ-a-Public-1.id}","${aws_subnet.CCSDEV-AZ-b-Public-1.id}","${aws_subnet.CCSDEV-AZ-c-Public-1.id}","${aws_subnet.CCSDEV-AZ-a-Private-1.id}", "${aws_subnet.CCSDEV-AZ-b-Private-1.id}", "${aws_subnet.CCSDEV-AZ-c-Private-1.id}", "${aws_subnet.CCSDEV-AZ-a-Management.id}", "${aws_subnet.CCSDEV-AZ-b-Management.id}", "${aws_subnet.CCSDEV-AZ-c-Management.id}"]
  
  tags {
    Name = "CCSDEV legacy database subnets"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Parameter Group for PostgreSQL
#
#   ccsdev-legacy-db-parameters
#       Example parameter group that enforces SSL
##############################################################

resource "aws_db_parameter_group" "ccsdev-legacy-db-parameters" {
  name        = "ccsdev-legacy-db-parameters"
  family      = "postgres9.6"
  description = "PostgreSQL parameters for CCSDEV"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags {
    Name = "CCSDEV legacy database parameters"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_db_parameter_group" "ccsdev-legacy-db-parameters11" {
  name        = "ccsdev-legacy-db-parameters11"
  family      = "postgres11"
  description = "PostgreSQL 11 parameters for CCSDEV"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags {
    Name = "CCSDEV legacy database parameters 11"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# PostgreSQL Database Encryption key
##############################################################

#resource "aws_kms_key" "ccsdev_db_key" {
#  description             = "CCSDEV DB Key"
#  deletion_window_in_days = 10
#
#  tags {
#    Name = "CCSDEV database KMS key"
#    CCSRole = "Infrastructure"
#    CCSEnvironment = "${var.environment_name}"
#  }
#}

#resource "aws_kms_alias" "ccsdev_db_key_alias" {
#  name          = "alias/ccsdevdb"
#  target_key_id = "${aws_kms_key.ccsdev_db_key.key_id}"
#}

resource "aws_kms_key" "ccsdev_legacy_db_key" {
  description             = "CCSDEV LEGACY DB Key"
  deletion_window_in_days = 10

  tags {
    Name = "CCSDEV legacy database KMS key"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_kms_alias" "ccsdev_legacy_db_key_alias" {
  name          = "alias/ccsdevlegacydb"
  target_key_id = "${aws_kms_key.ccsdev_legacy_db_key.key_id}"
}


##############################################################
# PostgreSQL Default Database instance
#
# Note that this is currently an example with limited 
# performance and no replication or multi-AZ support
#
# Note use of timestamp to create unique final snapshot id
##############################################################

locals {
  ccsdev_legacy_default_db_password = "${var.default_db_password == "" ? random_string.ccsdev_legacy_default_db_password.result : var.default_db_password}"
}

resource "random_string" "ccsdev_legacy_default_db_password" {
  length = 30
  special = false
  number = true
  lower = true
  upper = true
}

resource "aws_db_instance" "ccsdev_legacy_default_db" {
  # Only create if create_rds_database is true (1) 
  count = "${var.create_default_rds_database}"

  lifecycle {
    ignore_changes = ["final_snapshot_identifier"]
  }

#  identifier                = "ccsdev-db"
  identifier                = "ccsdev-legacy-db"
  allocated_storage         = "${var.default_db_storage}"
  apply_immediately         = "${var.default_db_apply_immediately}"
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "11.2"
  instance_class            = "${var.default_db_instance_class}"
  name                      = "${var.default_db_name}"
  username                  = "${var.default_db_username}"
  password                  = "${local.ccsdev_legacy_default_db_password}"
  port                      = "${var.postgres_port}"
  publicly_accessible       = false
  multi_az                  = false
  availability_zone         = "eu-west-2a"
  vpc_security_group_ids    = ["${aws_security_group.vpc-CCSDEV-internal-PG-DB.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.ccsdev-legacy-database-subnet-group.id}"
  parameter_group_name      = "${aws_db_parameter_group.ccsdev-legacy-db-parameters11.id}"
  backup_retention_period   = "${var.default_db_retention_period}"
  backup_window             = "22:45-23:15"
  maintenance_window        = "sat:04:03-sat:04:33"
  final_snapshot_identifier = "${format("ccsdev-legacy-db-final-%s", md5(timestamp()))}"
  #final_snapshot_identifier = "${format("ccsdev-db-final-%s", md5(timestamp()))}"
  storage_encrypted         = true
  kms_key_id                = "${aws_kms_key.ccsdev_legacy_db_key.arn}"
  #kms_key_id                = "${aws_kms_key.ccsdev_db_key.arn}"

  tags {
  #  Name = "CCSDEV database"
    Name = "CCSDEV legacy database"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Private VPC DNS zone CNAME to map to database
#
##############################################################

resource "aws_route53_record" "CCSDev-internal-legacy-db-CNAME" {
  # Only create if create_rds_database is true (1) 
  count = "${var.create_default_rds_database}"

  zone_id = "${aws_route53_zone.ccsdev-internal-org-private.zone_id}"
  name    = "${var.default_db_name}.legacy.db.${aws_route53_zone.ccsdev-internal-org-private.name}"
  type    = "CNAME"
  records = ["${aws_db_instance.ccsdev_legacy_default_db.address}"]
  ttl     = "300"
}

