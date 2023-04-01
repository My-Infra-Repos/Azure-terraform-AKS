# Key Vault Secrets - ACR username & password
module "kv_secret_docker_username" {
  source = "./secretname"

  name         = "acr-docker-username"
  value        = data.terraform_remote_state.acr.outputs.registry_username
  key_vault_id = data.terraform_remote_state.kv.outputs.key_vault_id

//   depends_on = [module.keyvault.azurerm_key_vault_access_policy]
}




# Key Vault Secrets - ACR username & password
module "kv_secret_docker_password" {
  source = "./secretpasswd"

  name         = "acr-docker-password"
  value        = data.terraform_remote_state.acr.outputs.registry_password
  key_vault_id = data.terraform_remote_state.kv.outputs.key_vault_id

//   depends_on = [data.terraform_remote_state.kv.outputs.]
}

