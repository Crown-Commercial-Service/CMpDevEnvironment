provider "aws" {
  region     = "${var.region}"
}

##############################################################
#
# CCSDEV IAM Configuration
#
# This script defines user/group related IAM assets
#
#   Polices
#     CCSDEV_policy_limited_user
#   Roles
#   Groups
#     CCS_System_Administration
#     CCS_Infrastructure_Administration
#     CCS_Application_Developer
#     CCS_API_Developer
#     CCS_User_Administration
#     CCS_Code_Build_Pipeline
#     CCS_Cognito_Administration
#     CCS_Terraform_Execution
#     CCS_Developer_API_Access
#
#   Users?
#
##############################################################

##############################################################
# Need Access to the current AWS account ID
##############################################################
data "aws_caller_identity" "current" {

}

##############################################################
# system Administration Group
#
# Users in this group are 'superusers' with full access to all
# AWS assets.
#
#   AWSCertificateManagerFullAccess
#   AmazonS3FullAccess
#   AmazonSSMFullAccess
#   AmazonRDSFullAccess
#   AmazonESFullAccess
#   AmazonElastiCacheFullAccess
#   KMS Full access - custom policy
##############################################################

resource "aws_iam_group" "CCSDEV_iam_sys_admin" {
  name = "CCS_System_Administration"
}

resource "aws_iam_group_membership" "sys_admin" {
  name = "tf-testing-group-membership"
  users = ["${basename(data.aws_caller_identity.current.arn)}"]
  group = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
}

resource "aws_iam_group_policy_attachment" "sys_admin_cert_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

resource "aws_iam_group_policy_attachment" "sys_admin_s3_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "sys_ssm_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_group_policy_attachment" "sys_admin_kms_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_kms_full.arn}"
}

resource "aws_iam_group_policy_attachment" "sys_admin_rds_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_group_policy_attachment" "sys_admin_es_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

resource "aws_iam_group_policy_attachment" "sys_admin_cache_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
}

resource "aws_iam_policy" "CCSDEV_policy_kms_full" {
  name   = "CCSDEV_policy_kms_full"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_policy_doc_kms_full.json}"
}

data "aws_iam_policy_document" "CCSDEV_policy_doc_kms_full" {

  statement {

    effect = "Allow",
    actions = [
                "kms:*",
                "iam:ListGroups",
                "iam:ListRoles",
                "iam:ListUsers"
    ]

    resources = [
		"*"
    ]
  }

}

##############################################################
# Infrastructure Administration Group
#
# Users in this group are able to access and modify many
# of the AWS assets.
#
# They will not be able to trigger App or Api builds or
# modify user (IAM) related information.
#
#   AmazonVPCFullAccess
#   AmazonRoute53FullAccess
#   AmazonEC2FullAccess
#   AmazonEC2ContainerRegistryFullAccess
#   AmazonECS_FullAccess
#   service-role/AWSConfigRole
#   CloudWatchLogsFullAccess
#   Various custom policy settings
#
##############################################################

resource "aws_iam_group" "CCSDEV_iam_infra_admin" {
  name = "CCS_Infrastructure_Administration"
}

resource "aws_iam_group_membership" "infra_admin" {
  name = "tf-testing-group-membership"
  users = ["${basename(data.aws_caller_identity.current.arn)}"]
  group = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
}

resource "aws_iam_group_policy_attachment" "infra_admin_vpc_full" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_group_policy_attachment" "infra_admin_route53_full" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "infra_admin_ec2_full" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "infra_admin_ecr_full" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_group_policy_attachment" "infra_admin_ecs_full" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_group_policy_attachment" "infra_admin_aws_config" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_group_policy_attachment" "infra_admin_logs_full" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_group_policy_attachment" "infra_admin_custom" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_infra_custom.arn}"
}

resource "aws_iam_policy" "CCSDEV_policy_infra_custom" {
  name   = "CCSDEV_policy_infra_custom"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_policy_doc_infra_custom.json}"
}

data "aws_iam_policy_document" "CCSDEV_policy_doc_infra_custom" {

  # GetInstanceProfile for cluster updates
  statement {

    effect = "Allow",
    actions = [
                "iam:GetInstanceProfile"
    ]

    resources = [
		"arn:aws:iam::*:instance-profile/*"
    ]
  }

  # SNS Topic creation for alarams
  statement {

    actions = [
        "sns:CreateTopic",
        "events:*"
    ]

    resources = [
		"*"
    ]
  }


}


##############################################################
# KMS Policy to allow access for developers to Parameter Store
##############################################################

resource "aws_iam_policy" "CCSDEV_policy_kms_dev" {
  name   = "CCSDEV_policy_kms_dev"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_policy_doc_kms_dev.json}"
}

data "aws_iam_policy_document" "CCSDEV_policy_doc_kms_dev" {

  statement {
    effect = "Allow",
    actions = ["kms:ListAliases"]
    resources = ["*"]
  }
}

