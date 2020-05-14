output "default" {
  value = {
    name         = aws_route53_zone.default.name
    comment      = aws_route53_zone.default.comment
    zone_id      = aws_route53_zone.default.zone_id
    name_trimmed = replace(aws_route53_zone.default.name, "/\\.$/", "")
  }
}

output "name" {
  value = aws_route53_zone.default.name
}

output comment {
  value = aws_route53_zone.default.comment
}

output zone_id {
  value = aws_route53_zone.default.zone_id
}

// Workaround for
// https://github.com/terraform-providers/terraform-provider-aws/issues/6535
output name_trimmed {
  value = replace(aws_route53_zone.default.name, "/\\.$/", "")
}
