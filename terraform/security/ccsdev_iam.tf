provider "aws" {
  region     = "${var.region}"
}

##############################################################
#
# CCSDEV IAM Configuration
#
# This script defines user related IAM assets
#
#   Polices
#   Roles
#   Groups
#     CCS_System_Administration
#     CCS_Infrastructure_Administration
#     CCS_Application_Developer
#     CCS_API_Developer
#     CCS_User_Administration
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
#   IAMFullAccess
#   AWSCertificateManagerFullAccess
#   AmazonS3FullAccess
##############################################################

resource "aws_iam_group" "CCSDEV_iam_sys_admin" {
  name = "CCS_System_Administration"
}

resource "aws_iam_group_policy_attachment" "sys_admin_iam_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "sys_admin_cert_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}
resource "aws_iam_group_policy_attachment" "sys_admin_s3_full" {
  group      = "${aws_iam_group.CCSDEV_iam_sys_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
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
#   AmazonRDSFullAccess
#
##############################################################

resource "aws_iam_group" "CCSDEV_iam_infra_admin" {
  name = "CCS_Infrastructure_Administration"
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

resource "aws_iam_group_policy_attachment" "infra_admin_rds_full" {
  group      = "${aws_iam_group.CCSDEV_iam_infra_admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

##############################################################
# Application Developer Group
#
# Users in the group have limited access to the ECS system
# and build tools to allow then to develop front end
# applications deployed into the App cluster. They have no
# direct access to RDS resources.
#
#   AmazonEC2FullAccess
#   AmazonEC2ContainerRegistryFullAccess
#   AmazonECS_FullAccess
#
##############################################################

resource "aws_iam_group" "CCSDEV_iam_app_dev" {
  name = "CCS_Application_Developer"
}

resource "aws_iam_group_policy_attachment" "app_dev_ec2_full" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "app_dev_ecr_full" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_group_policy_attachment" "app_dev_ecs_full" {
  group      = "${aws_iam_group.CCSDEV_iam_app_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}


##############################################################
# API Developer Group
#
# Users in the group have limited access to the ECS system
# and build tools to allow then to develop API services
# deployed into the Api cluster. They have will also
# have direct access to RDS resources.
#
#   AmazonEC2FullAccess
#   AmazonEC2ContainerRegistryFullAccess
#   AmazonECS_FullAccess
#   AmazonRDSFullAccess
#
##############################################################

resource "aws_iam_group" "CCSDEV_iam_api_dev" {
  name = "CCS_API_Developer"
}

resource "aws_iam_group_policy_attachment" "api_dev_ec2_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_ecr_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_ecs_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_group_policy_attachment" "api_dev_rds_full" {
  group      = "${aws_iam_group.CCSDEV_iam_api_dev.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

##############################################################
# Users Administration Group
#
# Users in this group are able to define new users and add
# Then to the the correct groups.
#
# Note:
# They will NOT be able to add users to the system
# administration group.
##############################################################

resource "aws_iam_group" "CCSDEV_iam_user_admin" {
  name = "CCS_User_Administration"
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
		"${aws_iam_group.CCSDEV_iam_user_admin.arn}"
    ]
  }
}
