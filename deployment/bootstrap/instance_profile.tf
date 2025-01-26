data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_instance_profile" "nginx_access_profile" {
  name = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
  role = aws_iam_role.nginx_access_role.name
}

resource "aws_iam_role" "nginx_access_role" {
  name               = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy" "nginx_access_policy" {
  name   = "${var.app_name}.${var.vpc_name}.${var.cluster}.${var.domain}"
  role   = aws_iam_role.nginx_access_role.name
  policy = file("${path.module}/templates/iam_role_policy")
}
