// This bucket only exists for Zone apex redirection:
// it doesn't need a bucket policy.

// Config for website (S3 & CloudFront) zone apex → www. redirection.
resource "aws_s3_bucket" "default" {
  bucket = "redirect-${var.suffix}"
  acl    = "private"

  logging {
    target_bucket = var.s3_bucket_log_bucket
    target_prefix = "s3-logs/redirect-${var.suffix}/"
  }

  website {
    redirect_all_requests_to = "https://www.${var.route53_zone}"
  }

  tags = {
    Name        = "redirect-${var.suffix}"
    Environment = "production"
  }
}
