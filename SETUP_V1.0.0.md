# Repository 3 setup — v1.0.0

This repository is a complete portfolio reference. The source, templates, documentation, tests, and bootstrap assets are included. Azure DevOps organization resources and Azure subscription values must be supplied before live deployment.

## 1. Create the Git repository

```powershell
git init
git branch -M main
git add .
git commit -m "feat: release Azure DevOps enterprise pipelines v1.0.0"
git remote add origin https://github.com/harshilamin/azure-devops-enterprise-pipelines.git
git push -u origin main
```

## 2. Validate locally

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
python -m pip install -r requirements-docs.txt
python -m ruff format --check .
python -m ruff check .
python -m mypy
python -m pytest
powershell.exe -ExecutionPolicy Bypass -File .\scripts\validate-repository.ps1
```

Linux/macOS:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e '.[dev]'
python -m pip install -r requirements-docs.txt
./scripts/validate-repository.sh
```

## 3. Replace organization-specific values

Review these files first:

- `pipelines/templates/variables/global.yml`
- `.azuredevops/variable-groups/*.example.yml`
- `.azuredevops/service-connections/azure-wif.template.json`
- `infra/terraform/environments/*.tfvars`
- `infra/terraform/backend/*.hcl.example`

Supply real values for Azure DevOps organization/project, Azure subscription and tenant, ACR, AKS resource group/cluster, Key Vault, Terraform state, approvers, and optional SonarQube Cloud or Cosign configuration.

## 4. Create Azure DevOps resources

Use the bootstrap scripts or follow the documentation manually:

```bash
./scripts/bootstrap/create-environments.sh
./scripts/bootstrap/create-variable-groups.sh
./scripts/bootstrap/create-wif-service-connection.sh
./scripts/bootstrap/configure-branch-policies.sh
./scripts/bootstrap/create-terraform-state.sh
```

PowerShell environment creation is also available:

```powershell
powershell.exe -ExecutionPolicy Bypass `
  -File .\scripts\bootstrap\create-environments.ps1
```

Read:

- `docs/setup/prerequisites.md`
- `docs/setup/azure-devops-configuration.md`
- `docs/setup/workload-identity-federation.md`
- `docs/setup/first-run.md`

## 5. Create six Azure Pipelines

Create pipelines from:

1. `azure-pipelines-pr.yml`
2. `azure-pipelines.yml`
3. `azure-pipelines-infrastructure.yml`
4. `azure-pipelines-drift.yml`
5. `azure-pipelines-rollback.yml`
6. `azure-pipelines-security.yml`

Configure `azure-pipelines-pr.yml` as a required build-validation policy on `main`. Authorize each pipeline only for the service connections, variable groups, Environments, and repositories it needs.

## 6. Protect deployment resources

- Add approval/checks to QA and Production Environments.
- Restrict the Production Environment and Production service connection to authorized pipelines and operators.
- Add approval/checks for Terraform apply Environments.
- Keep `allowApproversToApproveTheirOwnRuns: false` in the Production ManualValidation stage.

## 7. First safe execution order

1. Run the PR pipeline.
2. Run the security pipeline.
3. Run the infrastructure pipeline with `applyChanges: false` for Development.
4. Review and apply the exact saved Terraform plan.
5. Run the main application pipeline from `main` through Development and QA.
6. Create a `v1.0.0` tag only after non-production validation is green.
7. Approve and observe Production deployment.
8. Test rollback with a known-good digest in a non-production environment before relying on it operationally.

## 8. Tag and publish

```powershell
git tag -a v1.0.0 -m "Release v1.0.0: Azure DevOps enterprise pipelines"
git push origin v1.0.0
```

Create a GitHub release using `RELEASE_NOTES_V1.0.0.md`.