##############################################################
# Application Developer Group
#
# Users in the group have limited access to the ECS system
# and build tools to allow then to develop front end
# applications deployed into the App cluster. They have no
# direct access to RDS resources.
#
#   AmazonEC2ReadOnlyAccess
#   AmazonEC2ContainerRegistryPowerUser
#   AmazonECS_FullAccess
#   CloudWatchReadOnlyAccess
#   AmazonSSMFullAccess
#   AmazonElastiCacheReadOnlyAccess
#   SNS Topic subscription (custom)
#
# TODO At present access NOT restricted to the app cluster
#
##############################################################

resource "aws_iam_group" "CCSDEV_iam_app_dev" {
  name = "CCS_Application_Developer"
}

resource "aws_iam_group_membership" "app_dev" {
  name = "tf-testing-group-membership"
  users = ["${basename(data.aws_caller_identity.current.arn)}"]
  group = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
}

resource "aws_iam_group_policy_attachment" "app_dev_ec2_readonly" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "app_dev_ecr_power" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_group_policy_attachment" "app_dev_ecs_full" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_group_policy_attachment" "app_dev_logs_readonly" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "app_dev_ssm_full" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_group_policy_attachment" "app_dev_elasticache_readonly" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "app_dev_kms_dev" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_kms_dev.arn}"
}

resource "aws_iam_group_policy_attachment" "app_dev_topic_subscription" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_topic_subscription.arn}"
}

##############################################################
# API Developer Group
#
# Users in the group have limited access to the ECS system
# and build tools to allow then to develop API services
# deployed into the Api cluster. They have will also
# have direct access to RDS resources.
#
#   AmazonEC2ReadOnlyAccess
#   AmazonEC2ContainerRegistryPowerUser
#   AmazonECS_FullAccess
#   AmazonRDSFullAccess
#   AmazonElastiCacheReadOnlyAccess
#   AmazonESFullAccess
#   CloudWatchReadOnlyAccess
#   AmazonSSMFullAccess
#   SNS Topic subscription (custom)
#
# TODO At present access NOT restricted to the api cluster
#
##############################################################

resource "aws_iam_group" "CCSDEV_iam_api_dev" {
  name = "CCS_API_Developer"
}

resource "aws_iam_group_membership" "api_dev" {
  name = "tf-testing-group-membership"
  users = ["${basename(data.aws_caller_identity.current.arn)}"]
  group = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
}

resource "aws_iam_group_policy_attachment" "api_dev_ec2_readonly" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_ecr_power" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_group_policy_attachment" "api_dev_ecs_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_rds_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}
resource "aws_iam_group_policy_attachment" "api_dev_es_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_logs_readonly" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_ssm_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_elasticache_readonly" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_kms_dev" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_kms_dev.arn}"
}

resource "aws_iam_group_policy_attachment" "api_dev_topic_subscription" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_topic_subscription.arn}"
}



##############################################################
# Developer API Access Group
#
# Users in the group have access to specific AWS resources
# via an access key.
#
# No specific policies are attached. Individual resources
# will attach to this group.
#
# For example the Application/API S3 data bucket will attach
# a policy to this group to allow limited API access.
#
##############################################################

resource "aws_iam_group" "CCSDEV_iam_dev_api_access" {
  name = "CCS_Developer_API_Access"
}


##############################################################
# CCS Code Build Pipeline Group
#
# Users in this group are able to define and adminstrate
# AWS CodeBuild and AWS CodePipeline Projects.
#
#   CodeBuildAdminAccess
#   CodePipelineFullAccess
#   SNS Topic Creation (custom)
##############################################################

resource "aws_iam_group" "CCSDEV_iam_code_build_pipeline" {
  name = "CCS_Code_Build_Pipeline"
}

resource "aws_iam_group_membership" "code_build_pipeline" {
  name = "tf-testing-group-membership"
  users = ["${basename(data.aws_caller_identity.current.arn)}"]
  group = "${aws_iam_group.CCSDEV_iam_code_build_pipeline.name}"
}

