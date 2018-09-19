##############################################################
# Name of the created CodeBuild project
##############################################################
output "project_name" {
  value = "${aws_codebuild_project.project.name}"
}

##############################################################
# Fully Qualified ECS Image Repository URL
##############################################################
output "image_name" {
  value = "${local.deploy_image_name}"
}