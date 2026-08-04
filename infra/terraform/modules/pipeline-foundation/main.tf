data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_container_registry" "this" {
  name                          = var.acr_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = var.public_network_access
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = false
  tags                          = local.tags
}

resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = var.public_network_access
  tags                          = local.tags
}


resource "azurerm_key_vault_key" "cosign" {
  count = var.create_signing_key ? 1 : 0

  name         = var.signing_key_name
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 3072
  key_opts     = ["sign", "verify"]

  tags = local.tags
}

resource "azurerm_role_assignment" "pipeline_acr_push" {
  count = var.pipeline_principal_object_id == "" ? 0 : 1

  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = var.pipeline_principal_object_id
}

resource "azurerm_role_assignment" "pipeline_key_crypto" {
  count = var.pipeline_principal_object_id == "" ? 0 : 1

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = var.pipeline_principal_object_id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  count = var.aks_kubelet_object_id == "" ? 0 : 1

  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_kubelet_object_id
}
