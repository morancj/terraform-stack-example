data "aws_iam_policy_document" "default" {
  // This would work after the Terraform 0.12 upgrade
  # count     = "${length(var.environments)}"
  policy_id = "World-readable S3 bucket"

  statement {
    sid     = "1"
    actions = ["s3:GetObject"]

    resources = [
      # "arn:aws:s3:::${var.environments[count.index]}-${var.suffix}/*",
      "arn:aws:s3:::${var.environment}-${var.suffix}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "default" {
  # count  = "${length(var.environments)}"
  # bucket = "${var.environments[count.index]}-${var.suffix}"
  bucket = "${var.environment}-${var.suffix}"

  acl = "private"

  # policy = "${element(data.aws_iam_policy_document.json, count.index)}"
  # policy = "${element(data.aws_iam_policy_document.default.*.json, count.index)}"
  policy = data.aws_iam_policy_document.default.json

  logging {
    target_bucket = var.s3_bucket_log_bucket

    # target_prefix = "s3-logs/${var.environments[count.index]}-${var.suffix}/"
    target_prefix = "s3-logs/${var.environment}-${var.suffix}/"
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    # Name        = "${var.environments[count.index]}-${var.suffix}"
    # Environment = "${var.environments[count.index]}"
    Name = "${var.environment}-${var.suffix}"

    Environment = var.environment
  }
}
