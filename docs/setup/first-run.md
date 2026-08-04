# First pipeline run

## Safe sequence

1. Run local validation.
2. Push the repository to a feature branch.
3. Create the PR-validation pipeline and verify it independently.
4. Configure it as a blocking branch policy.
5. Create Development, QA, Production, and infrastructure Environments.
6. Create the federated service connection and variable groups.
7. Replace placeholder ACR, AKS, Key Vault, and Terraform backend variable-group values.
8. Run the infrastructure pipeline with `action=plan` for Development.
9. Run the application pipeline from a non-production branch and validate the release bundle.
10. Merge to `main` and validate Development and QA.
11. Create a `v1.0.0` tag only after Production checks are configured.

## Expected first failures

A complete reference repository cannot know your organization-specific names. The first cloud run should fail fast if placeholders remain. Correct names in variable groups and backend variable-group configuration rather than hard-coding them into templates.

## Evidence to capture

- PR policy result.
- WIF service-connection authentication.
- Release bundle digest, scan report, and SBOM.
- Azure DevOps Environment deployment history.
- Terraform plan and approval record.
- Production manual validation and environment approval.
