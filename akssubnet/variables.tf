
variable "app_name" {
  type        = string
  description = "Application name. Use only lowercase letters and numbers"
}

variable "location" {
  default="centralUS"
  type        = string
  description = "Azure region where to create resources."
}


variable "kubernetes_address_space" {
  default="172.2.0.0/24"
  type = string
  description = "Version of your kubernetes node pool"
}

// variable "aci_address_space" {
//   default="172.2.8.0/24"
//   type = string
//   description = "Version of your kubernetes node pool"
// }