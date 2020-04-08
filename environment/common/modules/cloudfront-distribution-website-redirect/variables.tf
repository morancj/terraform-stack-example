// This should be a list after the Terraform 0.12 upgrade
variable "environment" {
  type    = "string"
  default = "redirect"
}

// Comment can be derived from environment, but can't because
# // we're using Terraform < 0.12
# variable "comment" {
#   type = "list"
# }

// This could be a map after the Terraform 0.12 upgrade
variable "aliases" {
  # type = "map"
  type        = "list"
  description = "Alternate names this CloudFront Web Distribution should serve."
}

variable "domain_name" {
  description = "FQDN of this CloudFront Web Distribution."
}

// This should be a list after the Terraform 0.12 upgrade
variable "origin_domain_name" {
  type        = "string"
  description = "Generally this will be the relevant S3 bucket's regional website endpoint DNS name."
}

variable "s3_bucket_log_bucket" {
  description = "Which bucket should be used for receiving logs"
}

variable "acm_arn" {
  description = "ARN of the Amazon Certificate Manager certificate for this Web Distribution."
}
