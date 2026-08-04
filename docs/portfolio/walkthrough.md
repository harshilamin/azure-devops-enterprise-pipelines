# Portfolio walkthrough

## Ninety-second story

This repository demonstrates enterprise Azure DevOps YAML pipeline engineering. It uses reusable templates for application quality, immutable container release, AKS deployment, Terraform plan/apply, drift detection, security scanning, and rollback. Azure access uses Workload Identity Federation, Production requires both an agentless manual validation and Environment checks, and the application is built once and promoted by SHA-256 digest. The release bundle includes the digest, Buildx metadata, a Trivy report, a CycloneDX SBOM, and optional Cosign verification. Terraform publishes a binary plan and applies that exact approved artifact. The repository also includes branch-policy, Environment, variable-group, and service-connection bootstrap examples, plus local and CI contract validation.

## File sequence

1. `azure-pipelines.yml` — stage composition and Production tag gate.
2. `pipelines/templates/stages/deploy-aks.yml` — deployment job and immutable digest.
3. `pipelines/templates/stages/manual-validation.yml` — server job and no self-approval.
4. `pipelines/templates/jobs/container-release.yml` — Buildx, Trivy, Syft, Cosign.
5. `azure-pipelines-infrastructure.yml` — exact plan/apply and infrastructure Environment.
6. `terraform-oidc-environment.yml` — federated token mapping.
7. `azure-pipelines-drift.yml` — scheduled detailed-exit-code plan.
8. `azure-pipelines-rollback.yml` — known-good digest without rebuild.
9. `configure-branch-policies.sh` — protected-main controls.
10. `tests/pipeline_contracts` — executable architecture assertions.

## Closing statement

The important design is not the number of tasks. It is the separation of build, evidence, approval, promotion, deployment, and infrastructure state, with organization-owned controls that pipeline authors cannot bypass through the same YAML change.
