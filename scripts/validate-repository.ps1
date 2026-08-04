[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root
$artifacts = Join-Path $root '.artifacts'
Remove-Item $artifacts -Recurse -Force -ErrorAction SilentlyContinue
New-Item (Join-Path $artifacts 'rendered') -ItemType Directory -Force | Out-Null

Write-Host '=== Python quality ==='
python -m ruff format --check .
if ($LASTEXITCODE -ne 0) { throw 'Ruff formatting failed.' }
python -m ruff check .
if ($LASTEXITCODE -ne 0) { throw 'Ruff linting failed.' }
python -m mypy
if ($LASTEXITCODE -ne 0) { throw 'mypy failed.' }
python -m pytest
if ($LASTEXITCODE -ne 0) { throw 'pytest failed.' }
python scripts/validate_repository.py
if ($LASTEXITCODE -ne 0) { throw 'Static validation failed.' }

if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Write-Host '=== Terraform ==='
    terraform fmt -check -recursive infra/terraform
    if ($LASTEXITCODE -ne 0) { throw 'Terraform format failed.' }
    terraform -chdir=infra/terraform/live init -backend=false
    if ($LASTEXITCODE -ne 0) { throw 'Terraform init failed.' }
    terraform -chdir=infra/terraform/live validate
    if ($LASTEXITCODE -ne 0) { throw 'Terraform validate failed.' }
}
else { Write-Host 'SKIP: Terraform is not installed.' }

if (Get-Command helm -ErrorAction SilentlyContinue) {
    Write-Host '=== Helm ==='
    $chart = 'deploy/helm/pipeline-demo-api'
    helm lint $chart --strict
    if ($LASTEXITCODE -ne 0) { throw 'Helm lint failed.' }
    foreach ($environment in @('dev', 'qa', 'prod')) {
        helm lint $chart --strict --values "$chart/values-$environment.yaml"
        if ($LASTEXITCODE -ne 0) { throw "Helm lint failed for $environment." }
        $manifest = Join-Path $artifacts "rendered/pipeline-demo-$environment.yaml"
        helm template pipeline-demo $chart `
            --namespace "pipeline-demo-$environment" `
            --values "$chart/values-$environment.yaml" `
            --set image.repository=example.azurecr.io/pipeline-demo-api `
            --set image.digest=sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa `
            | Out-File -FilePath $manifest -Encoding utf8
        if ($LASTEXITCODE -ne 0) { throw "Helm template failed for $environment." }
        python scripts/validate_helm_manifests.py --manifest $manifest --environment $environment
        if ($LASTEXITCODE -ne 0) { throw "Manifest validation failed for $environment." }
    }
    helm package $chart --destination $artifacts
    if ($LASTEXITCODE -ne 0) { throw 'Helm package failed.' }
}
else { Write-Host 'SKIP: Helm is not installed.' }

if (Get-Command mkdocs -ErrorAction SilentlyContinue) {
    Write-Host '=== Documentation ==='
    mkdocs build --strict --site-dir (Join-Path $artifacts 'site')
    if ($LASTEXITCODE -ne 0) { throw 'MkDocs build failed.' }
}
else { Write-Host 'SKIP: MkDocs is not installed.' }

Write-Host 'Repository 3 validation passed.'
