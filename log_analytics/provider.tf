terraform {
  # Set the terraform required version
  required_version = ">= 0.14.8"

  # Register common providers
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.48.0"
    }

  }

  # Persist state in a storage account
     backend "azurerm" {
     resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "loganalytics.tfstate"

     }
}

# Configure the Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

