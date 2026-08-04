# Security Policy

## Supported version

Version 1.0.x is the supported portfolio release.

## Reporting

Do not open a public issue containing a credential, tenant ID, subscription ID, private endpoint, or vulnerability exploit. Use a private security advisory or contact the repository owner directly.

## Repository rules

- Never commit PATs, service-principal secrets, kubeconfigs, `.env` files, Terraform state, or Key Vault values.
- Use Workload Identity Federation for Azure Resource Manager service connections.
- Restrict service connections and Environments to explicitly authorized pipelines.
- Require pull requests and a blocking validation policy on `main`.
- Deploy Production only by immutable image digest.
- Keep signing keys in Azure Key Vault and grant only the Key Vault Crypto User role to the build identity.
- Review generated SBOMs and vulnerability reports before promotion.
- Treat pipeline template changes as privileged code and require designated reviewers.
