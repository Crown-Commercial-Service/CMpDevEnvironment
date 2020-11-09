resource "aws_iam_role" "cmp_terraform_codebuild_role" {
  name = "${var.codebuild_iam_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cmp_terraform_codepipeline_role" {
  name = "${var.codepipeline_iam_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cmp_terraform_codebuild_admin_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = "${var.codebuild_iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "cmp_terraform_codebuild_dynamodb_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "${var.codebuild_iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "cmp_terraform_codebuild_s3_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${var.codebuild_iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "cmp_terraform_codepipeline_s3_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${var.codepipeline_iam_role_name}"
}

resource "aws_iam_policy" "codebuild_cmp_policy" {
  name   = "codebuild-cmp-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codebuild:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:eu-west-2:538094434428:log-group:/aws/codebuild/cmp-terraform-plan",
        "arn:aws:logs:eu-west-2:538094434428:log-group:/aws/codebuild/cmp-terraform-plan:*"
      ]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:GetObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "route53:ListHostedZones"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
  }
  EOF
}

resource "aws_iam_policy" "codepipeline_cmp_policy" {
  name   = "codepipeline-cmp-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:GetObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "codebuild_cmp_policy_attachment" {
  name        = "codebuild_cmp_policy_attachment"
  policy_arn  = "${aws_iam_policy.codepipeline_cmp_policy.arn}"
  roles       = ["${aws_iam_role.cmp_terraform_codepipeline_role.name}"]
}

resource "aws_iam_policy_attachment" "codepipeline_cmp_policy_attachment" {
  name        = "codepipeline_cmp_policy_attachment"
  policy_arn  = "${aws_iam_policy.codebuild_cmp_policy.arn}"
  roles       = ["${aws_iam_role.cmp_terraform_codebuild_role.name}"]
}
