##############################################################
#
# CCSDEV Services Virtual Private Cloud Security Groups
#
# Defines security groups used by:
#   EC2 server instances
#   Load balancers
#
##############################################################

resource "aws_security_group" "vpc-CCSDEV-internal-ssh" {
  name        = "CCSDEV-internal-ssh"
  description = "ssh from hosts in management subnet"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.CCSDEV-AZ-a-Management.cidr_block}", "${aws_subnet.CCSDEV-AZ-b-Management.cidr_block}", "${aws_subnet.CCSDEV-AZ-c-Management.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-internal-ssh"
  }
}

resource "aws_security_group" "vpc-CCSDEV-external-ssh" {
  name        = "CCSDEV-external-ssh"
  description = "ssh from external hosts"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.roweit_office_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-external-ssh"
  }
}

##############################################################
# App cluster security groups
##############################################################

resource "aws_security_group" "vpc-CCSDEV-internal-app" {
  name        = "CCSDEV-internal-app"
  description = "App access internal hosts"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "32768"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.CCSDEV-Services.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-internal-app"
  }
}

resource "aws_security_group" "vpc-CCSDEV-external-app" {
  name        = "CCSDEV-external-app"
  description = "App access external hosts"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  tags {
    "Name" = "CCSDEV-external-app"
  }
}

resource "aws_security_group" "vpc-CCSDEV-external-app-alb" {
  name        = "CCSDEV-external-app-alb"
  description = "Application access external via alb"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.roweit_office_ip}"]
  }

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.ccs_a_ip}"]
  }

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.ccs_b_ip}"]
  }

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.ccs_c_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-external-app-alb"
  }
}

##############################################################
# Api cluster security groups
##############################################################

resource "aws_security_group" "vpc-CCSDEV-internal-api" {
  name        = "CCSDEV-internal-api"
  description = "API access external hosts"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "32768"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.CCSDEV-Services.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-internal-api"
  }
}

resource "aws_security_group" "vpc-CCSDEV-internal-api-alb" {
  name        = "CCSDEV-internal-api-alb"
  description = "Api access internal via alb"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.CCSDEV-Services.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-internal-api-alb"
  }
}

##############################################################
# Database access security groups
##############################################################

resource "aws_security_group" "vpc-CCSDEV-internal-PG-DB" {
  name        = "CCSDEV-internal-PG-DB"
  description = "PostgreSQL from within VPC"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "${var.postgres_port}"
    to_port     = "${var.postgres_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.CCSDEV-AZ-a-Private-1.cidr_block}", "${aws_subnet.CCSDEV-AZ-b-Private-1.cidr_block}", "${aws_subnet.CCSDEV-AZ-c-Private-1.cidr_block}", "${aws_subnet.CCSDEV-AZ-a-Management.cidr_block}", "${aws_subnet.CCSDEV-AZ-b-Management.cidr_block}", "${aws_subnet.CCSDEV-AZ-c-Management.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-internal-PG-DB"
  }
}

##############################################################
# Elastic Search security groups
##############################################################

resource "aws_security_group" "vpc-CCSDEV-internal-ES" {
  name        = "CCSDEV-internal-ES"
  description = "ElasticSearch from within VPC private and management"
  vpc_id      = "${aws_vpc.CCSDEV-Services.id}"

  ingress {
    from_port   = "${var.https_port}"
    to_port     = "${var.https_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.CCSDEV-AZ-a-Private-1.cidr_block}", "${aws_subnet.CCSDEV-AZ-b-Private-1.cidr_block}", "${aws_subnet.CCSDEV-AZ-c-Private-1.cidr_block}", "${aws_subnet.CCSDEV-AZ-a-Management.cidr_block}", "${aws_subnet.CCSDEV-AZ-b-Management.cidr_block}", "${aws_subnet.CCSDEV-AZ-c-Management.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "CCSDEV-internal-ES"
  }
}
