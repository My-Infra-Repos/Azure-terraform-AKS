// variable "resource_group_name" {
//   type        = string
//   description = "Resource group name"
// }

variable "app_name" {
  type        = string
  default = "example-nonprod"
  description = "Application name. Use only lowercase letters and numbers"
}

variable "location" {
  default="centralUS"
  type        = string
  description = "Azure region where to create resources."
}



