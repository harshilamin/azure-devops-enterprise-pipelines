# Azure DevOps Enterprise Pipelines

This repository is a complete portfolio reference for enterprise Azure DevOps YAML pipelines. It demonstrates application CI/CD, Terraform delivery, environment governance, immutable promotion, security gates, drift detection, and rollback.

## Core outcomes

- Reusable variables, step, job, and stage templates.
- Pull-request validation that can be configured as a blocking Azure Repos policy.
- Build-once, promote-the-same-digest deployment to Development, QA, and Production.
- Azure Resource Manager service connections using Workload Identity Federation.
- Azure DevOps Environments as deployment and approval boundaries.
- Terraform plan artifacts and exact-plan apply.
- Trivy vulnerability scanning, CycloneDX SBOM generation, and optional Cosign signing with Azure Key Vault.
- Cross-platform local validation and focused contract tests.

## Repository relationship

Repository 1 provisions the Azure foundation. Repository 2 demonstrates an AKS GitOps platform. This repository focuses specifically on Azure DevOps enterprise pipeline design and can deploy either its own sample workload or adapted workloads from the other repositories.

## Start here

1. Read the [architecture overview](architecture/overview.md).
2. Complete [prerequisites](setup/prerequisites.md).
3. Configure [Workload Identity Federation](setup/workload-identity-federation.md).
4. Create Azure DevOps [environments and variable groups](setup/azure-devops-configuration.md).
5. Run [local validation](testing/local-validation.md).
6. Follow the [first pipeline run](setup/first-run.md).
