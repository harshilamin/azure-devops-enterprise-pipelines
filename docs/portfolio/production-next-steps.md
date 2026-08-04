# Production next steps

| Portfolio implementation | Production evolution |
|---|---|
| One default WIF service connection | Separate plan, apply, ACR, signing, and AKS identities |
| Microsoft-hosted agents | Private ephemeral agents with controlled egress and network access |
| Example ACR/Key Vault module | Private endpoints, firewall rules, diagnostics, replication, retention, policy |
| Optional Cosign signing | Mandatory signing plus admission verification |
| Basic branch-policy bootstrap | Organization policy, required reviewers by path, centrally governed templates |
| Manual change-ticket variable | ServiceNow/Azure Boards check and automated evidence attachment |
| Static Helm validation | Ephemeral cluster integration and conformance tests |
| In-cluster curl smoke test | Synthetic tests, API contract tests, SLO-based progressive delivery |
| Scheduled drift plan | Central drift service, ownership routing, policy exceptions, reporting |
| Local template repository | Dedicated versioned pipeline-template repository with consumer pinning |

The portfolio deliberately keeps external dependencies approachable while documenting the stronger production model.
