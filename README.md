# Terraform Example stacks

Example stacks for static hosting.

Updated for Terraform 0.12, tested (hah!) with v0.12.24.

## Introduction

`account/` is used for configuring per-AWS Account infrastructure: currently, this just deploys EC2 templates for Ubuntu 1{4,6,8}.04. These launch templates are pre-configured with [user data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html), which will be evaluated by [cloud-init](https://cloudinit.readthedocs.io/en/latest/) if you Launch a new EC2 Instance from one of these templates.

`environment/` is used for creating static website hosting infrastructure for a Zone apex. It will create a Zone apex redirect (from e.g. `example.org` to `www.example.org`), `staging.example.org` and `[production|www].example.org`.

Very similar code is being used in production for several organisations. However, that was before the migration of this code to support Terraform 0.12 / HCL 2, so new bugs may have been introduced since then.

NO WARRANTY OF CORRECT OR EXPECTED OPERATION IS PROVIDED: USE IS ENTIRELY AT YOUR OWN RISK!

## Prerequisites

A suitable test top-level domain: the code assumes `example.org`, which __WILL NOT WORK__.

At least one AWS Account and Role with near-`root` level access via API keys. The default `AdministratorAccess` Policy attached to a suitable role will work fine.

[Terraform](https://www.terraform.io/downloads.html) [0.12.24](https://releases.hashicorp.com/terraform/0.12.24/) or higher.

⚠️ Be sure to verify your download checksums and signature!

AWS access configured: to get started, it is recommended you use either [an AWS credentials file](https://www.terraform.io/docs/providers/aws/index.html#shared-credentials-file) or [Environment variables](https://www.terraform.io/docs/providers/aws/index.html#environment-variables).

Basic experience with Terraform, modules and variables. This example is configured with environment variables and assumes `example.org` as the top-level domain. Support for subdomains is untested and probably won't work.

## Limitations

IAM configuration is incomplete.

[Lambda@Edge](https://aws.amazon.com/lambda/edge/) on the CloudFront stacks is partially configured with an example function. It should be fine for a demo. Look at the `lifecycle` `ignore_changes` statement on the `aws_cloudfront_distribution` resource for more.

You must upload your content to the source buckets (and possibly subsequently invalidate the CloudFront cache and your browser cache) via some other mechanism. The code was written with a CI/CD pipeline in mind: the example uses a Role called `CI_CD_BuildBot_Role` in `ACCOUNTID_three`.

## To-Do

Support more configuration using [Input Variables](https://www.terraform.io/docs/configuration/variables.html).

Split all modules into their own repos.

Make the split between `account/` and `environment/` more logical.

Use more Terraform 0.12 / HCL 2 features to reduce the code for `staging` and `production` hosting.

Support website hosting for non-apex domain names.

## Usage

Substitute your own values for the three `TF_VAR_ACCOUNTID` variables and `TF_VAR_ADMINISTRATIVE_ROLE` as required.

Change `example.org` in the code to your top-level test domain.

```
➜ terraform version
Terraform v0.12.24
+ provider.aws v2.62.0
+ provider.template v2.1.2

➜ terraform init

➜ terraform validate
Success! The configuration is valid.

➜ TF_VAR_ACCOUNTID_one=012345678901 \
  TF_VAR_ACCOUNTID_two=123456789012 \
  TF_VAR_ACCOUNTID_three=234567890123 \
  TF_VAR_ADMINISTRATIVE_ROLE=TerraformRoleName \
  terraform plan
```

### Usage Example

```
➜ terraform version
Terraform v0.12.24
+ provider.aws v2.62.0
+ provider.template v2.1.2

➜ terraform init
Initializing modules...
- account_one in account/default
- account_one.ec2_instance_launch_templates in environment/common/modules/ec2-launch-templates
- account_two in account/account_two
- account_two.ec2_instance_launch_templates in environment/common/modules/ec2-launch-templates
- example_org in environment/common/stacks/static-website-tld
Downloading github.com/morancj/terraform-aws-acm-certificate?ref=1.0.1 for example_org.acm-production...
- example_org.acm-production in .terraform/modules/example_org.acm-production
Downloading github.com/morancj/terraform-aws-acm-certificate?ref=1.0.1 for example_org.acm-redirect...
- example_org.acm-redirect in .terraform/modules/example_org.acm-redirect
Downloading github.com/morancj/terraform-aws-acm-certificate?ref=1.0.1 for example_org.acm-staging...
- example_org.acm-staging in .terraform/modules/example_org.acm-staging
- example_org.cloudfront-distribution-website-production in environment/common/modules/cloudfront-distribution-website
- example_org.cloudfront-distribution-website-redirect in environment/common/modules/cloudfront-distribution-website-redirect
- example_org.cloudfront-distribution-website-staging in environment/common/modules/cloudfront-distribution-website
- example_org.iam-website-buildbot in environment/common/modules/iam-website-buildbot
- example_org.lambda-add-cloudfront-security-headers-production in environment/common/modules/lambda-add-cloudfront-security-headers
- example_org.lambda-add-cloudfront-security-headers-staging in environment/common/modules/lambda-add-cloudfront-security-headers
- example_org.route53-records-apex in environment/common/modules/route53-alias-website
- example_org.route53-records-production in environment/common/modules/route53-alias-website
- example_org.route53-records-redirect in environment/common/modules/route53-alias-website
- example_org.route53-records-staging in environment/common/modules/route53-alias-website
- example_org.route53-zone in environment/common/modules/route53-zone
- example_org.s3-bucket-log-bucket in environment/common/modules/s3-bucket-log-bucket
- example_org.s3-bucket-website-production in environment/common/modules/s3-bucket-website
- example_org.s3-bucket-website-redirect in environment/common/modules/s3-bucket-website-redirect
- example_org.s3-bucket-website-staging in environment/common/modules/s3-bucket-website

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.62.0...
- Downloading plugin for provider "template" (hashicorp/template) 2.1.2...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.example_org.module.lambda-add-cloudfront-security-headers-staging.data.aws_iam_policy_document.iam_for_lambda_trust: Refreshing state...
module.example_org.module.s3-bucket-website-production.data.aws_iam_policy_document.default: Refreshing state...
module.example_org.module.lambda-add-cloudfront-security-headers-production.data.aws_iam_policy_document.iam_for_lambda_trust: Refreshing state...
module.example_org.module.iam-website-buildbot.data.aws_caller_identity.current: Refreshing state...
module.example_org.module.s3-bucket-website-staging.data.aws_iam_policy_document.default: Refreshing state...
module.example_org.module.iam-website-buildbot.data.aws_iam_policy_document.buildbot_trust_relationship: Refreshing state...
module.account_one.module.ec2_instance_launch_templates.data.aws_iam_policy_document.default: Refreshing state...
module.example_org.module.iam-website-buildbot.data.aws_iam_policy_document.buildbot_access_common: Refreshing state...
module.account_two.module.ec2_instance_launch_templates.data.aws_iam_policy_document.default: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:
```
_...snip..._

Here, Terraform should output the list of resources (infrastructure entities) to create. If all looks good, run `terraform plan --`
