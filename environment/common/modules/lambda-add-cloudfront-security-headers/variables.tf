variable "suffix" {
  type        = "string"
  description = "Used to identify build environments. Could be determined from `environment` if the modules were reworked (requires Terraform ≥ 0.12 for clear code)."
}
