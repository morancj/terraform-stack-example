resource "aws_launch_template" "default" {
  count                   = length(var.names)
  name                    = var.names[count.index]
  description             = var.description[count.index]
  disable_api_termination = false

  ebs_optimized = false

  iam_instance_profile {
    name = aws_iam_instance_profile.default.name
  }

  image_id = var.image_id[count.index]

  instance_initiated_shutdown_behavior = "stop"

  instance_type = var.instance_type

  key_name = var.key_name

  monitoring {
    enabled = false
  }

  // We may eventually wish this module to support more than one network
  // interface. If so, handle a map, not a list.
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true

    # device_index = "0"
    security_groups = var.network_interface_security_groups

    subnet_id = var.network_interface_subnet_id
  }

  placement {
    tenancy = "default"
  }

  // Using a map for tags would allow tags for different purposes, e.g. CPM
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = format("%s%s%s", var.names[count.index], ".", var.domain_name)
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = format("%s%s%s", var.names[count.index], ".", var.domain_name)
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.tpl", {
    fqdn = format("%s%s%s", var.names[count.index], ".", var.domain_name)
  }))
}
