# Validation record — v1.0.0

The release package was validated before distribution.

## Executed during package creation

- Python bytecode compilation for `src`, `scripts`, and `tests`.
- 27 application and pipeline-contract tests.
- 96.83 percent application branch coverage.
- YAML and JSON syntax parsing.
- Helm values JSON Schema validation for Development, QA, and Production.
- MkDocs navigation-target validation.
- Reusable Azure Pipelines template-reference validation.
- Bash syntax validation for all shell scripts.
- Required-file, placeholder, and committed-secret-material checks.
- ZIP integrity and SHA-256 checksum verification.

## Included but not executed in the package environment

The repository validation wrappers and Azure DevOps pipelines also run:

- Ruff formatting and linting.
- mypy strict type checking.
- Helm strict lint, render, manifest-contract validation, Kubeconform, and package creation.
- Terraform format, initialization without a backend, and validation.
- Strict MkDocs site generation.

Those tools were not available in the package-generation environment. They are pinned or constrained in the repository and are executed by the included workstation wrappers and portfolio CI after installation.

## Requires your Azure DevOps organization and Azure subscription

Live Azure DevOps template expansion, Workload Identity Federation authentication, Environment approvals/checks, Azure Key Vault retrieval, ACR push, AKS deployment, Terraform remote state, and Terraform apply require organization-specific resources and permissions. These operations were not claimed as locally executed.
