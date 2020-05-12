resource "aws_route53_record" "default" {
  provider        = aws.route53-account
  count           = length(var.types)
  zone_id         = var.zone_id
  name            = var.name
  type            = element(var.types, count.index)
  allow_overwrite = false

  alias {
    name                   = var.alias_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = false
  }
}
