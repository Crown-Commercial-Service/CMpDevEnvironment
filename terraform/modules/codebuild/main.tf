data "template_file" "buildspec_template_file" {
  template = "${file("${path.module}/${var.source_buildspec_filepath}")}"
}

resource "aws_codebuild_project" "terraform_plan_codebuild_project" {
  name         = "${var.codebuild_project_name}"
  service_role = "${var.codebuild_service_role}"

  artifacts {
    type = "${var.artifacts_type}"
  }

  environment {
    compute_type = "${var.environment_compute_type}"
    image        = "${var.environment_image}"
    type         = "${var.environment_type}"

    environment_variable {
      name = "BOOTSTRAP_DIR"
      value = "${var.bootstrap_directory}"
    }

    environment_variable {
      name = "BOOTSTRAP_TFPLAN"
      value = "${var.bootstrap_tfplan_filename}"
    }

    environment_variable {
      name = "INFRASTRUCTURE_DIR"
      value = "${var.infrastructure_directory}"
    }

    environment_variable {
      name = "INFRASTRUCTURE_TFPLAN"
      value = "${var.infrastructure_tfplan_filename}"
    }

    environment_variable {
      name = "BUILD_CMP_MAINTENANCE_DIR"
      value = "${var.build_cmp_maintenance_directory}"
    }

    environment_variable {
      name = "BUILD_CMP_MAINTENANCE_TFPLAN"
      value = "${var.build_cmp_maintenance_tfplan_filename}"
    }

    environment_variable {
      name = "BUILD_CROWN_MARKETPLACE_DIR"
      value = "${var.build_crown_marketplace_directory}"
    }

    environment_variable {
      name = "BUILD_CROWN_MARKETPLACE_TFPLAN"
      value = "${var.build_crown_marketplace_tfplan_filename}"
    }

    environment_variable {
      name = "BUILD_CROWN_MARKETPLACE_LEGACY_DIR"
      value = "${var.build_crown_marketplace_legacy_directory}"
    }

    environment_variable {
      name = "BUILD_CROWN_MARKETPLACE_LEGACY_TFPLAN"
      value = "${var.build_crown_marketplace_legacy_directory}"
    }

    environment_variable {
      name = "BUILD_CROWN_MARKETPLACE_SIDEKIQ_DIR"
      value = "${var.build_crown_marketplace_sidekiq_directory}"
    }

    environment_variable {
      name = "BUILD_CROWN_MARKETPLACE_SIDEKIQ_TFPLAN"
      value = "${var.build_crown_marketplace_sidekiq_directory}"
    }

    environment_variable {
      name = "BUILD_IMAGE_RUBY_DIR"
      value = "${var.build_image_ruby_directory}"
    }

    environment_variable {
      name = "BUILD_IMAGE_RUBY_TFPLAN"
      value = "${var.build_image_ruby_tfplan_filename}"
    }
  }

  source {
    type      = "${var.source_type}"
    buildspec = "${data.template_file.buildspec_template_file.rendered}"
  }
}
