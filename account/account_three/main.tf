// Root module for AWS Account `Production`.

// Common config

// EC2 Instance Launch Templates

module "ec2_instance_launch_templates" {
  source = "../../environment/common/modules/ec2-launch-templates"

  key_name = var.key_name

  network_interface_security_groups = [
    // Some SG ID
    "sg-0fedcba9876543210",
  ]

  // Some subnet id
  network_interface_subnet_id = "subnet-76543210"
}
