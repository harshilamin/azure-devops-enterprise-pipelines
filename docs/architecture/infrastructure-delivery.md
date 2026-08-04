# Infrastructure delivery

## Pipeline modes

`azure-pipelines-infrastructure.yml` accepts:

- `targetEnvironment`: `dev`, `qa`, or `prod`.
- `action`: `plan` or `apply`.

## Plan flow

1. Terraform format and validation run without a backend.
2. `AzureCLI@2` exposes the Workload Identity Federation token.
3. The task maps the token to Terraform OIDC environment variables.
4. Terraform initializes the environment backend from the Terraform variable group.
5. Terraform writes a binary plan and JSON plan summary.
6. Both files are published as an immutable pipeline artifact.

## Apply flow

An apply run adds an agentless `ManualValidation@1` gate. The apply deployment job targets `infrastructure-<environment>`, downloads the exact saved plan, initializes the same backend with the same Terraform version, and applies that plan without replanning.

## Drift detection

`azure-pipelines-drift.yml` runs on weekdays. Terraform detailed exit codes distinguish:

- `0`: no drift.
- `1`: planning failure.
- `2`: drift detected.

The default behavior fails on drift, making the scheduled run an actionable signal rather than a passive report.
