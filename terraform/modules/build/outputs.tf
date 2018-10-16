##############################################################
# Name of the created CodeBuild project
##############################################################
output "build_test_project_name" {
  value = "${join(" ", aws_codebuild_project.build_test_project.*.name)}"
}

output "deploy_test_project_name" {
  value = "${join(" ", aws_codebuild_project.deploy_test_project.*.name)}"
}

output "build_project_name" {
  value = "${aws_codebuild_project.build_project.name}"
}

##############################################################
# Fully Qualified ECS Image Repository URL
##############################################################
output "image_name" {
  value = "${local.deploy_image_name}"
}