output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.key_vault.id
  sensitive   = false
}

output "key_vault_name" {
  description = "Key Vault Name"
  value       = azurerm_key_vault.key_vault.name
  sensitive   = false
}

output "key_vault_url" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.key_vault.vault_uri
  sensitive   = false
}
