// static website hosting
// Zone apex redirects to `www.`

// Common setup
module "route53-zone" {
  providers = {
    aws = aws.route53-account
  }

  source = "../../modules/route53-zone"

  // `environments` would always be `production`
  name    = var.aws_route53_zone["name"]
  comment = var.aws_route53_zone["comment"]
}

module "s3-bucket-log-bucket" {
  providers = {
    aws = aws.static-website-account
  }

  source = "../../modules/s3-bucket-log-bucket"

  // `environments` would always be `production`
  s3_bucket_log_bucket = var.s3_bucket_log_bucket
}

module "iam-website-buildbot" {
  providers = {
    aws = aws.static-website-account
  }

  source = "../../modules/iam-website-buildbot"

  iam_role_buildbot_name = "${replace(var.aws_route53_zone["name"], ".", "-")}-buildbot"
  iam_role_buildbot_arn  = var.IAM_ROLE_BUILDBOT_ARN

  s3_buckets = [
    module.s3-bucket-website-staging.arn,
    module.s3-bucket-website-production.arn,
  ]

  s3_paths = [
    "${module.s3-bucket-website-staging.arn}/*",
    "${module.s3-bucket-website-production.arn}/*",
  ]
}
