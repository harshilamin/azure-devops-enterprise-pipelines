#!/usr/bin/env bash
set -euo pipefail
organization="${AZDO_ORG_URL:?Set AZDO_ORG_URL}"
project="${AZDO_PROJECT:?Set AZDO_PROJECT}"
for name in pipeline-demo-dev pipeline-demo-qa pipeline-demo-prod infrastructure-dev infrastructure-qa infrastructure-prod; do
  existing="$(az devops invoke --organization "${organization}" --area distributedtask --resource environments --route-parameters project="${project}" --query-parameters name="${name}" --query 'value[0].id' -o tsv || true)"
  if [[ -z "${existing}" ]]; then
    az devops invoke --organization "${organization}" --area distributedtask --resource environments --route-parameters project="${project}" --http-method POST --in-file <(printf '{"name":"%s","description":"Managed deployment boundary"}' "${name}") >/dev/null
    echo "Created ${name}"
  else
    echo "Exists ${name} (${existing})"
  fi
done
