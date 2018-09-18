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
##############################################################

resource "aws_db_subnet_group" "ccsdev-database-subnets" {
  name        = "ccsdev-database-subnets"
  description = "Access to CCSDEV databases from private and management subnets"
  subnet_ids  = ["${aws_subnet.CCSDEV-AZ-a-Private-1.id}", "${aws_subnet.CCSDEV-AZ-b-Private-1.id}", "${aws_subnet.CCSDEV-AZ-c-Private-1.id}", "${aws_subnet.CCSDEV-AZ-a-Management.id}", "${aws_subnet.CCSDEV-AZ-b-Management.id}", "${aws_subnet.CCSDEV-AZ-c-Management.id}"]
}

##############################################################
# Parameter Group for PostgreSQL
#
#   ccsdev-db-parameters
#       Example parameter group that enforces SSL
##############################################################

resource "aws_db_parameter_group" "ccsdev-db-parameters" {
  name        = "ccsdev-db-parameters"
  family      = "postgres9.6"
  description = "PostgreSQL parameters for CCSDEV"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }
}
