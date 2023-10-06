variable "app_name" {
  type        = string
  default ="exampleapplication"
  description = "Application name. Use only lowercase letters and numbers"
}

variable "location" {
  default="centralUS"
  type        = string
  description = "Azure region where to create resources."
}

variable "helm_agic_version" {
  default="1.6.0"
  type        = string
  description = "Helm chart version of ingress-azure-helm-package"
}