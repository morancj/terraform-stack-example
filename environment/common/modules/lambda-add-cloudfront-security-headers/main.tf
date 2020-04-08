// Trust Lambda, Lambda@Edge
data "aws_iam_policy_document" "iam_for_lambda_trust" {
  provider = "aws.lambda-account"

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "lambda_cloudfront" {
  provider           = "aws.lambda-account"
  name               = "AssumeRole-lambda_cloudfront-${var.suffix}"
  description        = "Used by CloudFront for Lambda@Edge"
  assume_role_policy = "${data.aws_iam_policy_document.iam_for_lambda_trust.json}"
  path               = "/service-role/"
}

// Allow Lambda function execution
resource "aws_iam_role_policy_attachment" "lambda_cloudfront_execution" {
  provider   = "aws.lambda-account"
  role       = "${aws_iam_role.lambda_cloudfront.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_cloudfront_xray" {
  provider   = "aws.lambda-account"
  role       = "${aws_iam_role.lambda_cloudfront.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_lambda_function" "cloudfront-add-security-headers" {
  provider = "aws.lambda-account"

  // Use paths relative to the Terraform repo root, or the full path
  // (e.g. "/home/user/Git/Terraform/...") will be written to the state file.
  filename = "environment/common/modules/lambda-add-cloudfront-security-headers/cloudfront-add-security-headers.zip"

  function_name = "cloudfront-add-security-headers-${var.suffix}"
  role          = "${aws_iam_role.lambda_cloudfront.arn}"
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("cloudfront-add-security-headers.zip"))}"
  source_code_hash = "${filebase64sha256("environment/common/modules/lambda-add-cloudfront-security-headers/cloudfront-add-security-headers.zip")}"

  runtime = "nodejs10.x"
  publish = true
}
