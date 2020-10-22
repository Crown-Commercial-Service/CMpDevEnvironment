data "template_file" "buildspec_template_file" {
  template = file("${path.module}/${var.source_buildspec_filepath}")
}

resource "aws_codebuild_project" "terraform_plan_codebuild_project" {
  name         = var.codebuild_project_name
  service_role = var.codebuild_service_role

  artifacts {
    type = var.artifacts_type
  }

  environment {
    compute_type = var.environment_compute_type
    image        = var.environment_image
    type         = var.environment_type

    environment_variable {
      name = "BOOTSTRAP_DIR"
      value = var.bootstrap_directory
    }

    environment_variable {
      name = "BOOTSTRAP_TFPLAN"
      value = var.bootstrap_tfplan_filename
    }
  }

  source {
    type      = var.source_type
    buildspec = data.template_file.buildspec_template_file.rendered
  }
}