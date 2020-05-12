// production/www/apex environment

// Zone apex to `www.` redirect
module "s3-bucket-website-redirect" {
  providers = {
    aws = aws.static-website-account
  }

  source = "../../modules/s3-bucket-website-redirect"

  // If you want a redirect, you must have a suitable target!
  route53_zone         = "${module.route53-zone.default["name_trimmed"]}"
  suffix               = "${local.route53_zone_name_hyphenated}"
  s3_bucket_log_bucket = "${module.s3-bucket-log-bucket.id}"
}

module "cloudfront-distribution-website-redirect" {
  source = "../../modules/cloudfront-distribution-website-redirect"

  providers = {
    aws = aws.static-website-account
  }

  environment = "redirect"

  // See e.g:
  // https://alexharv074.github.io/2019/05/12/adventures-in-the-terraform-dsl-part-i-structured-data.html#addressing-a-list-of-maps
  // https://www.terraform.io/docs/configuration-0-11/interpolation.html#conditionals
  // https://www.hashicorp.com/blog/terraform-0-12-conditional-operator-improvements/
  aliases = [
    "redirect.${module.route53-zone.default["name_trimmed"]}",
    "${module.route53-zone.default["name_trimmed"]}",
  ]

  domain_name = "${module.route53-zone.default["name_trimmed"]}"

  # origin_domain_names = [
  #   "${module.s3-bucket-website-redirect.default["website_endpoint"]}",
  # ]
  origin_domain_name = "${module.s3-bucket-website-redirect.website_endpoint}"

  s3_bucket_log_bucket = "${module.s3-bucket-log-bucket.bucket_domain_name}"

  acm_arn = "${module.acm-redirect.arn}"
}

module "acm-redirect" {
  source = "github.com/morancj/terraform-aws-acm-certificate?ref=0.1.2"

  providers = {
    aws.acm_account     = aws.static-website-account
    aws.route53_account = aws.acm-account
  }

  domain_name = "redirect.${module.route53-zone.default["name"]}"

  subject_alternative_names = [
    "${module.route53-zone.default["name"]}",
  ]

  hosted_zone_id        = "${module.route53-zone.default["zone_id"]}"
  validation_record_ttl = "60"
}

module "route53-records-redirect" {
  providers = {
    aws = aws.route53-account
  }

  source = "../../modules/route53-alias-website"

  zone_id = "${module.route53-zone.default["zone_id"]}"
  name    = "redirect.${module.route53-zone.default["name"]}"

  types = [
    "A",
    "AAAA",
  ]

  alias_name    = "${module.cloudfront-distribution-website-redirect.domain_name}"
  alias_zone_id = "${module.cloudfront-distribution-website-redirect.hosted_zone_id}"
}

module "route53-records-apex" {
  providers = {
    aws = aws.route53-account
  }

  source = "../../modules/route53-alias-website"

  name    = "${module.route53-zone.default["name"]}"
  zone_id = "${module.route53-zone.default["zone_id"]}"

  types = [
    "A",
    "AAAA",
  ]

  // Either record will do, the `A` or `AAAA`.
  alias_name    = "${module.route53-records-redirect.name[0]}"
  alias_zone_id = "${module.route53-records-redirect.zone_id[0]}"
}

// production/www hosting
module "s3-bucket-website-production" {
  providers = {
    aws = aws.static-website-account
  }

  source = "../../modules/s3-bucket-website"

  // This should be a list after the Terraform 0.12 upgrade
  environment = "production"

  suffix = "${local.route53_zone_name_hyphenated}"

  // The logging target usually depends on the output of the S3 log bucket module.
  // Otherwise, provide the name of the bucket for logging. The log bucket must
  // have a suitable ACL!
  s3_bucket_log_bucket = "${var.s3_bucket_log_bucket}"
}

module "cloudfront-distribution-website-production" {
  source = "../../modules/cloudfront-distribution-website"

  providers = {
    aws = aws.static-website-account
  }

  environment = "production"

  // See:
  // https://alexharv074.github.io/2019/05/12/adventures-in-the-terraform-dsl-part-i-structured-data.html#addressing-a-list-of-maps
  // https://www.terraform.io/docs/configuration-0-11/interpolation.html#conditionals
  // https://www.hashicorp.com/blog/terraform-0-12-conditional-operator-improvements/
  aliases = [
    "production.${module.route53-zone.default["name_trimmed"]}",
    "www.${module.route53-zone.default["name_trimmed"]}",
  ]

  domain_name = "${module.route53-zone.default["name_trimmed"]}"

  # origin_domain_names = [
  #   "${module.s3-bucket-website-production.default["website_endpoint"]}",
  # ]
  origin_domain_name = "${module.s3-bucket-website-production.website_endpoint}"

  s3_bucket_log_bucket = "${module.s3-bucket-log-bucket.bucket_domain_name}"

  # lambda_arn = "${module.lambda-add-cloudfront-security-headers.lambda_function["qualified_arn"]}"
  lambda_arn = "${module.lambda-add-cloudfront-security-headers-production.lambda_function["qualified_arn"]}"

  acm_arn = "${module.acm-production.arn}"
}

module "lambda-add-cloudfront-security-headers-production" {
  source = "../../modules/lambda-add-cloudfront-security-headers"

  suffix = "production"

  providers = {
    aws.lambda-account = aws.static-website-account
  }
}

module "acm-production" {
  source = "github.com/morancj/terraform-aws-acm-certificate?ref=0.1.2"

  providers = {
    aws.acm_account     = aws.static-website-account
    aws.route53_account = aws.acm-account
  }

  domain_name = "production.${module.route53-zone.default["name"]}"

  subject_alternative_names = [
    "www.${module.route53-zone.default["name"]}",
  ]

  hosted_zone_id        = "${module.route53-zone.default["zone_id"]}"
  validation_record_ttl = "60"
}

module "route53-records-production" {
  providers = {
    aws = aws.route53-account
  }

  source = "../../modules/route53-alias-website"

  zone_id = "${module.route53-zone.default["zone_id"]}"
  name    = "www.${module.route53-zone.default["name"]}"

  types = [
    "A",
    "AAAA",
  ]

  # alias_name    = "${module.cloudfront-distribution-website-production.default["name"]}"
  # alias_zone_id = "${module.cloudfront-distribution-website-production.default["zone_id"]}"
  alias_name = "${module.cloudfront-distribution-website-production.domain_name}"

  alias_zone_id = "${module.cloudfront-distribution-website-production.hosted_zone_id}"
}
