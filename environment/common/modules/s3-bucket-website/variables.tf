// This should be a list after the Terraform 0.12 upgrade
variable "environment" {
  type = "string"

  default     = "staging"
  description = "Used primarily to identify resources."
}

variable "suffix" {
  description = "Used to identify build environments. Could be determined from `environment` if the modules were reworked (requires Terraform ≥ 0.12 for clear code)."
}

variable "s3_bucket_log_bucket" {
  default     = "logs-example-org"
  description = "S3 bucket for receiving access logs"
}
