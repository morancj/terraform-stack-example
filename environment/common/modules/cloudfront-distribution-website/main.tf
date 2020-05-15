// CloudFront distributions for static website

// `locals` used to concatenate strings
locals {
  origin_id = "S3-website"

}

resource "aws_cloudfront_distribution" "default" {

  lifecycle {
    # Ignore changes to the Lambda function association as those are managed by our
    # CI/CD process, not Terraform.
    # We can't ignore the default_cache_behavior.ID.lambda_function_association.lambda_arn directly,
    # because the value of "ID" is unpredictable (is it some hash of the ETAG?)
    ignore_changes = [
      default_cache_behavior
    ]
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id   = local.origin_id
    origin_path = ""

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  # comment         = "${var.domain_name} ${var.environments[count.index]} website"
  comment = "${var.domain_name} ${var.environment} website"

  // `aliases` must match `environments`, at least until I figure out iterating on this properly!
  # var.aliases[count.index]
  aliases = var.aliases

  # "${var.environments == "staging" ? var.aliases_staging : var.aliases_production}"


  # "alias_one",
  # "alias_two"


  # "${local.aliases[count.index]}"
  // "${split(",", var.aliases_staging ? element(values(var.aliases_production), 0) : join(",", list(element(split(",", element(values(var.aliases_production), 0)), 0), "")))}"
  # "${var.environments == "production" ?
  #   "${split(",", var.prod_subnet : join(","))" :
  #   var.dev_subnet}"


  # "{split(",", var.aliases_staging)}"


  # "${var.environments == "staging" ? join(",", split(",", list(var.aliases_staging))) : join(",", split(",", list(var.aliases_production)))}"

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      lambda_arn = var.lambda_arn

      event_type = "origin-response"
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }
  http_version = "http2"
  logging_config {
    include_cookies = false
    bucket          = var.s3_bucket_log_bucket

    # environments          = "${local.environments}"
    # prefix = "cf-logs/${var.environments[count.index]}.${var.domain_name}/"
    prefix = "cf-logs/${var.environment}.${var.domain_name}/"
  }
  price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    // Hyphenated form of the name
    # Name ="${replace(
    #   "${var.environments[count.index]}.${var.domain_name}",
    #   ".",
    #   "-")
    #   }"
    # Name = "${var.environments[count.index]}.${var.domain_name}"
    Name = "${var.environment}.${var.domain_name}"

    # Environment = "${var.environments[count.index]}"
    Environment = var.environment
  }
  viewer_certificate {
    acm_certificate_arn      = var.acm_arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }
  # Work around new behaviour documented in GitHub issue 8073:
  # https://github.com/terraform-providers/terraform-provider-aws/issues/8073
  wait_for_deployment = false
}
