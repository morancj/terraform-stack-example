resource "aws_route53_zone" "default" {
  name    = var.name
  comment = var.comment
}
