data "archive_file" "lambda" {
  type        = "zip"
  source_file = "main.js"
  output_path = "lambda.zip"
}

resource "aws_iam_role" "ccsdev-lambda-exec" {
  name = "ccsdev-lambda-exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ccsdev-pre-sign-up-lambda-policy" {
  name = "ccsdev-pre-sign-up-lambda-policy"
  role = "${aws_iam_role.ccsdev-lambda-exec.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "ccsdev-pre-sign-up-function" {
  filename = "${data.archive_file.lambda.output_path}"
  function_name = "ccsdev-pre-sign-up-function"
  role = "${aws_iam_role.ccsdev-lambda-exec.arn}"
  handler = "main.handler"
  runtime = "nodejs10.x"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda.output_path}"))}"
  publish = true
}
