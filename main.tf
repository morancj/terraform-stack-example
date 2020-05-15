terraform {
  required_version = "~> 0.11"

  required_providers {
    aws = "~> 2.41"
    template = "~> 2.1"
  }

}

provider "aws" {
  region = "us-east-1"
}

// All these account ID's may be the same! However, specifying them seperately
// enables this demo to support multiple AWS Accounts
variable "ACCOUNTID_one" {
  type = string
  description = "First AWS Account ID"
}

variable "ACCOUNTID_two" {
  type = string
  description = "Second AWS Account ID"
}

variable "ACCOUNTID_three" {
  type = string
  description = "Third AWS Account ID"
}

//variable "IAM_ROLE_BUILDBOT_ARN" {
//  type = string
//  description = "ARN for CI/CD build bot Role"
//  default = "arn:aws:iam::${var.ACCOUNTID_three}:role/CI_CD_BuildBot_Role"
//}

locals {
  IAM_ROLE_BUILDBOT_ARN = "arn:aws:iam::${var.ACCOUNTID_three}:role/CI_CD_BuildBot_Role"
}

variable "ADMINISTRATIVE_ROLE" {
  type = string
  description = "AWS IAM Role for Terraform to assume"
}

provider "aws" {
  alias = "account_one"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${var.ACCOUNTID_one}:role/${var.ADMINISTRATIVE_ROLE}"
    session_name = "Terraform-account_one_Admin"
  }

}

provider "aws" {
  alias = "account_two"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${var.ACCOUNTID_two}:role/${var.ADMINISTRATIVE_ROLE}"
    session_name = "Terraform-account_two_Admin"
  }

}


// Zone-Apex-Domain static website infrastructure
module "example_org" {
  // Must pass all used providers, see:
  // https://www.terraform.io/docs/configuration/modules.html#passing-providers-explicitly
  // For this example,
  // Route 53 and ACM entries are in the AWS Account "account_one", while
  // everything else is in "account_two"
  providers = {
    aws.static-website-account = aws.account_one
    aws.route53-account        = aws.account_two
    aws.acm-account            = aws.account_two
    aws.lambda-account         = aws.account_one
    aws.iam-account            = aws.account_one
    aws.git-account            = aws.account_one
  }

  // Variables
  source = "./environment/common/stacks/static-website-tld/"

  aws_route53_zone = {
    name    = "example.org"
    comment = "Managed by Terraform"
  }

  // Either re-use an existing shared logging bucket
  // s3_bucket_log_bucket = aws_s3_bucket.my-bucket-name.id

  // Otherwise, you may want to create an S3 bucket
  # s3_bucket_log_bucket = "logs-${replace(var.aws_route53_zone["name"], ".", "-")}"
  s3_bucket_log_bucket = "logs-example-org"
  IAM_ROLE_BUILDBOT_ARN = local.IAM_ROLE_BUILDBOT_ARN
}

module "account_one" {
  providers = {
    aws = aws.account_one
  }

  source = "./account/common"
}

module "account_two" {
  providers = {
    aws = aws.account_two
  }

  source = "./account/account_two"
}
