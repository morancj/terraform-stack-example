# `ec2-launch-templates`

## Introduction

This modules deploys EC2 Launch Templates for Ubuntu 14.04, 16.04 and 18.04. They enable common configuration across AWS Accounts, which would be hard to build and maintain manually.

Defaults are configured in [../../environment/common/modules/ec2-launch-templates/variables.tf](../../environment/common/modules/ec2-launch-templates/variables.tf). The defaults are configured for the `account_one` AWS Account, which is a sandbox account used for testing, and should therefore be a safe default. [account/common] and [account/dev] are therefore both soft linked to [account/default].

To use this module on other accounts, you must change:

- `key_name`
- `network_interface_security_groups`
- `network_interface_subnet_id`

To use it in other AWS Regions, you will also have to change:

- `image_id`

as these are defined per-region. See below for more details.

## Variables

Common variables to override will be:

- `key_name` : This is the EC2 (SSH) Key Pair name to use;
- `network_interface_security_groups` : This is a `list` of EC2 Security Groups to include in your templates;
- `network_interface_subnet_id` : This is the EC2 Subnet ID for the network interface (only one network interface is currently supported).

In future, these variables should be replaced with to `resource` and `data` config defined, and imported into, in Terraform.

## Prerequisites

This module does not create:

- DNS Zone(s)
- EC2 Key Pairs
- VPCs
- Security Groups

These must be defined elsewhere (in a higher-level yet to be written module), or manually created and suitable values passed as variables.
