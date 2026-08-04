# Terraform pipeline foundation

This example creates a small Azure foundation used by the pipelines:

- Resource group.
- Premium Azure Container Registry with admin access disabled.
- Azure Key Vault using Azure RBAC and purge protection.
- Optional AcrPush, AcrPull, and Key Vault Crypto User assignments.

AKS is intentionally not created here. Repository 1 owns the enterprise AKS foundation. Replace all placeholder globally unique names before applying.

The Azure DevOps Terraform pipeline uses an Azure Resource Manager Workload Identity Federation service connection and applies the exact plan artifact produced earlier in the same run.
