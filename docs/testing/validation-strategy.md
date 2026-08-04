# Validation strategy

The repository layers validation so a single green YAML parser is not mistaken for pipeline correctness.

| Layer | Checks |
|---|---|
| Python | Ruff, mypy, pytest, branch coverage |
| Application | Configuration validation, health endpoints, Production docs behavior |
| Pipeline | Entry points, trigger model, manual validation, artifact promotion, WIF, exact-plan apply, rollback |
| Helm | Strict lint, all environment renders, security and replica contracts |
| Terraform | Recursive format, init without backend, validate |
| Shell | Bash syntax for every script |
| Documentation | Strict MkDocs build and navigation |
| Supply chain | Critical vulnerability gate, SBOM, optional sign/attest/verify |

## Static versus live evidence

Static validation proves repository contracts. It does not prove Azure DevOps template expansion against your organization, Azure permissions, AKS connectivity, ACR access, Environment checks, or Key Vault access. The first-run guide separates these live validations.
