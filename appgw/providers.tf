terraform {
  # Set the terraform required version
  required_version = ">= 0.14.8"

  # Register common providers
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.48.0"
      // version = "2.88.1"
      // version = "3.21.0"
      // version = "2.67.0"
    }

  helm = {
      source  = "hashicorp/helm"
      version = "2.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.3.2"
    }

  }

  # Persist state in a storage account
    backend "azurerm" {
    resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "appgateway.tfstate"

     }
}

# Configure the Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

// provider "kubernetes" {
//   host                   = data.terraform_remote_state.aks.outputs.aks_config.host
//   client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.aks_config.client_certificate)
//   client_key             = base64decode(data.terraform_remote_state.aks.outputs.aks_config.client_key)
//   cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.aks_config.cluster_ca_certificate)
// }

// provider "helm" {
//   kubernetes {
//     host                   = data.terraform_remote_state.aks.outputs.aks_config.host
//     client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.aks_config.client_certificate)
//     client_key             = base64decode(data.terraform_remote_state.aks.outputs.aks_config.client_key)
//     cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.aks_config.cluster_ca_certificate)
//   }
// }

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
  }
}