# Interview questions

## Why use templates at variables, step, job, and stage levels?

Each level removes a different type of duplication. Variables centralize versions and paths. Steps standardize tool setup and commands. Jobs define independent quality or release units. Stages express promotion and approval boundaries. Entry pipelines remain readable and policy-focused.

## How do you prove build once, promote many?

The container release job writes the registry digest to a release-bundle artifact. Every deployment downloads that artifact and sets Helm `image.digest`. Deployment templates contain no build command, and contract tests assert that property.

## Why use both ManualValidation and Environment approvals?

Manual validation captures release-specific review inside the run and prevents requester self-approval. Environment checks are owned outside YAML, so the same pull request cannot remove the final deployment authorization. They provide defense in depth and different ownership boundaries.

## How does Terraform authenticate without a secret?

`AzureCLI@2` uses the WIF service connection and exposes a short-lived ID token. The template maps it to Terraform Azure provider and backend OIDC variables. The token exists only during the job.

## Why publish and apply an exact plan?

An approval should authorize a known change, not permission to calculate a different change later. The pipeline publishes the binary plan and JSON evidence, then the apply stage downloads and applies that exact artifact with the same Terraform version.

## Why fail on drift instead of automatically repairing it?

Drift can represent an emergency fix, malicious change, or stale Terraform. Automatic repair may remove a mitigation or legitimize an unreviewed change. Failing the run creates a review point before reconciliation.

## Why use Azure Key Vault for Cosign?

A Key Vault key keeps signing material out of the repository and Azure DevOps secret storage. The federated pipeline identity can receive Key Vault Crypto User at the vault or key scope and use the `azurekms://` reference.

## What would change in production?

Use separate identities by responsibility, private agents/network paths, custom Azure roles, signed-image admission, externalized policy templates, centralized observability, change-management integration, ephemeral AKS tests, and organization-level template governance.
