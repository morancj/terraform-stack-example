variable "domain_name" {
  type        = "string"
  description = "Domain name, no trailing dot"
  default     = "example.org"
}

variable "names" {
  type        = "list"
  description = "EC2 Launch Template name"

  default = [
    "ubuntu-1404-tf",
    "ubuntu-1604-tf",
    "ubuntu-1804-tf",
  ]
}

variable "description" {
  type        = "list"
  description = "EC2 Launch Template description"

  default = [
    "Ubuntu 14.04, AMI release 20191107",
    "Ubuntu 16.04, AMI release 20191107",
    "Ubuntu 18.04, AMI release 20191107",
  ]
}

variable "image_id" {
  type        = "list"
  description = "AMI ID for EC2 Launch Template"

  default = [
    // From https://cloud-images.ubuntu.com/locator/ec2/, example search:
    // `18.04 us-east-1 hvm:ebs-ssd amd64`
    "ami-000b3a073fc20e415",
    "ami-04ac550b78324f651",
    "ami-055df5de4f42cf331",
  ]
}

variable "key_name" {
  type        = "string"
  description = "EC2 SSH private key name"

  // FIXME: We could add a similarly-named key (e.g. `2020`) to each AWS
  // Account for convenience, or simply pass them to the module
  default = "account_ones-2017b"
}

variable "network_interface_security_groups" {
  type        = "list"
  description = "A list of Security Groups to associate with the network interface"

  default = [
    "sg-abcdef01234567890",
  ]
}

variable "network_interface_subnet_id" {
  type        = "string"
  description = "Subnet ID for the network interface"

  default = "subnet-fedcba00"
}

variable "instance_type" {
  type        = "string"
  description = "EC2 Instance Type"
  default     = "t3a.micro"
}
