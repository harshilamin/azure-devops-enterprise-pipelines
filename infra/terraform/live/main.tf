module "pipeline_foundation" {
  source = "../modules/pipeline-foundation"

  location                     = var.location
  resource_group_name          = var.resource_group_name
  acr_name                     = var.acr_name
  key_vault_name               = var.key_vault_name
  environment                  = var.environment
  tags                         = var.tags
  pipeline_principal_object_id = var.pipeline_principal_object_id
  aks_kubelet_object_id        = var.aks_kubelet_object_id
  public_network_access        = var.public_network_access
  create_signing_key           = var.create_signing_key
  signing_key_name             = var.signing_key_name
}
