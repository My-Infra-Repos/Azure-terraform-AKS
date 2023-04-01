resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = data.terraform_remote_state.rg.outputs.name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true # Disable this in production
}