resource "aws_iam_group_policy_attachment" "code_build_admin" {
  group      = "${aws_iam_group.CCSDEV_iam_code_build_pipeline.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_group_policy_attachment" "code_pipeline_full" {
  group      = "${aws_iam_group.CCSDEV_iam_code_build_pipeline.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

resource "aws_iam_group_policy_attachment" "code_pipeline_notification" {
  group      = "${aws_iam_group.CCSDEV_iam_code_build_pipeline.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_pipeline_notification.arn}"
}

resource "aws_iam_policy" "CCSDEV_policy_pipeline_notification" {
  name   = "CCSDEV_policy_pipeline_notification"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_policy_doc_pipeline_notification.json}"
}

data "aws_iam_policy_document" "CCSDEV_policy_doc_pipeline_notification" {

  statement {

    actions = [
        "sns:CreateTopic",
        "events:*"
    ]

    resources = [
		"*"
    ]
  }

}


##############################################################
# CCS Cognito User Administration Group
#
# Users in this group are able to administer the Cognito
# service used to application users.
#
#   AmazonCognitoPowerUser
##############################################################

resource "aws_iam_group" "CCSDEV_iam_cognito_admin" {
  name = "CCS_Cognito_Administration"
}

resource "aws_iam_group_membership" "cognito_admin" {
  name = "tf-testing-group-membership"
  users = ["${basename(data.aws_caller_identity.current.arn)}"]
  group = "${aws_iam_group.CCSDEV_iam_cognito_admin.name}"
}

resource "aws_iam_group_policy_attachment" "cognito_admin" {
  group      = "${aws_iam_group.CCSDEV_iam_cognito_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}


##############################################################
# Users Administration Group
#
# Users in this group are able to define new users and add
# Then to the the correct groups.
# 
# This group includes a custom policy definition that
# restricts the user to accessing certain groups.
#
# Note:
# They will NOT be able to add users to the system
# administration group.
##############################################################

resource "aws_iam_group" "CCSDEV_iam_user_admin" {
  name = "CCS_User_Administration"
}

resource "aws_iam_group_membership" "iam_user_admin" {
  name = "tf-testing-group-membership"
  users = ["${basename(data.aws_caller_identity.current.arn)}"]
  group = "${aws_iam_group.CCSDEV_iam_user_admin.name}"
}

resource "aws_iam_group_policy_attachment" "user_admin_iam_limited" {
  group      = "${aws_iam_group.CCSDEV_iam_user_admin.name}"
  policy_arn = "${aws_iam_policy.CCSDEV_policy_limited_user.arn}"
}

resource "aws_iam_policy" "CCSDEV_policy_limited_user" {
  name   = "CCSDEV_policy_limited_user"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_policy_doc_limited_user.json}"
}
data "aws_iam_policy_document" "CCSDEV_policy_doc_limited_user" {

  statement {

    actions = [
        "iam:GenerateCredentialReport",
        "iam:GenerateServiceLastAccessedDetails",
        "iam:List*",
        "iam:GetAccountSummary"
    ]

    resources = [
		"*"
    ]
  }

  statement {

    actions = [
        "iam:GetUser",
        "iam:CreateUser",
        "iam:UpdateUser",
        "iam:DeleteUser",
        "iam:GetGroup",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup",
        "iam:ChangePassword",
        "iam:DeleteAccessKey",
        "iam:GetLoginProfile",
        "iam:CreateLoginProfile",
        "iam:DeleteLoginProfile",
        "iam:UpdateLoginProfile",
        "iam:GetAccessKeyLastUsed",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:UpdateAccessKey"        
    ]

    resources = [
		"arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*",
		"${aws_iam_group.CCSDEV_iam_infra_admin.arn}",
		"${aws_iam_group.CCSDEV_iam_app_dev.arn}",
		"${aws_iam_group.CCSDEV_iam_api_dev.arn}",
		"${aws_iam_group.CCSDEV_iam_code_build_pipeline.arn}",
		"${aws_iam_group.CCSDEV_iam_user_admin.arn}"
    ]
  }
}

resource "aws_iam_policy" "CCSDEV_policy_topic_subscription" {
  name   = "CCSDEV_policy_topic_subscription"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCSDEV_policy_doc_topic_subscription.json}"
}

data "aws_iam_policy_document" "CCSDEV_policy_doc_topic_subscription" {

  statement {

    actions = [
      "sns:Subscribe",
      "sns:Unsubscribe"
    ]

    resources = [
		"*"
    ]
  }

}

##############################################################
# Terraform Execution Group
#
# Users in this group are able to execute Terraform scripts
# These usrs require access to IAM, S3 and DynamoDB to be able to
# Execute the bootstrap process to accesss state information
#
#   AmazonS3FullAccess
#   AmazonDynamoDBFullAccess 
##############################################################

resource "aws_iam_group" "CCSDEV_iam_terraform_exec" {
  name = "CCS_Terraform_Execution"
}

resource "aws_iam_group_policy_attachment" "terraform_exec_s3_full" {
  group      = "${aws_iam_group.CCSDEV_iam_terraform_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "terraform_exec_dynamodb_full" {
  group      = "${aws_iam_group.CCSDEV_iam_terraform_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


##############################################################
# IAM role task for container instances
# Note that other scripts will add policies to this role
# to grant access as required.
##############################################################

resource "aws_iam_role" "CCSDEV_task_role" {
  name               = "CCSDEV-task-role"
  description        = "Role for application/api container tasks"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.CCSDEV_task_role_policy.json}"

}

data "aws_iam_policy_document" "CCSDEV_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

