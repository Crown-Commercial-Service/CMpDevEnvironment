######################################
# Supply Teachers
######################################
module "component-st" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"
    environment_name = "Sandbox"
    type = "app"
    prefix = "ccs"
    name = "st"
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "master"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 2
    enable_tests = true
    enable_cognito_support = true
    cognito_login_callback = "auth/cognito/callback"
    cognito_logout_callback = "supply-teachers/gateway"
    environment = [
      {
        name = "RAILS_ENV",
        value = "production"
      },
      {
        name = "RAILS_SERVE_STATIC_FILES",
        value = "true"
      },
      {
        # Set to enable the ability to upload data
        name = "APP_HAS_UPLOAD_PRIVILEGES",
        value = "true"
      }
    ]
    port = "80"
}

######################################
# Facilities Management
######################################
module "component-fm" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"
    environment_name = "Sandbox"
    type = "app"
    prefix = "ccs"
    name = "fm"
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "sandbox"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 2
    enable_tests = true
    enable_cognito_support = true
    cognito_login_callback = "auth/cognito/callback"
    cognito_logout_callback = "facilities-management/gateway"
    environment = [
      {
        name = "RAILS_ENV",
        value = "production"
      },
      {
        name = "RAILS_SERVE_STATIC_FILES",
        value = "true"
      },
      {
        # Set to enable the ability to upload data
        name = "APP_HAS_UPLOAD_PRIVILEGES",
        value = "true"
      }
    ]
    port = "80"
}

######################################
# Management Consultancy
######################################
module "component-mc" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"
    environment_name = "Sandbox"
    type = "app"
    prefix = "ccs"
    name = "mc"
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "master"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 2
    enable_tests = true
    enable_cognito_support = true
    cognito_login_callback = "auth/cognito/callback"
    cognito_logout_callback = "management-consultancy/gateway"
    environment = [
      {
        name = "RAILS_ENV",
        value = "production"
      },
      {
        name = "RAILS_SERVE_STATIC_FILES",
        value = "true"
      },
      {
        # Set to enable the ability to upload data
        name = "APP_HAS_UPLOAD_PRIVILEGES",
        value = "true"
      }
    ]
    port = "80"
}

######################################
# Apprenticeship Training
######################################
module "component-ats" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"
    environment_name = "Sandbox"
    type = "app"
    prefix = "ccs"
    name = "ats"
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "apprenticeships"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 2
    enable_tests = true
    enable_cognito_support = true
    cognito_login_callback = "auth/cognito/callback"
    cognito_logout_callback = "apprenticeship-training/gateway"
    environment = [
      {
        name = "RAILS_ENV",
        value = "production"
      },
      {
        name = "RAILS_SERVE_STATIC_FILES",
        value = "true"
      },
      {
        # Set to enable the ability to upload data
        name = "APP_HAS_UPLOAD_PRIVILEGES",
        value = "true"
      }
    ]
    port = "80"
}

######################################
# Legal Services
######################################
module "component-ls" {
    # source = "git::https://github.com/Crown-Commercial-Service/CMpDevEnvironment.git//terraform/modules/component"
    source = "../../modules/component"
    environment_name = "Sandbox"
    type = "app"
    prefix = "ccs"
    name = "ls"
    build_type = "custom"
    build_image = "ccs/ruby"
    github_owner = "Crown-Commercial-Service"
    github_repo = "crown-marketplace"
    github_branch = "master"
    github_token_alias = "ccs-build_github_token"
    cluster_name = "CCSDEV_app_cluster"
    task_count = 2
    enable_tests = true
    enable_cognito_support = true
    cognito_login_callback = "auth/cognito/callback"
    cognito_logout_callback = "legal-services/gateway"
    environment = [
      {
        name = "RAILS_ENV",
        value = "production"
      },
      {
        name = "RAILS_SERVE_STATIC_FILES",
        value = "true"
      },
      {
        # Set to enable the ability to upload data
        name = "APP_HAS_UPLOAD_PRIVILEGES",
        value = "true"
      }
    ]
    port = "80"
}
