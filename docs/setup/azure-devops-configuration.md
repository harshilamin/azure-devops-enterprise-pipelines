# Azure DevOps organization configuration

## Pipelines

Create these pipeline definitions:

| Name | YAML path |
|---|---|
| Repo3 Application | `/azure-pipelines.yml` |
| Repo3 PR Validation | `/azure-pipelines-pr.yml` |
| Repo3 Infrastructure | `/azure-pipelines-infrastructure.yml` |
| Repo3 Drift | `/azure-pipelines-drift.yml` |
| Repo3 Rollback | `/azure-pipelines-rollback.yml` |
| Repo3 Security | `/azure-pipelines-security.yml` |

## Variable groups

Create and authorize:

- `pipeline-demo-build-config`
- `pipeline-demo-dev-config`
- `pipeline-demo-qa-config`
- `pipeline-demo-prod-config`
- `terraform-dev-config`
- `terraform-qa-config`
- `terraform-prod-config`

Use the examples under `.azuredevops/variable-groups/`. The build group can enable SonarQube Cloud after its Azure DevOps extension and service connection are configured. Keep secret values in Azure Key Vault rather than plain variable-group values.

## Environments

Create the six environments before first compilation. Configure pipeline permissions, approver groups, branch control, business-hours checks, exclusive locks, and change-management checks according to organizational policy.

## Branch policy

The bootstrap script demonstrates:

- Two minimum reviewers.
- No creator self-approval.
- Vote reset on source push.
- Blocking PR validation.
- Work-item linking.
- Resolved comments.

## Authorization

Restrict each variable group, environment, agent pool, and service connection to the pipelines that require it. Avoid “grant access permission to all pipelines” for sensitive production resources.
