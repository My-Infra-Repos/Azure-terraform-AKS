terraform {
  # Set the terraform required version
  required_version = ">= 0.14.8"

  # Register common providers
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    //   version = "2.67.0"
    }

  }

  # Persist state in a storage account
     backend "azurerm" {
     resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "vnet.tfstate"

     }
}

# Configure the Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# Data

# Provides client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
