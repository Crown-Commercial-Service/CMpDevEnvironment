data "archive_file" "presignup-lambda" {
  type        = "zip"
  source_file = "presignup.js"
  output_path = "presignup-lambda.zip"
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
  filename = "${data.archive_file.presignup-lambda.output_path}"
  function_name = "ccsdev-pre-sign-up-function"
  role = "${aws_iam_role.ccsdev-lambda-exec.arn}"
  handler = "presignup.handler"
  runtime = "nodejs10.x"
  source_code_hash = "${base64sha256(file("${data.archive_file.presignup-lambda.output_path}"))}"
  publish = true
}

# Ensure the The Cognito user pool is allowed to invoke the function
resource "aws_lambda_permission" "ccsdev-pre-sign-up-permission" {
  statement_id  = "AllowPreSignUpAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ccsdev-pre-sign-up-function.function_name}"
  principal     = "cognito-idp.amazonaws.com"

  source_arn    = "${aws_cognito_user_pool.ccs_user_pool.arn}"
}