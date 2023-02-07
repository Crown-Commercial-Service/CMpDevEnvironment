##############################################################
#
# CCSDEV ElastiCache Redis Service
#
# Defines:
#
##############################################################

resource "aws_elasticache_subnet_group" "ccsdev_elasticache_redis_subnets" {
  # Only create if create_elasticache_redis is true (1) 
  count = "${var.create_elasticache_redis}"

  name        = "ccsdev-elasticache-redis-subnets"
  description = "Access to CCSDEV ElasticCache Redis from public, private and management subnets"
  subnet_ids  = ["${aws_subnet.CCSDEV-AZ-a-Public-1.id}", "${aws_subnet.CCSDEV-AZ-b-Public-1.id}", "${aws_subnet.CCSDEV-AZ-c-Public-1.id}", "${aws_subnet.CCSDEV-AZ-a-Private-1.id}", "${aws_subnet.CCSDEV-AZ-b-Private-1.id}", "${aws_subnet.CCSDEV-AZ-c-Private-1.id}", "${aws_subnet.CCSDEV-AZ-a-Management.id}", "${aws_subnet.CCSDEV-AZ-b-Management.id}", "${aws_subnet.CCSDEV-AZ-c-Management.id}"]
}

resource "aws_elasticache_parameter_group" "ccsdev_elasticache_redis_parameters" {
  name   = "ccsdev-elasticache-redis-parameters-7"
  family = "redis7"
}

resource "aws_elasticache_cluster" "ccsdev_elasticache_redis" {
  # Only create if create_elasticache_redis is true (1) 
  count = "${var.create_elasticache_redis}"

  cluster_id           = "ccsdev-redis"
  engine               = "redis"
  node_type            = "${var.elasticache_instance_class}"
  num_cache_nodes      = 1
  engine_version       = "7.0.5"
  parameter_group_name = "${aws_elasticache_parameter_group.ccsdev_elasticache_redis_parameters.id}"
  port                 = "${var.redis_port}"
  maintenance_window   = "sat:04:03-sat:05:03"

  subnet_group_name  = "${aws_elasticache_subnet_group.ccsdev_elasticache_redis_subnets.id}"
  security_group_ids = ["${aws_security_group.vpc-CCSDEV-internal-EC-REDIS.id}"]

  tags {
    Name           = "CCSDEV ElasticCache Redis instance"
    CCSRole        = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

##############################################################
# Private VPC DNS zone CNAME to map to Redis
#
##############################################################

resource "aws_route53_record" "CCSDEV-internal-redis-CNAME" {
  # Only create if create_elasticache_redis is true (1) 
  count = "${var.create_elasticache_redis}"

  zone_id = "${aws_route53_zone.ccsdev-internal-org-private.zone_id}"
  name    = "redis"
  type    = "CNAME"
  records = ["${aws_elasticache_cluster.ccsdev_elasticache_redis.cache_nodes.0.address}"]
  ttl     = "300"
}
