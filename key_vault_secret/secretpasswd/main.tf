resource "azurerm_key_vault_secret" "secret" {
  name         = var.name
  // name         = data.terraform_remote_state.acr.outputs.registry_username
  value        = var.value
  // value = data.terraform_remote_state.acr.outputs.registry_password
  key_vault_id = var.key_vault_id
  content_type = ""

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}