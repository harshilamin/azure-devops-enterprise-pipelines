#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"
artifacts="${root}/.artifacts"
rm -rf "${artifacts}"
mkdir -p "${artifacts}/rendered"

echo '=== Python quality ==='
python -m ruff format --check .
python -m ruff check .
python -m mypy
python -m pytest
python scripts/validate_repository.py

echo '=== Shell syntax ==='
while IFS= read -r -d '' script; do bash -n "${script}"; done < <(find scripts -name '*.sh' -print0)

if command -v terraform >/dev/null 2>&1; then
  echo '=== Terraform ==='
  terraform fmt -check -recursive infra/terraform
  terraform -chdir=infra/terraform/live init -backend=false
  terraform -chdir=infra/terraform/live validate
else
  echo 'SKIP: Terraform is not installed.'
fi

if command -v helm >/dev/null 2>&1; then
  echo '=== Helm ==='
  chart=deploy/helm/pipeline-demo-api
  helm lint "${chart}" --strict
  for environment in dev qa prod; do
    helm lint "${chart}" --strict --values "${chart}/values-${environment}.yaml"
    helm template pipeline-demo "${chart}" \
      --namespace "pipeline-demo-${environment}" \
      --values "${chart}/values-${environment}.yaml" \
      --set image.repository=example.azurecr.io/pipeline-demo-api \
      --set image.digest=sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
      > "${artifacts}/rendered/pipeline-demo-${environment}.yaml"
    python scripts/validate_helm_manifests.py \
      --manifest "${artifacts}/rendered/pipeline-demo-${environment}.yaml" \
      --environment "${environment}"
  done
  helm package "${chart}" --destination "${artifacts}"
else
  echo 'SKIP: Helm is not installed.'
fi

if command -v mkdocs >/dev/null 2>&1; then
  echo '=== Documentation ==='
  mkdocs build --strict --site-dir "${artifacts}/site"
else
  echo 'SKIP: MkDocs is not installed.'
fi

echo 'Repository 3 validation passed.'
