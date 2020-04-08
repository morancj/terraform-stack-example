// Cross-Account access
data "aws_iam_policy_document" "buildbot_trust_relationship" {
  statement {
    sid     = "TrustRelationship"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${var.iam_role_buildbot_arn}"]
    }
  }
}

resource "aws_iam_role" "buildbot" {
  name               = "${var.iam_role_buildbot_name}"
  description        = "Static website buildbot target Role"
  assume_role_policy = "${data.aws_iam_policy_document.buildbot_trust_relationship.json}"
}

// Actions permitted to the buildbot Role in this Account
data "aws_iam_policy_document" "buildbot_access_s3" {
  // S3 Bucket-level permissions
  statement {
    sid = "S3BucketAccess"

    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      "${var.s3_buckets}",
    ]
  }

  // S3 Object-level permissions
  statement {
    sid = "S3ObjectAccess"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
    ]

    resources = [
      "${var.s3_paths}",
    ]
  }
}

# S3 bucket access
resource "aws_iam_policy" "buildbot_access_s3" {
  name        = "buildbot_access_s3"
  description = "S3 bucket and object access"
  policy      = "${data.aws_iam_policy_document.buildbot_access_s3.json}"
}

resource "aws_iam_role_policy_attachment" "buildbot_access_s3" {
  role       = "${aws_iam_role.buildbot.name}"
  policy_arn = "${aws_iam_policy.buildbot_access_s3.arn}"
}

# Access to wildcard resources
data "aws_iam_policy_document" "buildbot_access_common" {
  // CloudFront permissions can't easily be restricted to a distribution, see:
  // https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cf-api-permissions-ref.html
  statement {
    sid = "AllowCloudFrontInvalidations"

    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetDistribution",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations",

      // Required for Lambda@Edge
      "cloudfront:GetDistributionConfig",

      "cloudfront:UpdateDistribution",
    ]

    resources = [
      "*",
    ]
  }

  // We use Lambda functions for redirects via CF and Lambda@Edge
  statement {
    sid = "AllowLambdaFunctionModifications"

    actions = [
      "lambda:CreateFunction",
      "lambda:ListFunctions",
      "lambda:PublishVersion",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunction",
      "lambda:EnableReplication*",
    ]

    resources = [
      "*",
    ]
  }

  // Allow providing STS credentials to EC2 instance running CI/CD
  statement {
    sid = "PassthroughAuthentication"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${var.iam_role_buildbot_arn}",
    ]
  }
}

resource "aws_iam_policy" "buildbot_access_common" {
  name        = "buildbot_access_common"
  description = "Services required by the buildbot regardless of S3 bucket"
  policy      = "${data.aws_iam_policy_document.buildbot_access_common.json}"
}

resource "aws_iam_role_policy_attachment" "buildbot_access_common" {
  role       = "${aws_iam_role.buildbot.name}"
  policy_arn = "${aws_iam_policy.buildbot_access_common.arn}"
}

# resource "aws_iam_policy" "buildbot_assume_role" {
#   name        = "$buildbot_access_common"
# #   description = "Grants cross-Account access for the buildbot"
#   description = ""
#   policy      = "${data.aws_iam_policy_document.buildbot_access_common.json}"
# }


// To-Do: add functionality for
// `resource "aws_iam_role_policy_attachment" "CI_CD_bot_policy_attachment-CI_CD_Role"`
// and
// `data "aws_iam_policy_document" "CI_CD_bot"`
// bindings.

