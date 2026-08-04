# Contributing

## Workflow

1. Create a branch using `feature/`, `fix/`, `docs/`, or `chore/`.
2. Keep pipeline-template changes small and reviewable.
3. Run `scripts/validate-repository.ps1` or `.sh`.
4. Open a pull request using the repository template.
5. Resolve all comments and wait for the blocking PR-validation pipeline.
6. Use squash merge unless release history requires otherwise.

## Commit examples

- `feat: add reusable AKS deployment stage`
- `fix: preserve terraform detailed exit code`
- `docs: clarify production approval checks`
- `chore: update pinned tool versions`

## Sensitive changes

Changes under `pipelines/templates`, `.azuredevops`, `scripts/bootstrap`, or `infra/terraform` should require platform-team review through CODEOWNERS or Azure Repos required-reviewer policies.
