# Provides client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}

data "terraform_remote_state" "rg" {
  // backend = "remote"
  backend = "azurerm"
  config = {
    resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "rg.tfstate"

  }
}

data "terraform_remote_state" "vnet" {
  // backend = "remote"
  backend = "azurerm"
  config = {
    resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "vnet.tfstate"

  }
}

data "terraform_remote_state" "acr" {
  backend="azurerm"
  config={
    resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "acr.tfstate"
  }
}

data "terraform_remote_state" "kv" {
  backend="azurerm"
  config={
    resource_group_name   = "tfstate-prm-non-prod"
    storage_account_name  = "tfstprmaccount"
    container_name        = "tfstprmcontainer"
    key                   = "kv.tfstate"
  }
}