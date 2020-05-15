output "arn" {
  value = aws_iam_role.buildbot.arn
}

data "aws_caller_identity" "current" {}

output "static-website_account_id" {
  value = data.aws_caller_identity.current.account_id
}
