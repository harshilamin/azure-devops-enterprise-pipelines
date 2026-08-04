# Troubleshooting

## Pipeline cannot use an Environment

- Confirm the Environment exists before YAML compilation.
- Check pipeline permissions on the Environment.
- Check that the YAML name exactly matches the Environment.
- Confirm an approval/check is not waiting in another stage.

## WIF authentication fails

- Confirm service-connection authorization scheme is Workload Identity Federation.
- Compare the Azure DevOps issuer and subject with the Entra federated credential.
- Confirm audience is `api://AzureADTokenExchange`.
- Confirm the application/client ID and tenant are correct.
- Confirm the Azure role assignment is on the intended scope.

## Terraform plan succeeds but apply cannot use it

- Use the same Terraform version and operating system.
- Download the correct environment artifact.
- Confirm source revision matches the plan run.
- Initialize the same backend before apply.
- Do not modify Terraform configuration between plan and apply.

## Helm deployment fails

- Inspect `helm status` and `helm history`.
- Inspect Deployment events and pod logs.
- Verify the digest exists in ACR and AKS can pull it.
- Confirm the namespace and values file.
- Verify PDB, affinity, topology, requests, and NetworkPolicy do not block scheduling or smoke testing.

## Smoke test fails

- Confirm Service endpoints exist.
- Check DNS from the temporary curl pod.
- Check NetworkPolicy allows same-namespace traffic.
- Confirm the requested path exists for the environment.
- Confirm Key Vault secret retrieval if the API key is enabled.
