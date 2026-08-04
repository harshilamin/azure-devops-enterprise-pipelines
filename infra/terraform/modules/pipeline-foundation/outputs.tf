output "resource_group_name" { value = azurerm_resource_group.this.name }
output "acr_name" { value = azurerm_container_registry.this.name }
output "acr_login_server" { value = azurerm_container_registry.this.login_server }
output "key_vault_name" { value = azurerm_key_vault.this.name }
output "key_vault_uri" { value = azurerm_key_vault.this.vault_uri }

output "cosign_key_id" {
  value = try(azurerm_key_vault_key.cosign[0].id, null)
}

output "cosign_key_reference" {
  value = var.create_signing_key ? "azurekms://${azurerm_key_vault.this.name}.vault.azure.net/${var.signing_key_name}" : null
}
