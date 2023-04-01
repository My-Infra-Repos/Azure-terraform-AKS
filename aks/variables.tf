// variable "resource_group_name" {
//   type        = string
//   description = "Resource group name"
// }

variable "app_name" {
  type        = string
  description = "Application name. Use only lowercase letters and numbers"
}

variable "location" {
  default="centralUS"
  type        = string
  description = "Azure region where to create resources."
}



### AKS configuration params ###
variable "kubernetes_version" {
  type = string
  description = "Version of your kubernetes node pool"
}


variable "vm_size_node_pool" {
  type = string
  description = "VM Size of your node pool"
}

variable "node_pool_min_count" {
  type = string
  description = "VM minimum amount of nodes for your node pool"
}

variable "node_pool_max_count" {
  type = string
  description = "VM maximum amount of nodes for your node pool"
}



### Helm Chart versions ###
variable "helm_pod_identity_version" {
  type        = string
  description = "Helm chart version of aad-pod-identity"
}

variable "helm_csi_secrets_version" {
  type        = string
  description = "Helm chart version of secrets-store-csi-driver-provider-azure"
}

variable "helm_keda_version" {
  type        = string
  description = "Helm chart version of KEDA"
}

variable "kubernetes_cluster_rbac_enabled" {
  default = "true"
}

variable "aks_admins_group_object_id" {
}

// variable "virtual_network_name" {
//   type        = string
//   description = "Virtual network name. This service will create subnets in this network."
// }

// variable "acr_id" {
//   type        = string
//   description = "Azure container registry ID to pull images from."
// }

// variable "key_vault_id" {
//   type        = string
//   description = "Application key vault ID"
// }

// variable "log_analytics_id" {
//   type        = string
//   description = "log analytics ID"
// }

variable "address_space"{
  type=string
  default="172.2.1.0/24"
  
}

variable "domain_name_label" {
  type        = string
  description = "Domain name label for AKS Cluster / Application Gateway"
}
