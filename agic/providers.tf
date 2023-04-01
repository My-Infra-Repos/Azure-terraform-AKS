terraform {
  # Set the terraform required version
  required_version = ">= 0.14.8"

  # Register common providers
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version= "3.48.0"
      // version = "2.88.1"
    }

  helm = {
      source  = "hashicorp/helm"
      // version = "2.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      // version = "2.3.2"
    }

  }

  # Persist state in a storage account
    backend "azurerm" {
    resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "agic.tfstate"

     }
}

# Configure the Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.aks.outputs.aks_admin_config.host
  client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.aks_admin_config.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.aks.outputs.aks_admin_config.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.aks_admin_config.cluster_ca_certificate)
}

// provider "helm" {
//   debug           = true
//   namespace       = "kube-system"
//   service_account = "tiller"
//   install_tiller  = "true"
//   tiller_image    = "gcr.io/kubernetes-helm/tiller:v${var.TILLER_VER}"
//   kubernetes {
//     host                   = "${azurerm_kubernetes_cluster.k8s.kube_admin_config.0.host}"
//     client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_certificate)}"
//     client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_key)}"
//     cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_admin_config.0.cluster_ca_certificate)}"
//   }
// }

provider "helm" {

  kubernetes {
    host                   = data.terraform_remote_state.aks.outputs.aks_admin_config.host
    client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.aks_admin_config.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.aks.outputs.aks_admin_config.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.aks_admin_config.cluster_ca_certificate)
  }
}





// provider "kubernetes" {
//   host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
//   client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
//   client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
//   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
// }

// provider "helm" {
//   kubernetes {
//     host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
//     client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
//     client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
//     cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
//   }
// }