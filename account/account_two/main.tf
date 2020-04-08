// Root module for AWS Account `Web`.

// Common config

// EC2 Instance Launch Templates

module "ec2_instance_launch_templates" {
  source = "../../environment/common/modules/ec2-launch-templates"

  key_name = "account_one_key"

  network_interface_security_groups = [
    "sg-0123456789abcdef0",
  ]

  network_interface_subnet_id = "subnet-01234567"
}
