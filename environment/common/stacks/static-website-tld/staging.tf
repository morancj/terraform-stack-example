// staging/development environment

// staging/development hosting
module "s3-bucket-website-staging" {
  providers = {
    aws = aws.static-website-account
  }

  source = "../../modules/s3-bucket-website"

  // This should be a list after the Terraform 0.12 upgrade
  environment = "staging"

  suffix = local.route53_zone_name_hyphenated

  // The logging target usually depends on the output of the S3 log bucket module.
  // Otherwise, provide the name of the bucket for logging. The log bucket must
  // have a suitable ACL!
  s3_bucket_log_bucket = var.s3_bucket_log_bucket
}

module "cloudfront-distribution-website-staging" {
  source = "../../modules/cloudfront-distribution-website"

  providers = {
    aws = aws.static-website-account
  }

  environment = "staging"

  // See e.g:
  // https://alexharv074.github.io/2019/05/12/adventures-in-the-terraform-dsl-part-i-structured-data.html#addressing-a-list-of-maps
  // https://www.terraform.io/docs/configuration-0-11/interpolation.html#conditionals
  // https://www.hashicorp.com/blog/terraform-0-12-conditional-operator-improvements/
  aliases = [
    "staging.${module.route53-zone.default["name_trimmed"]}",
  ]

  domain_name = module.route53-zone.default["name_trimmed"]

  # origin_domain_names = [
  #   "${module.s3-bucket-website-staging.default["website_endpoint"]}",
  # ]
  origin_domain_name = module.s3-bucket-website-staging.website_endpoint

  s3_bucket_log_bucket = module.s3-bucket-log-bucket.bucket_domain_name

  # lambda_arn = "${module.lambda-add-cloudfront-security-headers.function["qualified_arn"]}"
  lambda_arn = module.lambda-add-cloudfront-security-headers-staging.lambda_function["qualified_arn"]

  acm_arn = module.acm-staging.arn
}

module "lambda-add-cloudfront-security-headers-staging" {
  source = "../../modules/lambda-add-cloudfront-security-headers"

  suffix = "staging"

  providers = {
    aws.lambda-account = aws.acm-account
  }
}

module "acm-staging" {
  source = "../../../../../terraform-aws-acm-certificate"

  providers = {
    aws.acm_account     = aws.static-website-account
    aws.route53_account = aws.acm-account
  }

  domain_name = "staging.${module.route53-zone.default["name"]}"

  subject_alternative_names = []

  hosted_zone_id        = module.route53-zone.default["zone_id"]
  validation_record_ttl = "60"
}

module "route53-records-staging" {
  providers = {
    aws.route53-account = aws.route53-account
  }

  source = "../../modules/route53-alias-website"

  zone_id = module.route53-zone.default["zone_id"]
  name    = "staging.${module.route53-zone.default["name"]}"

  types = [
    "A",
    "AAAA",
  ]

  alias_name    = module.cloudfront-distribution-website-staging.domain_name
  alias_zone_id = module.cloudfront-distribution-website-staging.hosted_zone_id
}
