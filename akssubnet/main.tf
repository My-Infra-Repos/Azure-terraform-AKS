# Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks-${var.app_name}"
  resource_group_name  = data.terraform_remote_state.rg.outputs.name
  // virtual_network_name = var.virtual_network_name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.name
  address_prefixes     = [var.kubernetes_address_space]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB", "Microsoft.EventHub", "Microsoft.ServiceBus", "Microsoft.AzureActiveDirectory", "Microsoft.Web"]
}

// resource "azurerm_subnet" "aci_aks_subnet" {
//   name                 = "aci-snet-aks-${var.app_name}"
//   resource_group_name  = data.terraform_remote_state.rg.outputs.name
//   // virtual_network_name = var.virtual_network_name
//   virtual_network_name = data.terraform_remote_state.vnet.outputs.name
//   address_prefixes     = [var.aci_address_space]
//     delegation {
//     name = "aciDelegation"
//     service_delegation {
//       name    = "Microsoft.ContainerInstance/containerGroups"
//       actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
//     }
//   }
// }
