# Provides client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}

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

