output "project_name" {
  value = "${aws_codebuild_project.project.name}"
}

output "image_name" {
  value = "${local.image_name}"
}