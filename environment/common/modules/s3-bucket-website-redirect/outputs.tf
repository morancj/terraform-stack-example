output "default" {
  value = {
    id                          = aws_s3_bucket.default.id
    bucket_domain_name          = aws_s3_bucket.default.bucket_domain_name
    bucket_regional_domain_name = aws_s3_bucket.default.bucket_regional_domain_name
    website_endpoint            = aws_s3_bucket.default.website_endpoint
  }
}

output "id" {
  value = aws_s3_bucket.default.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.default.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.default.bucket_regional_domain_name
}

output "website_endpoint" {
  value = aws_s3_bucket.default.website_endpoint
}
