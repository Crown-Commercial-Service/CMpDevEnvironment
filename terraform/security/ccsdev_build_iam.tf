##############################################################
#
# CCSDEV Build IAM Configuration
#
# This script defines CodeBuild/CodePipeline related IAM assets
#
#   Policies
#     codebuild_service_role_assume_policy
#     codebuild_service_policy
#     codebuild_api_service_role_policy
#     codebuild_app_service_role_policy
#     codepipeline_service_role_assume_policy
#     codepipeline_service_policy
#     codepipeline_api_service_role_policy
#     codepipeline_app_service_role_policy
#   Attachments
#     codebuild_api_container_registry_permissions
#     codebuild_app_container_registry_permissions
#     codepipeline_api_container_registry_permissions
#     codepipeline_app_container_registry_permissions
#   Roles
#     codebuild_api_service_role
#     codebuild_app_service_role
#     codepipeline_api_service_role
#     codepipeline_app_service_role
#
##############################################################
# CodeBuild Policies
##############################################################
data "aws_iam_policy_document" "codebuild_service_role_assume_policy" {
  statement {
    principals = {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "codebuild_service_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]

    resources = ["*"]
  }

  statement {
    actions = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
   ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameters",
      "ssm:GetParameter"
   ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_api_service_role_policy" {
  role = "${aws_iam_role.codebuild_api_service_role.name}"
  name = "codebuild_api_service_role_policy"
  policy = "${data.aws_iam_policy_document.codebuild_service_policy.json}"
}

resource "aws_iam_role_policy" "codebuild_app_service_role_policy" {
  role = "${aws_iam_role.codebuild_app_service_role.name}"
  name = "codebuild_app_service_role_policy"
  policy = "${data.aws_iam_policy_document.codebuild_service_policy.json}"
}
##############################################################
# CodeBuild Attachments
##############################################################
resource "aws_iam_role_policy_attachment" "codebuild_api_container_registry_permissions" {
  role = "${aws_iam_role.codebuild_api_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_app_container_registry_permissions" {
  role = "${aws_iam_role.codebuild_app_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

##############################################################
# CodeBuild Roles
##############################################################
resource "aws_iam_role" "codebuild_api_service_role" {
  name                = "codebuild-api-service-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.codebuild_service_role_assume_policy.json}"
}

resource "aws_iam_role" "codebuild_app_service_role" {
  name                = "codebuild-app-service-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.codebuild_service_role_assume_policy.json}"
}

##############################################################
# CodePipeline Policies
##############################################################
data "aws_iam_policy_document" "codepipeline_service_role_assume_policy" {
  statement {
    principals = {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com", "application-autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "codepipeline_service_policy" {
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
        "iam:PassRole"
    ]

    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["ecs-tasks.amazonaws.com"]
      variable = "iam:PassedToService"
    }
}


  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
   ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_api_service_role_policy" {
  role = "${aws_iam_role.codepipeline_api_service_role.name}"
  name = "codepipeline_api_service_role_policy"
  policy = "${data.aws_iam_policy_document.codepipeline_service_policy.json}"
}

resource "aws_iam_role_policy" "codepipeline_app_service_role_policy" {
  role = "${aws_iam_role.codepipeline_app_service_role.name}"
  name = "codepipeline_app_service_role_policy"
  policy = "${data.aws_iam_policy_document.codepipeline_service_policy.json}"
}

##############################################################
# CodePipeline Attachments
##############################################################
resource "aws_iam_role_policy_attachment" "codepipeline_api_container_registry_permissions" {
  role = "${aws_iam_role.codepipeline_api_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codepipeline_app_container_registry_permissions" {
  role = "${aws_iam_role.codepipeline_app_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codepipeline_api_ecs_autoscale_permissions" {
  role = "${aws_iam_role.codepipeline_api_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_role_policy_attachment" "codepipeline_app_ecs_autoscale_permissions" {
  role = "${aws_iam_role.codepipeline_app_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

##############################################################
# CodePipeline Roles
##############################################################
resource "aws_iam_role" "codepipeline_api_service_role" {
  name                = "codepipeline-api-service-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.codepipeline_service_role_assume_policy.json}"
}

resource "aws_iam_role" "codepipeline_app_service_role" {
  name                = "codepipeline-app-service-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.codepipeline_service_role_assume_policy.json}"
}
