# Security model

## Identity

Azure access uses Azure Resource Manager service connections configured for Workload Identity Federation. No service-principal password is stored in Azure DevOps.

For Terraform, `AzureCLI@2` exposes `servicePrincipalId`, `idToken`, and `tenantId`. The template maps these to `ARM_CLIENT_ID`, `ARM_OIDC_TOKEN`, `ARM_TENANT_ID`, and the active subscription ID.

## Secrets

- Non-secret configuration lives in variable groups.
- Runtime-only secrets are fetched by `AzureKeyVault@2`.
- Secret values are not committed, published, or intentionally echoed.
- The sample smoke-test API key is optional.

## Artifact controls

- Production uses an OCI SHA-256 digest.
- Trivy blocks critical image vulnerabilities.
- Syft produces a CycloneDX SBOM.
- Buildx emits provenance and SBOM metadata.
- Optional Cosign signing and attestation use an Azure Key Vault key.

## Runtime controls

The sample Helm chart requires non-root execution, a read-only root filesystem, dropped Linux capabilities, RuntimeDefault seccomp, resource limits, probes, PDBs in QA/Production, and NetworkPolicy.

## Governance

- Two reviewers are recommended for `main`.
- The creator vote does not count.
- PR validation is a blocking build policy.
- Production validation prevents self-approval.
- Environment checks are controlled outside pipeline YAML.
