##############################################################
#
# Application Configuration and Support
#
# Defines:
#   Application requirements
#
##############################################################

##############################################################
# Container Repository
##############################################################
resource "aws_ecr_repository" "app" {
  name = "ccs/app"
}

##############################################################
# Policies
##############################################################
data "aws_iam_policy_document" "codebuild_app_service_role_assume_policy" {
  statement {
    principals = {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "codebuild_app_service_role" {
  name                = "codebuild-app-service-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.codebuild_app_service_role_assume_policy.json}"
}

data "aws_iam_policy_document" "codebuild_app_service_policy" {
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
}

resource "aws_iam_role_policy" "codebuild_app_service_role_policy" {
  role = "${aws_iam_role.codebuild_app_service_role.name}"
  name = "codebuild_app_service_role_policy"
  policy = "${data.aws_iam_policy_document.codebuild_app_service_policy.json}"
}

resource "aws_iam_role_policy_attachment" "codebuild_container_registry_permissions" {
  role = "${aws_iam_role.codebuild_app_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

##############################################################
# Codebuild Project
##############################################################
resource "aws_codebuild_project" "app" {
  name          = "app-build-project"
  description   = "app_codebuild_project"
  build_timeout = "60" # Default 60 minutes
  service_role  = "${aws_iam_role.codebuild_app_service_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      "name"  = "IMAGE_URI"
      "value" = "${aws_ecr_repository.app.repository_url}:latest"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/roweit/CCSExampleApp1.git"
    git_clone_depth = 1
    buildspec       = "${file("${path.module}/docker_buildspec.yml")}"
  }

  vpc_config {
    vpc_id = "${aws_vpc.CCSDEV-Services.id}"

    subnets = [
      "${aws_subnet.CCSDEV-AZ-a-Private-1.id}",
    ]

    security_group_ids = [
      "${aws_security_group.vpc-CCSDEV-internal-app.id}",
    ]
  }
}