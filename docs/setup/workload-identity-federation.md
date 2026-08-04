# Workload Identity Federation service connection

## Objective

Create an Azure Resource Manager service connection that receives short-lived tokens through federation instead of storing a service-principal secret.

## Automated starting point

Set the required environment variables and run:

```bash
./scripts/bootstrap/create-wif-service-connection.sh
```

The script calls `az devops service-endpoint create`, then prints the issuer and subject returned by Azure DevOps. Create a Microsoft Entra federated identity credential with:

- The returned issuer.
- The returned subject.
- Audience `api://AzureADTokenExchange`.

## Terraform token mapping

The `terraform-oidc-environment.yml` template uses `AzureCLI@2` with `addSpnToEnvironment: true`. It exports:

```text
ARM_CLIENT_ID
ARM_TENANT_ID
ARM_OIDC_TOKEN
ARM_SUBSCRIPTION_ID
ARM_USE_OIDC=true
ARM_USE_AZUREAD=true
```

The variables are marked secret for the remainder of the job.

## Recommended identity separation

| Identity | Scope |
|---|---|
| Terraform plan | Read access to managed scopes and state |
| Terraform apply | Contributor-equivalent custom role plus role-assignment permissions only where needed |
| Container release | ACR push and optional Key Vault Crypto User |
| AKS deploy | Cluster user access and namespace-scoped Kubernetes authorization |

The single-service-connection default keeps the portfolio setup approachable; the documentation makes the production separation explicit.
