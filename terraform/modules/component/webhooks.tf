provider "github" {
  token        = "${data.aws_ssm_parameter.github_token.value}"
  organization = "${var.github_owner}"
}

data "aws_ssm_parameter" "github_token" {
  name  = "${var.github_token_alias}"
}

resource "random_string" "webhook_secret" {
  length = 30
  special = false
  number = true
  lower = true
  upper = true
}

resource "aws_codepipeline_webhook" "current" {
    name            = "${var.name}-webhook" 
    authentication  = "GITHUB_HMAC" 
    target_action   = "Source"
    target_pipeline = "${var.name}-pipeline"

    authentication_configuration {
      secret_token = "${random_string.webhook_secret.result}"
    }

    filter {
      json_path    = "$.ref"
      match_equals = "refs/heads/{Branch}"
    }
}

resource "github_repository_webhook" "current" {
  repository = "${var.github_repo}"

  name = "web"

  configuration {
    url          = "${aws_codepipeline_webhook.current.url}"
    content_type = "form"
    insecure_ssl = true 
    secret       = "${random_string.webhook_secret.result}"
  }
  events = ["push"]
}