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
