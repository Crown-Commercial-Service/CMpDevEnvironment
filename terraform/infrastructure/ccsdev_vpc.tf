provider "aws" {
  region     = "${var.region}"
}

##############################################################
#
# CCSDEV Virtual Private Cloud Definition
#
# This consists of a network using 192.168.0.0/16 divided
# into 3 availability zones.
#
# With each zone 3 subnets are defined:
#   Management
#   Public
#   Private
#
# A private DNS zone is created in route53
#
##############################################################

resource "aws_vpc" "CCSDEV-Services" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    "Name" = "CCSDEV Services"
  }
}

##############################################################
# Management Subnets
##############################################################

resource "aws_subnet" "CCSDEV-AZ-a-Management" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.15.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-a-Management"
  }
}

resource "aws_subnet" "CCSDEV-AZ-b-Management" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.31.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-b-Management"
  }
}

resource "aws_subnet" "CCSDEV-AZ-c-Management" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.47.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-c-Management"
  }
}

##############################################################
# Public Subnets
##############################################################

resource "aws_subnet" "CCSDEV-AZ-a-Public-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-a-Public-1"
  }
}

resource "aws_subnet" "CCSDEV-AZ-b-Public-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.16.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-b-Public-1"
  }
}

resource "aws_subnet" "CCSDEV-AZ-c-Public-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.32.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-c-Public-1"
  }
}

##############################################################
# Private Subnets
##############################################################

resource "aws_subnet" "CCSDEV-AZ-a-Private-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-a-Private-1"
  }
}

resource "aws_subnet" "CCSDEV-AZ-b-Private-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.17.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-b-Private-1"
  }
}

resource "aws_subnet" "CCSDEV-AZ-c-Private-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.33.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false

  tags {
    "Name" = "CCSDEV-AZ-c-Private-1"
  }
}

##############################################################
# VPC Access control list
##############################################################

resource "aws_network_acl" "acl-0a4ad1624819281ff" {
  vpc_id     = "${aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${aws_subnet.CCSDEV-AZ-a-Management.id}", "${aws_subnet.CCSDEV-AZ-b-Management.id}", "${aws_subnet.CCSDEV-AZ-c-Management.id}", "${aws_subnet.CCSDEV-AZ-a-Public-1.id}", "${aws_subnet.CCSDEV-AZ-b-Public-1.id}", "${aws_subnet.CCSDEV-AZ-c-Public-1.id}", "${aws_subnet.CCSDEV-AZ-a-Private-1.id}", "${aws_subnet.CCSDEV-AZ-b-Private-1.id}", "${aws_subnet.CCSDEV-AZ-c-Private-1.id}"]

  ingress {
    from_port  = "${var.http_port}"
    to_port    = "${var.http_port}"
    rule_no    = 100
    action     = "allow"
    protocol   = "6"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = "${var.https_port}"
    to_port    = "${var.https_port}"
    rule_no    = 110
    action     = "allow"
    protocol   = "6"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = "${var.ssh_port}"
    to_port    = "${var.ssh_port}"
    rule_no    = 120
    action     = "allow"
    protocol   = "6"
    cidr_block = "${var.roweit_office_ip}"
  }

  ingress {
    from_port  = "${var.ssh_port}"
    to_port    = "${var.ssh_port}"
    rule_no    = 130
    action     = "allow"
    protocol   = "6"
    cidr_block = "${aws_subnet.CCSDEV-AZ-a-Management.cidr_block}"
  }

  ingress {
    from_port  = "${var.ssh_port}"
    to_port    = "${var.ssh_port}"
    rule_no    = 140
    action     = "allow"
    protocol   = "6"
    cidr_block = "${aws_subnet.CCSDEV-AZ-b-Management.cidr_block}"
  }

  ingress {
    from_port  = "${var.ssh_port}"
    to_port    = "${var.ssh_port}"
    rule_no    = 150
    action     = "allow"
    protocol   = "6"
    cidr_block = "${aws_subnet.CCSDEV-AZ-c-Management.cidr_block}"
  }

  ingress {
    from_port  = 1024
    to_port    = 65535
    rule_no    = 160
    action     = "allow"
    protocol   = "6"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = "${var.http_port}"
    to_port    = "${var.http_port}"
    rule_no    = 100
    action     = "allow"
    protocol   = "6"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = "${var.https_port}"
    to_port    = "${var.https_port}"
    rule_no    = 110
    action     = "allow"
    protocol   = "6"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = "${var.ssh_port}"
    to_port    = "${var.ssh_port}"
    rule_no    = 120
    action     = "allow"
    protocol   = "6"
    cidr_block = "${aws_vpc.CCSDEV-Services.cidr_block}"
  }

  egress {
    from_port  = 1024
    to_port    = 65535
    rule_no    = 130
    action     = "allow"
    protocol   = "6"
    cidr_block = "0.0.0.0/0"
  }

  tags {}
}

