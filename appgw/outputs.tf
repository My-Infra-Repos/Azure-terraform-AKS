output "appgw_fqdn" {
  value       = azurerm_public_ip.public_ip.fqdn
  description = "FQDN of the Application Gateway / AKS Cluster."
}

output "appgw_name" {
  value       = azurerm_application_gateway.appgateway.name
  description = "Name of the Application Gateway used by AKS"
}

output "appgw_id" {
  value       = azurerm_application_gateway.appgateway.id
  description = "Name of the Application Gateway used by AKS"
}

output "azurerm_user_assigned_identity" {
    value       = azurerm_user_assigned_identity.agidentity.id
  description = "Name of the Application Gateway used by AKS"
}

output "azurerm_user_assigned_client_identity" {
    value       = azurerm_user_assigned_identity.agidentity.client_id
  description = "Name of the Application Gateway used by AKS"
}
