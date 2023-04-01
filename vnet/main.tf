# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = var.name
  address_space       = ["172.2.0.0/16"]
  location            = var.location
  resource_group_name = data.terraform_remote_state.rg.outputs.name
}
