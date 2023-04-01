output "database-sumbent" {
  value = azurerm_subnet.prm-nonprod-db.name
}

output "database-sumbent-id" {
  value = azurerm_subnet.prm-nonprod-db.id
}

output "databse" {
  value     = azurerm_postgresql_flexible_server.prm-nonprod-db.name
}

output "azurerm-private-dns-zone"{
  value=azurerm_private_dns_zone.prm-nonprod-db.name
}

output "azurerm_private_dns_zone_virtual_network" {
  value=azurerm_private_dns_zone_virtual_network_link.prm-nonprod-db.id
}

output "azurerm_private_dns_zone_virtual_network_name" {
  value=azurerm_private_dns_zone_virtual_network_link.prm-nonprod-db.name
}