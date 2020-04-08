output "default" {
  value = {
    id             = "${aws_cloudfront_distribution.default.id}"
    hosted_zone_id = "${aws_cloudfront_distribution.default.hosted_zone_id}"
    domain_name    = "${aws_cloudfront_distribution.default.domain_name}"
  }
}

output "id" {
  value = "${aws_cloudfront_distribution.default.id}"
}

output "hosted_zone_id" {
  value = "${aws_cloudfront_distribution.default.hosted_zone_id}"
}

output "domain_name" {
  value = "${aws_cloudfront_distribution.default.domain_name}"
}
