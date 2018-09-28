provider "aws" {
  region = "${var.region}"
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
    Name = "CCSDEV Services"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
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
    Name = "CCSDEV-AZ-a-Management"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_subnet" "CCSDEV-AZ-b-Management" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.31.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags {
    Name = "CCSDEV-AZ-b-Management"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_subnet" "CCSDEV-AZ-c-Management" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.47.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false

  tags {
    Name = "CCSDEV-AZ-c-Management"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
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
    Name = "CCSDEV-AZ-a-Public-1"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_subnet" "CCSDEV-AZ-b-Public-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.16.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags {
    Name = "CCSDEV-AZ-b-Public-1"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_subnet" "CCSDEV-AZ-c-Public-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.32.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false

  tags {
    Name = "CCSDEV-AZ-c-Public-1"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
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
    Name = "CCSDEV-AZ-a-Private-1"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_subnet" "CCSDEV-AZ-b-Private-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.17.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags {
    Name = "CCSDEV-AZ-b-Private-1"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_subnet" "CCSDEV-AZ-c-Private-1" {
  vpc_id                  = "${aws_vpc.CCSDEV-Services.id}"
  cidr_block              = "192.168.33.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false

  tags {
    Name = "CCSDEV-AZ-c-Private-1"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# VPC Access control list
##############################################################

resource "aws_network_acl" "acl-0a4ad1624819281ff" {
  vpc_id     = "${aws_vpc.CCSDEV-Services.id}"
  subnet_ids = ["${aws_subnet.CCSDEV-AZ-a-Management.id}", "${aws_subnet.CCSDEV-AZ-b-Management.id}", "${aws_subnet.CCSDEV-AZ-c-Management.id}", "${aws_subnet.CCSDEV-AZ-a-Public-1.id}", "${aws_subnet.CCSDEV-AZ-b-Public-1.id}", "${aws_subnet.CCSDEV-AZ-c-Public-1.id}", "${aws_subnet.CCSDEV-AZ-a-Private-1.id}", "${aws_subnet.CCSDEV-AZ-b-Private-1.id}", "${aws_subnet.CCSDEV-AZ-c-Private-1.id}"]

  tags {
    Name = "CCSDEV VPC Access Control List"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-ingress-http" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = false
  from_port      = "${var.http_port}"
  to_port        = "${var.http_port}"
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-ingress-https" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = false
  from_port      = "${var.https_port}"
  to_port        = "${var.https_port}"
  rule_number    = 110
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-ingress-ssh-AZ-a" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = false
  from_port      = "${var.ssh_port}"
  to_port        = "${var.ssh_port}"
  rule_number    = 120
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "${aws_subnet.CCSDEV-AZ-a-Management.cidr_block}"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-ingress-ssh-AZ-b" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = false
  from_port      = "${var.ssh_port}"
  to_port        = "${var.ssh_port}"
  rule_number    = 130
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "${aws_subnet.CCSDEV-AZ-b-Management.cidr_block}"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-ingress-ssh-AZ-c" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = false
  from_port      = "${var.ssh_port}"
  to_port        = "${var.ssh_port}"
  rule_number    = 140
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "${aws_subnet.CCSDEV-AZ-c-Management.cidr_block}"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-ingress-ephemeral" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = false
  from_port      = 1024
  to_port        = 65535
  rule_number    = 150
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-ingress-ssh" {
  count          = "${length(keys(var.ssh_access_cidrs))}"
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = false
  from_port      = "${var.ssh_port}"
  to_port        = "${var.ssh_port}"
  rule_number    = "${200 + count.index}"
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "${element(values(var.ssh_access_cidrs), count.index)}"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-egress-http" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = true
  from_port      = "${var.http_port}"
  to_port        = "${var.http_port}"
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-egress-https" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = true
  from_port      = "${var.https_port}"
  to_port        = "${var.https_port}"
  rule_number    = 110
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-egress-ssh" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = true
  from_port      = "${var.ssh_port}"
  to_port        = "${var.ssh_port}"
  rule_number    = 120
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "${aws_vpc.CCSDEV-Services.cidr_block}"
}

resource "aws_network_acl_rule" "acl-0a4ad1624819281ff-egress-ephemeral" {
  network_acl_id = "${aws_network_acl.acl-0a4ad1624819281ff.id}"
  egress         = true
  from_port      = 1024
  to_port        = 65535
  rule_number    = 130
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
}

##############################################################
# Internet Gateway
##############################################################

resource "aws_internet_gateway" "CCSDEV-Internet-Gateway" {
  vpc_id = "${aws_vpc.CCSDEV-Services.id}"

  tags {
    Name = "CCSDEV Internet Gateway"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Elastic IP's for NAT
##############################################################

resource "aws_eip" "CCSDEV-NAT-a-EIP" {
  vpc = true

  tags {
    Name = "CCSDEV-NAT-a-EIP"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
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
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Routing Tables
##############################################################

resource "aws_route_table" "CCSDEV-Main-Route-Table" {
  vpc_id = "${aws_vpc.CCSDEV-Services.id}"

  tags {
    Name = "CCSDEV Main Route Table"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
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
    Name = "CCSDEV IG Route Table"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_route_table" "CCSDEV-NAT-a-Route-Table" {
  vpc_id = "${aws_vpc.CCSDEV-Services.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.CCSDEV-NAT-a-Gateway.id}"
  }

  tags {
    Name = "CCSDEV NAT a Route Table"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
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
# DNS Zones
##############################################################
data "aws_route53_zone" "public_cluster_https_domain" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_zone" "ccsdev-internal-org-private" {
  name       = "${var.domain_internal_prefix}.${var.domain_name}"
  comment    = "Internal DNS for CCSDEV VPC"
  vpc_id     = "${aws_vpc.CCSDEV-Services.id}"
  vpc_region = "eu-west-2"

  tags {
    Name = "Internal DNS for CCSDEV VPC"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_route53_zone" "ccsdev-internal-org-public" {
  count      = "${var.enable_https}"
  name       = "${var.domain_internal_prefix}.${var.domain_name}"
  comment    = "Public DNS for CCSDEV VPC"
  vpc_region = "eu-west-2"

  tags {
    Name = "Public DNS for CCSDEV VPC"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
 }
}

resource "aws_route53_record" "ccsdev-internal-org-public-ns" {
  count   = "${var.enable_https}"
  zone_id = "${data.aws_route53_zone.public_cluster_https_domain.zone_id}"
  name    = "${var.domain_internal_prefix}.${var.domain_name}"
  type    = "NS"
  ttl     = "60"

  records = [
    "${aws_route53_zone.ccsdev-internal-org-public.name_servers.0}",
    "${aws_route53_zone.ccsdev-internal-org-public.name_servers.1}",
    "${aws_route53_zone.ccsdev-internal-org-public.name_servers.2}",
    "${aws_route53_zone.ccsdev-internal-org-public.name_servers.3}",
  ]
}