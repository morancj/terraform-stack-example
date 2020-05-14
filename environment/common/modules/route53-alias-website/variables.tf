variable "zone_id" {
  description = "Route 53 Zone in which to create records."
}

variable "name" {
  description = "Record name to create."
}

variable "types" {
  type = list(string)

  default = [
    "A",
    "AAAA",
  ]

  description = "Record Types to create: `A` (IPv4) and `AAAA` (IPv6) supported."
}

variable "alias_name" {
  description = "Value of the Route53 `ALIAS` record target."
}

variable "alias_zone_id" {
  description = "Route53 Zone in which the target resides."
}
