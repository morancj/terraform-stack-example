terraform {
  required_version = "~> 0.11"

  required_providers {
    aws = "~> 2.41"
    template = "~> 2.1"
  }

}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::ACCOUNTID_one:role/ADMINISTRATIVE_ROLE"
    session_name = "Terraform-account_one_Admin"
  }

  alias = "account_one"
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::ACCOUNTID_two:role/ADMINISTRATIVE_ROLE"
    session_name = "Terraform-account_two_Admin"
  }

  alias = "account_two"
}


// Zone-Apex-Domain static website infrastructure
module "example_net" {
  // Must pass all used providers, see:
  // https://www.terraform.io/docs/configuration/modules.html#passing-providers-explicitly
  // For this example,
  // Route 53 and ACM entries are in the AWS Account "account_one", while
  // everything else is in "account_two"
  providers = {
    aws.static-website-account = "aws.account_one"
    aws.route53-account        = "aws.account_two"
    aws.acm-account            = "aws.account_two"
    aws.lambda-account         = "aws.account_one"
    aws.iam-account            = "aws.account_one"
    aws.git-account            = "aws.account_one"
  }

  // Variables
  source = "./environment/common/stacks/static-website-tld/"

  aws_route53_zone {
    name    = "example.net"
    comment = "Managed by Terraform"
  }

  // Either re-use an existing shared logging bucket
  // s3_bucket_log_bucket = "${aws_s3_bucket.my-bucket-name.id}"

  // Otherwise, you may want to create an S3 bucket
  # s3_bucket_log_bucket = "logs-${replace(var.aws_route53_zone["name"], ".", "-")}"
  s3_bucket_log_bucket = "logs-example-net"
}

module "account_one" {
  providers = {
    aws = "aws.account_one"
  }

  source = "./account/common"
}

module "account_two" {
  providers = {
    aws = "aws.account_two"
  }

  source = "./account/account_two"
}
