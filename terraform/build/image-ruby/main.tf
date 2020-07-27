terraform {
  required_version = "~> 0.11"
}

module "image" {
  # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/image"
  source = "../../modules/image"
  
  prefix = "ccs"
  name = "ruby"
  github_owner = "Crown-Commercial-Service"
  github_repo = "CMpDevBuildImage_Ruby"
  github_branch = "master"
  github_token_alias = "ccs-build_github_token"
}
