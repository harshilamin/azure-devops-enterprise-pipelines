output "resource_group_name" {
  value = module.pipeline_foundation.resource_group_name
}

output "acr_name" {
  value = module.pipeline_foundation.acr_name
}

output "acr_login_server" {
  value = module.pipeline_foundation.acr_login_server
}

output "key_vault_name" {
  value = module.pipeline_foundation.key_vault_name
}

output "key_vault_uri" {
  value = module.pipeline_foundation.key_vault_uri
}


output "cosign_key_id" {
  value = module.pipeline_foundation.cosign_key_id
}

output "cosign_key_reference" {
  value = module.pipeline_foundation.cosign_key_reference
}
