# Prerequisites

## Local tools

- Git.
- Python 3.12 or newer.
- PowerShell 7 or Bash.
- Helm, Terraform, Docker, and Azure CLI for full local/live testing.
- Azure DevOps CLI extension for bootstrap scripts.

## Azure resources

- Azure subscription and Microsoft Entra tenant.
- AKS cluster from Repository 1 or an equivalent cluster.
- Azure Container Registry.
- Azure Key Vault using Azure RBAC.
- Remote Terraform state storage account and container.
- A user-assigned identity or application registration used by the Azure DevOps WIF service connection.

## Azure DevOps objects

- Azure DevOps organization and project.
- Azure Repos Git repository.
- Six YAML pipelines created from the root entry points.
- Azure DevOps Environments listed in `.azuredevops/environments/README.md`.
- Build, deployment, and Terraform variable groups.
- Release Approvers and Platform Approvers groups.

## Required permissions

The federated principal should receive only the roles required by each pipeline. A portfolio lab may use one service connection, but a production design should separate read-only plan, infrastructure apply, image push/sign, and AKS deployment identities.
