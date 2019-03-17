

resource "aws_ssm_parameter" "domain_prefix" {
  name  = "/${var.environment_name}/config/domain_prefix"
  description  = "Infrastructure configured domain internal prefix"
  type  = "SecureString"
  value = "${var.domain_internal_prefix}"

  tags {
    Name = "Parameter Store: Infrastructure configured domain internal prefix"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "enable_https" {
  name  = "/${var.environment_name}/config/enable_https"
  description  = "Whether HTTPS should be enabled"
  type  = "SecureString"
  value = "${var.enable_https}"

  tags {
    Name = "Parameter Store: Whether HTTPS should be enabled"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

locals {
  computed_rds_host = "${var.default_db_name}.db.${var.domain_internal_prefix}.${var.domain_name}"
  rds_host = "${var.default_db_host == "" ? local.computed_rds_host : var.default_db_host}"
  rds_url = "jdbc:postgresql://${var.default_db_name}.db.${var.domain_internal_prefix}.${var.domain_name}:5432/${var.default_db_name}"
}

resource "aws_ssm_parameter" "config_rds_url" {
  name  = "/${var.environment_name}/config/rds_url"
  description  = "Infrastructure configured database URL"
  type  = "SecureString"
  value = "${var.create_default_rds_database ? local.rds_url : "_"}"

  tags {
    Name = "Parameter Store: Infrastructure configured database URL"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "config_rds_type" {
  name  = "/${var.environment_name}/config/rds_type"
  description  = "Infrastructure configured database type"
  type  = "SecureString"
  value = "${var.create_default_rds_database ? var.default_db_type : "_"}"

  tags {
    Name = "Parameter Store: Infrastructure configured database type"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "config_rds_host" {
  name  = "/${var.environment_name}/config/rds_host"
  description  = "Infrastructure configured database host"
  type  = "SecureString"
  value = "${var.create_default_rds_database ? local.rds_host : "_"}"

  tags {
    Name = "Parameter Store: Infrastructure configured database host"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "config_rds_port" {
  name  = "/${var.environment_name}/config/rds_port"
  description  = "Infrastructure configured database port"
  type  = "SecureString"
  value = "${var.create_default_rds_database ? var.default_db_port : "_"}"

  tags {
    Name = "Parameter Store: Infrastructure configured database port"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "config_rds_name" {
  name  = "/${var.environment_name}/config/rds_name"
  description  = "Infrastructure configured database name"
  type  = "SecureString"
  value = "${var.create_default_rds_database ? var.default_db_name : "_"}"

  tags {
    Name = "Parameter Store: Infrastructure configured database name"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "config_rds_username" {
  name  = "/${var.environment_name}/config/rds_username"
  description  = "Infrastructure configured database username"
  type  = "SecureString"
  value = "${var.create_default_rds_database ? var.default_db_username : "_"}"

  tags {
    Name = "Parameter Store: Infrastructure configured database username"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "config_rds_password" {
  name  = "/${var.environment_name}/config/rds_password"
  description  = "Infrastructure configured database password"
  type  = "SecureString"
  value = "${var.create_default_rds_database ? "postgres" : "_"}"

  tags {
    Name = "Parameter Store: Infrastructure configured database password"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

locals {
  es_is_enabled = "${var.create_elasticsearch_default_domain ? 1 : 0}"
  es_is_disabled = "${var.create_elasticsearch_default_domain ? 0 : 1}"
}



resource "aws_ssm_parameter" "config_es_endpoint_disabled" {
  count = "${local.es_is_disabled}"
  name  = "/${var.environment_name}/config/es_endpoint"
  description  = "Infrastructure configured elasticsearch endpoint - disabled"
  type  = "SecureString"
  value = "_"

  tags {
    Name = "Parameter Store: Infrastructure configured elasticsearch endpoint - disabled"
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}