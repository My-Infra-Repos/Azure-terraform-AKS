resource "azurerm_public_ip_prefix" "nat_prefix" {
  name                = "pip-nat-aks-gw"
  resource_group_name = data.terraform_remote_state.rg.outputs.name
  location            = var.location
  ip_version          = "IPv4"
  prefix_length       = 29
  sku                 = "Standard"
  zones               = ["1"]
}
resource "azurerm_nat_gateway" "nat_gw_aks" {
  name                    = "natgw-aks-prm"
  resource_group_name     = data.terraform_remote_state.rg.outputs.name
  location                = var.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  nat_gateway_id      = azurerm_nat_gateway.nat_gw_aks.id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat_prefix.id

}

resource "azurerm_subnet_nat_gateway_association" "sn_cluster_nat_gw" {
  // subnet_id      = azurerm_subnet.cluster.id
  subnet_id= data.terraform_remote_state.akssubnet.outputs.aks_subnet_id
  nat_gateway_id = azurerm_nat_gateway.nat_gw_aks.id
}

output "gateway_ips" {
  value = azurerm_public_ip_prefix.nat_prefix.ip_prefix
}