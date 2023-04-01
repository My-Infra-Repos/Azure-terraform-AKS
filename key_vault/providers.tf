terraform {
  # Set the terraform required version
  required_version = ">= 0.14.8"
  // experiments = [module_variable_optional_attrs]

  # Register common providers
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      // version = "2.88.1"
    }

  }

  # Persist state in a storage account
    backend "azurerm" {
    resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "kv.tfstate"

     }
}

# Configure the Azure Provider
provider "azurerm" {
  // skip_provider_registration = true
  features {}
}


