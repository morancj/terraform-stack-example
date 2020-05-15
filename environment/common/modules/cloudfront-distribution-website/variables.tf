// This should be a list after the Terraform 0.12 upgrade
variable "environment" {
  type        = string
  default     = "staging"
  description = "Generally either `staging` or `production`."
}

// Comment can be derived from environment using Terraform < 0.12
# variable "comment" {
#   type = list(string)
# }

// This could be a map after the Terraform 0.12 upgrade
variable "aliases" {
  # type = map
  type        = list(string)
  description = "Alternate names this CloudFront Web Distribution should serve."
}

variable "domain_name" {}

// This should be a list after the Terraform 0.12 upgrade
variable "origin_domain_name" {
  type        = string
  description = "Generally this will be the relevant S3 bucket's regional website endpoint DNS name."
}

variable "s3_bucket_log_bucket" {
  description = "Which bucket should be used for receiving logs"
}

// We'll need to use a `map` here if we manage Lambda associations through
// Terraform.
variable "lambda_arn" {
  // account_one Account
  default     = "arn:aws:lambda:us-east-1:ACCOUNTID_one:function:cloudfront-add-security-headers:1"
  description = "ARN of the lamba function modifying response headers."
}

variable "acm_arn" {
  description = "ARN of the Amazon Certificate Manager certificate for this Web Distribution."
}
