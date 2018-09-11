##############################################################
#
# Application Configuration and Support
#
# Defines:
#   Application requirements
#
##############################################################
# Container Repository
##############################################################
resource "aws_ecr_repository" "app" {
  name = "${var.app_prefix}/${var.app_name}"
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

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
   ]

    resources = [
        "${data.aws_s3_bucket.build-artifacts.arn}",
        "${data.aws_s3_bucket.build-artifacts.arn}/*",
        "arn:aws:s3:::codepipeline*"
        ]
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
data "template_file" "buildspec" {
  template = "${file("${"${path.module}/docker_buildspec.yml"}")}"

  vars {
    container_prefix = "${var.app_prefix}"
    container_name = "${var.app_name}"
    image_name = "${aws_ecr_repository.app.repository_url}:latest"
  }
}

resource "aws_codebuild_project" "app" {
  name          = "${var.app_name}-build-project"
  description   = "${var.app_name}_codebuild_project"
  build_timeout = "60" # Default 60 minutes
  service_role  = "${aws_iam_role.codebuild_app_service_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "${data.template_file.buildspec.rendered}"
  }

  vpc_config {
    vpc_id = "${data.aws_vpc.CCSDEV-Services.id}"

    subnets = [
      "${data.aws_subnet.CCSDEV-AZ-a-Private-1.id}",
    ]

    security_group_ids = [
      "${data.aws_security_group.vpc-CCSDEV-internal-app.id}",
    ]
  }
}