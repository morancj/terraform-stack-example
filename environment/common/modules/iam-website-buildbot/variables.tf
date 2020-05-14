variable "s3_buckets" {
  type        = list(string)
  description = "List of S3 website hosting buckets to which we will permit access."
}

variable "s3_paths" {
  type        = list(string)
  description = "List of S3 website hosting bucket objects to which we will permit access."
}

variable "iam_role_buildbot_arn" {
  type        = string
  default     = "arn:aws:iam:::role/CI_CD_Role"
  description = "ARN of the IAM Role for the website building bot."
}

variable "iam_role_buildbot_name" {
  type        = string
  default     = "buildbot"
  description = "Name of buildbot IAM role"
}
