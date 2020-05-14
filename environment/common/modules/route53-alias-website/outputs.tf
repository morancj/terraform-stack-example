output "name" {
  value = aws_route53_record.default.*.name
}

output zone_id {
  value = aws_route53_record.default.*.zone_id
}
