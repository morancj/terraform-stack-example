// Config for website (S3 & CloudFront) logging.
resource "aws_s3_bucket" "default" {
  bucket = var.s3_bucket_log_bucket
  acl    = "log-delivery-write"

  lifecycle_rule {
    id                                     = "90-day archive, 455-day cleanup"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 7

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 455
    }
  }

  tags = {
    Name        = var.s3_bucket_log_bucket
    Environment = "production"
  }
}
