data "aws_caller_identity" "current" {}

data "template_file" "backend_template" {
  template = "${file("${"${path.module}/backend.tpl"}")}"

  vars {
      bucket    = "${var.bucket}"
      component = "${var.component}"
      region    = "${var.region}"
  }
}

resource "local_file" "backend-tf" {
    content  = "${data.template_file.backend_template.rendered}"
    filename = "${var.path}/../${var.component}/backend.tf"
}