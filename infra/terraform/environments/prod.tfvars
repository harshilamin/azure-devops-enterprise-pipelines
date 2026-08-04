location            = "southcentralus"
resource_group_name = "rg-ado-pipelines-prod"
acr_name             = "replaceadoacrprod01"
key_vault_name       = "kv-ado-pipelines-prd"
environment          = "prod"

# Replace with Azure object IDs after the WIF service connection and AKS exist.
pipeline_principal_object_id = ""
aks_kubelet_object_id        = ""
public_network_access        = true
create_signing_key           = false

tags = {
  owner       = "platform-engineering"
  cost-center = "portfolio"
}
