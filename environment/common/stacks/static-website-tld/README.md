# Terraform module: `static-website-tld`

## Description

This module creates static website hosting infrastructure. It will create `staging`, `production`, and `redirect` S3 buckets, CloudFront Web Distributions, and required resources. After the `apply` run completes, you should be able to browse to `http://испытание.テスト` and be redirected to `https://www.испытание.テスト`.

## Prerequisites

- Everything in the main [`README.md`](../../../../README.md) file.
- Other requirements should be fully described in this repo: see [`main.tf`](main.tf) in this directory, and [`main.tf`](../../../../main.tf) in the root directory.

## Usage

1) Purchase a new domain on AWS Route53: this new Zone will be the target for your module. __Do not__ create the Zone in Route53: this module will do that for you. If you have already created the Zone, see [Limitations](#Limitations) below.
1) Add a `module` block in [`main.tf` at the root of this repo](../../../../main.tf) calling this module.
1) Customise the parameters as required (use your new zone as a target, add a comment relating to e.g. the ticket ID, change the module `provider`s as required).  See [`module "example-org" {}`](../../../../main.tf#L130) for example.
1) Preview the changes with `terraform plan -out My.plan`. Suffix with `| sed 's/\\n/\n/g' | sed 's/\\"/\"/g'` to improve the output JSON formatting.
1) Review the proposed changes to ensure they are as you expect.
1) Apply your changes with `terraform apply My.plan`.

```zsh
➜ terraform plan -out My.plan | sed 's/\\n/\n/g' | sed 's/\\"/\"/g'
```

### Usage Tip

When working on the `example-org` module, I found it expedient to constrain my changes to those introduced by the module, until I needed the IAM change mentioned in [#Limitations](#Limitations) below. To do so, run a command like this:

```zsh
terraform plan -target=module.example-org -out=Morello-Project.plan | sed 's/\\n/\n/g' | sed 's/\\"/\"/g'
```

changing the module name and plan filenames as appropriate.

## Limitations

### Route53 Zone limitations

If you have already created the Zone, you'll need to import it with a command like this:

```zsh
aws-profile -p TerraformFullAccess /opt/terraform/terraform-0.11.14/terraform import -provider=aws.ACCOUNT_four module.ACCOUNT_four-static-hosting.module.route53-zone.aws_route53_zone.default ZABCDEFGHI0123
```

replacing the `ACCOUNT_four` references and Zone ID `ZABCDEFGHI0123` as required. This is due to Terraform adding the trailing period, which AWS no longer exposes via their API. If you don't do this, you'll have two domains in Route53 which look identical: one created by you, the other created by Terraform. ACM validation will fail, and so the stack won't deploy.

### IAM Policy limitations

This module is _almost_ feature complete: to allow the deployment to succeed, you'll need to add a line like this:

```hcl
      "${module.my-new-module-name.iam_role_buildbot_arn}",
```

to the `data "aws_iam_policy_document" "CI_CD_bot" {` stanza in [`../iamp.tf`](../../../../iamp.tf#L265). Replace `my-new-module-name` as required! After doing this, run the `terraform plan` command again, but remove the `-target=` option.

## To-Do

After migration to Terraform v. 0.12 or higher, it should be possible to migrate the `list`s to `map`s and consolidate both [`staging.tf`](staging.tf) and [`production.tf`](production.tf) into [`main.tf`](main.tf).

Remove the need to edit [`../iamp.tf`](../../../../iamp.tf#L265).
