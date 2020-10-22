resource "aws_iam_role" "cmp_terraform_codepipeline_role" {
  name = var.iam_role_name

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

resource "aws_iam_role_policy_attachment" "cmp_terraform_codepipeline_dynamodb_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = var.iam_role_name
}

resource "aws_iam_role_policy_attachment" "cmp_terraform_codepipeline_s3_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = var.iam_role_name
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

resource "aws_iam_policy_attachment" "codepipeline_cmp_policy_attachment" {
  name        = "codepipeline_cmp_policy_attachment"
  policy_arn  = aws_iam_policy.codepipeline_cmp_policy.arn
  roles       = [aws_iam_role.cmp_terraform_codepipeline_role.name]
}
