resource "aws_ssm_parameter" "domain_name" {
  name  = "/${var.environment_name}/config/domain_name"
  description  = "Infrastructure configured domain name"
  type  = "SecureString"
  value = "${var.domain_name}"

  tags {
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}

resource "aws_ssm_parameter" "domain_prefix" {
  name  = "/${var.environment_name}/config/domain_prefix"
  description  = "Infrastructure configured domain internal prefix"
  type  = "SecureString"
  value = "${var.domain_internal_prefix}"

  tags {
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
    CCSRole = "Infrastructure"
    CCSEnvironment = "${var.environment_name}"
  }
}