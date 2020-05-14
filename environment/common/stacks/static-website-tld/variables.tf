// AWS Accounts used. Passed from parent.
provider aws {
  alias = "static-website-account"
}

provider aws {
  alias = "route53-account"
}

provider aws {
  alias = "acm-account"
}

provider aws {
  alias = "lambda-account"
}

provider aws {
  alias = "iam-account"
}

provider aws {
  alias = "git-account"
}

variable "environments" {
  default = [
    "staging",
    "production",
  ]

  description = "Used primarily to identify resources. Must be a list."
}

variable "aws_route53_zone" {
  type        = map(string)
  description = "Name of Route53 Zone to create/update. Must contain at least populated values for `name` and `comment`."
}

variable "s3_bucket_log_bucket" {
  description = "S3 bucket for receiving access logs"
}

locals {
  route53_zone_name_hyphenated = replace(var.aws_route53_zone["name"], ".", "-")
  description                  = "Zone name, periods replaced with hyphens. Used for e.g. S3 bucket naming. Don't add a trailing period/dot (`.`) to the parent variable's `name`!"
}
