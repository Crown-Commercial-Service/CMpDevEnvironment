###############################################################################
# This build pipeline to monitor the marketplace date repository and 
# when changes are commited upload the latest supply teachers data.
#
# Note that is is triggering on ANY change in the data repository, in the future
# either different repositories or different branches may be needed.
###############################################################################
terraform {
  required_version = "~> 0.11"
}

module "upload" {
  # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/image"
  source = "../../modules/upload"

  environment_name = "Sandbox"

  prefix = "ccs"
  name = "upload-supply-teacher"
  github_owner = "Crown-Commercial-Service"
  github_repo = "crown-marketplace-data"
  github_branch = "master"
  github_token_alias = "ccs-build_github_token"

  # Upload the standard data file to cmpupload API for supply teachers
  upload_api = "cmpupload"
  framework = "supply-teachers"
  data_file = "anonymous.json"
}


