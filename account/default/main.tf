// Common config
// See [../README.md] for more.

// EC2 Instance Launch Templates
module "ec2_instance_launch_templates" {
  source = "../../environment/common/modules/ec2-launch-templates"

  // When adding LT's to an AWS Account other than `account_one`, you *must* specify
  // some variables. See
  // [../../environment/common/modules/ec2-launch-templates/README.md]
  // for details
}
