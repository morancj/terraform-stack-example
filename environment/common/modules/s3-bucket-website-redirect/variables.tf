variable "suffix" {
  description = "Used to identify build environments. Could be determined from `environment` if the modules were reworked (requires Terraform ≥ 0.12 for clear code)."
}

variable "route53_zone" {
  description = "Route53 Zone in which the target resides."
}

variable "s3_bucket_log_bucket" {
  description = "S3 bucket for receiving access logs"
}
