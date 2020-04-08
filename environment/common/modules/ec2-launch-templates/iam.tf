// Trust Relationship document
data "aws_iam_policy_document" "default" {
  // Allow EC2 to assume instance role
  statement {
    sid     = "EC2AssumeRolePolicy"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

// CRUD Role for EC2 Launch Template
resource "aws_iam_role" "default" {
  name               = "ec2-template-role"
  description        = "For use with EC2 Launch Templates, grants access via SSM"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

// Attach AWS default SSM management policy
resource "aws_iam_role_policy_attachment" "AmazonSSMRoleForInstancesQuickSetup" {
  role = "${aws_iam_role.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "default" {
  name = "${aws_iam_role.default.name}"
  role = "${aws_iam_role.default.name}"
}
