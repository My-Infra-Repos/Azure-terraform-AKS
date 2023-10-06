# Provides client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
# Subscription ID is required for AGIC
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

data "terraform_remote_state" "acr" {
  backend="azurerm"
  config={
    resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "acr.tfstate"
  }
}

data "terraform_remote_state" "kv" {
  backend="azurerm"
  config={
    resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "kv.tfstate"
  }
}

data "terraform_remote_state" "kvs" {
  backend="azurerm"
  config={
    resource_group_name   = "tfstate-example-non-prod"
    storage_account_name  = "tfstexampleaccount"
    container_name        = "tfstexamplecontainer"
    key                   = "kvsecret.tfstate"
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