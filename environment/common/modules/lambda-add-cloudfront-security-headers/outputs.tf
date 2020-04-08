output "iam_role" {
  value = {
    id  = "${aws_iam_role.lambda_cloudfront.id}"
    arn = "${aws_iam_role.lambda_cloudfront.arn}"
  }
}

output "lambda_function" {
  value = {
    arn           = "${aws_lambda_function.cloudfront-add-security-headers.arn}"
    qualified_arn = "${aws_lambda_function.cloudfront-add-security-headers.qualified_arn}"
  }
}
