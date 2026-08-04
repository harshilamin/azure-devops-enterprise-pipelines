# v1.0.0 — Enterprise Azure DevOps Pipelines

This release completes Repository 3 of the DevOps portfolio.

## Highlights

- Enterprise Azure DevOps YAML application pipeline.
- Reusable stage, job, step, and variable templates.
- Protected pull-request validation.
- Build-once, promote-the-same-digest AKS delivery.
- Azure Workload Identity Federation service connections.
- Variable groups, Azure Key Vault, Environments, approvals, and checks.
- Terraform validation, plan, approved exact-plan apply, and drift detection.
- Immutable digest rollback.
- Trivy security gates, CycloneDX SBOM, optional Cosign Azure KMS signing.
- Complete application, Helm, Terraform, pipeline, governance, and documentation validation.

## Package validation

- Python compilation and 27 application/pipeline contract tests.
- 96.83 percent application branch coverage.
- YAML and JSON syntax validation.
- Helm values JSON Schema validation.
- MkDocs navigation validation.
- Bash syntax validation.
- Cross-platform wrappers for Ruff, mypy, Helm, Terraform, and strict MkDocs validation.

Helm, Terraform, Ruff, mypy, and MkDocs execution is performed by the included CI/workstation wrappers when those dependencies are installed. Live Azure operations require organization-specific resources.

## Requires your Azure DevOps organization

Live pipeline compilation, service-connection authentication, Environment approvals, ACR push, AKS deployment, Key Vault access, and Terraform apply require organization-specific resources and permissions.
