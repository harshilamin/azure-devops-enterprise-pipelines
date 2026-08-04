variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "acr_name" { type = string }
variable "key_vault_name" { type = string }
variable "environment" { type = string }
variable "pipeline_principal_object_id" { type = string }
variable "aks_kubelet_object_id" { type = string }
variable "public_network_access" { type = bool }
variable "tags" { type = map(string) }


variable "create_signing_key" {
  type        = bool
  description = "Create an RSA Key Vault key for optional Cosign signing."
  default     = false
}

variable "signing_key_name" {
  type        = string
  description = "Name of the optional Cosign signing key."
  default     = "cosign-signing-key"
}
