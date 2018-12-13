##############################################################
# Name of the created CodeBuild project
##############################################################

output "build_project_name" {
  value = "${aws_codebuild_project.build_project.name}"
}

