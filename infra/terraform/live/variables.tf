variable "location" {
  type        = string
  description = "Azure region for the pipeline foundation."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "acr_name" {
  type        = string
  description = "Globally unique lowercase alphanumeric ACR name."
  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name must contain 5-50 lowercase alphanumeric characters."
  }
}

variable "key_vault_name" {
  type        = string
  description = "Globally unique Key Vault name."
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "key_vault_name must contain 3-24 alphanumeric or hyphen characters."
  }
}

variable "environment" {
  type        = string
  description = "Environment label."
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa, or prod."
  }
}

variable "pipeline_principal_object_id" {
  type        = string
  description = "Optional object ID of the Azure DevOps WIF identity."
  default     = ""
}

variable "aks_kubelet_object_id" {
  type        = string
  description = "Optional AKS kubelet managed identity object ID for AcrPull."
  default     = ""
}

variable "public_network_access" {
  type        = bool
  description = "Portfolio default. Disable after private endpoints and private agents are available."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}


variable "create_signing_key" {
  type        = bool
  description = "Create an optional Key Vault RSA key for Cosign."
  default     = false
}

variable "signing_key_name" {
  type        = string
  description = "Optional Cosign key name."
  default     = "cosign-signing-key"
}