##############################################################
# Internet Gateway
##############################################################

resource "aws_internet_gateway" "CCSDEV-Internet-Gateway" {
  vpc_id = "${aws_vpc.CCSDEV-Services.id}"

  tags {
    "Name" = "CCSDEV Internet Gateway"
  }
}

##############################################################
# Elastic IP's for NAT
##############################################################

resource "aws_eip" "CCSDEV-NAT-a-EIP" {
  vpc = true

  tags {
    "Name" = "CCSDEV-NAT-a-EIP"
  }
}

##############################################################
# NAT Gateway for private subnets outbound traffic
# AZ A only at the moment
##############################################################

resource "aws_nat_gateway" "CCSDEV-NAT-a-Gateway" {
  allocation_id = "${aws_eip.CCSDEV-NAT-a-EIP.id}"
  subnet_id     = "${aws_subnet.CCSDEV-AZ-a-Public-1.id}"

  tags {
    Name = "CCSDEV-NAT-a-Gateway"
  }
}

##############################################################
# Routing Tables
##############################################################

resource "aws_route_table" "CCSDEV-Main-Route-Table" {
  vpc_id = "${aws_vpc.CCSDEV-Services.id}"

  tags {
    "Name" = "CCSDEV Main Route Table"
  }
}

resource "aws_main_route_table_association" "CCSDEV-Main-Route-Table" {
  vpc_id         = "${aws_vpc.CCSDEV-Services.id}"
  route_table_id = "${aws_route_table.CCSDEV-Main-Route-Table.id}"
}

resource "aws_route_table" "CCSDEV-IG-Route-Table" {
  vpc_id = "${aws_vpc.CCSDEV-Services.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.CCSDEV-Internet-Gateway.id}"
  }

  tags {
    "Name" = "CCSDEV IG Route Table"
  }
}

resource "aws_route_table" "CCSDEV-NAT-a-Route-Table" {
  vpc_id = "${aws_vpc.CCSDEV-Services.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.CCSDEV-NAT-a-Gateway.id}"
  }

  tags {
    "Name" = "CCSDEV NAT a Route Table"
  }
}

##############################################################
# Routing Table/Subnet associations - gateway access
##############################################################

resource "aws_route_table_association" "CCSDEV-IG-Route-Table-Management-a" {
  route_table_id = "${aws_route_table.CCSDEV-IG-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-a-Management.id}"
}

resource "aws_route_table_association" "CCSDEV-IG-Route-Table-Management-b" {
  route_table_id = "${aws_route_table.CCSDEV-IG-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-b-Management.id}"
}

resource "aws_route_table_association" "CCSDEV-IG-Route-Table-Management-c" {
  route_table_id = "${aws_route_table.CCSDEV-IG-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-c-Management.id}"
}

resource "aws_route_table_association" "CCSDEV-IG-Route-Table-Public-1-a" {
  route_table_id = "${aws_route_table.CCSDEV-IG-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-a-Public-1.id}"
}

resource "aws_route_table_association" "CCSDEV-IG-Route-Table-Public-1-b" {
  route_table_id = "${aws_route_table.CCSDEV-IG-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-b-Public-1.id}"
}

resource "aws_route_table_association" "CCSDEV-IG-Route-Table-Public-1-c" {
  route_table_id = "${aws_route_table.CCSDEV-IG-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-c-Public-1.id}"
}

##############################################################
# Routing Table/Subnet associations - outbound access
##############################################################

resource "aws_route_table_association" "CCSDEV-NAT-a--Route-Table-Private-1-a" {
  route_table_id = "${aws_route_table.CCSDEV-NAT-a-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-a-Private-1.id}"
}

resource "aws_route_table_association" "CCSDEV-Main-Route-Table-Private-1-b" {
  route_table_id = "${aws_route_table.CCSDEV-NAT-a-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-b-Private-1.id}"
}

resource "aws_route_table_association" "CCSDEV-Main-Route-Table-Private-1-c" {
  route_table_id = "${aws_route_table.CCSDEV-NAT-a-Route-Table.id}"
  subnet_id      = "${aws_subnet.CCSDEV-AZ-c-Private-1.id}"
}

##############################################################
# Routing Table/Subnet associations - no external access
##############################################################

# None

##############################################################
# DNS Zone
##############################################################
resource "aws_route53_zone" "ccsdev-internal-org-private" {
  name       = "ccsdev-internal.org"
  comment    = "Internal DNS for CCSDEV VPC"
  vpc_id     = "${aws_vpc.CCSDEV-Services.id}"
  vpc_region = "eu-west-2"

  tags {}
}
