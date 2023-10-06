# Provides client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "terraform_remote_state" "rg" {
  // backend = "remote"
  backend = "azurerm"
  config = {
    resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "rg.tfstate"

  }
}

data "terraform_remote_state" "vnet" {
  // backend = "remote"
  backend = "azurerm"
  config = {
    resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "vnet.tfstate"

  }
}

data "terraform_remote_state" "aks" {
  backend="azurerm"
  config={
    resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "aks.tfstate"
  }
}



data "terraform_remote_state" "appgateway" {
  backend="azurerm"
  config={
    resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "appgateway.tfstate"
  }
}