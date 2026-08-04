# Platform overview

## Delivery architecture

```mermaid
flowchart LR
    A[Feature branch] --> B[Pull request]
    B --> C[PR validation]
    C --> D[Protected main]
    D --> E[Quality gates]
    E --> F[Build image once]
    F --> G[Trivy and SBOM]
    G --> H[Optional Cosign sign]
    H --> I[Release bundle]
    I --> J[Development]
    J --> K[QA]
    K --> L[Manual validation]
    L --> M[Production]

    N[Terraform source] --> O[Terraform plan]
    O --> P[Plan artifact]
    P --> Q[Approval]
    Q --> R[Exact plan apply]
```

## Control planes

| Control plane | Responsibility |
|---|---|
| Azure Repos | Protected source, review history, branch policies |
| Azure Pipelines | Template expansion, quality gates, artifact creation, orchestration |
| Azure DevOps Environments | Deployment history, permissions, approvals, checks, exclusive locks |
| Azure service connections | Federated Azure access without a stored client secret |
| ACR | Immutable OCI image and related supply-chain artifacts |
| AKS | Runtime target for the Helm release |
| Azure Key Vault | Runtime secrets and optional Cosign signing key |
| Terraform backend | Remote state with Azure AD authorization and locking |

## Trust boundaries

- Pipeline YAML can request deployment, but environment checks are controlled outside the YAML.
- The release bundle contains a digest and evidence, never a mutable tag as the deployment identity.
- Azure tokens are short lived and available only inside the relevant task.
- Secrets are fetched from Key Vault at runtime and are not written to source control.
- Production requires a release tag, manual validation, and Azure DevOps Environment authorization.
