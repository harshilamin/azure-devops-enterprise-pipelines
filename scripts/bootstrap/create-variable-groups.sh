#!/usr/bin/env bash
set -euo pipefail
: "${AZDO_ORG_URL:?Set AZDO_ORG_URL}"
: "${AZDO_PROJECT:?Set AZDO_PROJECT}"
: "${AZURE_SERVICE_CONNECTION:=sc-azure-wif-platform}"
: "${ACR_LOGIN_SERVER:?Set ACR_LOGIN_SERVER}"
: "${AKS_RESOURCE_GROUP:?Set AKS_RESOURCE_GROUP}"
: "${AKS_CLUSTER_NAME:?Set AKS_CLUSTER_NAME}"
: "${KEY_VAULT_NAME:?Set KEY_VAULT_NAME}"

: "${TF_STATE_RESOURCE_GROUP:?Set TF_STATE_RESOURCE_GROUP}"
: "${TF_STATE_STORAGE_ACCOUNT:?Set TF_STATE_STORAGE_ACCOUNT}"
: "${TF_STATE_CONTAINER:=tfstate}"
: "${PRODUCTION_APPROVERS:=[${AZDO_PROJECT}]\\Release Approvers}"
: "${INFRASTRUCTURE_APPROVERS:=[${AZDO_PROJECT}]\\Platform Approvers}"
: "${COSIGN_ENABLED:=false}"
: "${SONAR_ENABLED:=false}"
: "${SONAR_SERVICE_CONNECTION:=sonarcloud-enterprise}"
SONAR_ORGANIZATION="${SONAR_ORGANIZATION:-}"
SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-}"
: "${COSIGN_KEY_REFERENCE:=azurekms://${KEY_VAULT_NAME}.vault.azure.net/cosign-signing-key}"
common=(--organization "${AZDO_ORG_URL}" --project "${AZDO_PROJECT}")
create_or_update() {
  local name=$1; shift
  local id
  id="$(az pipelines variable-group list "${common[@]}" --query "[?name=='${name}'].id | [0]" -o tsv)"
  if [[ -z "${id}" ]]; then
    az pipelines variable-group create "${common[@]}" --name "${name}" --authorize false --variables "$@" >/dev/null
    echo "Created ${name}"
  else
    for pair in "$@"; do
      key="${pair%%=*}"; value="${pair#*=}"
      existing_variable="$(az pipelines variable-group variable list "${common[@]}" \
        --group-id "${id}" --query "contains(keys(@), '${key}')" -o tsv)"
      if [[ "${existing_variable}" == "true" ]]; then
        az pipelines variable-group variable update "${common[@]}" \
          --group-id "${id}" --name "${key}" --value "${value}" >/dev/null
      else
        az pipelines variable-group variable create "${common[@]}" \
          --group-id "${id}" --name "${key}" --value "${value}" >/dev/null
      fi
    done
    echo "Updated ${name}"
  fi
}
create_or_update pipeline-demo-build-config \
  acrServiceConnection="${AZURE_SERVICE_CONNECTION}" \
  acrLoginServer="${ACR_LOGIN_SERVER}" \
  imageRepository=pipeline-demo-api \
  cosignEnabled="${COSIGN_ENABLED}" \
  cosignKeyReference="${COSIGN_KEY_REFERENCE}" \
  productionApprovers="${PRODUCTION_APPROVERS}" \
  sonarEnabled="${SONAR_ENABLED}" \
  sonarServiceConnection="${SONAR_SERVICE_CONNECTION}" \
  sonarOrganization="${SONAR_ORGANIZATION}" \
  sonarProjectKey="${SONAR_PROJECT_KEY}" \
  changeTicket=PORTFOLIO-DEMO
for env in dev qa prod; do
  create_or_update "pipeline-demo-${env}-config" \
    azureServiceConnection="${AZURE_SERVICE_CONNECTION}" \
    acrLoginServer="${ACR_LOGIN_SERVER}" \
    imageRepository=pipeline-demo-api \
    aksResourceGroup="${AKS_RESOURCE_GROUP}" \
    aksClusterName="${AKS_CLUSTER_NAME}" \
    keyVaultName="${KEY_VAULT_NAME}" \
    productionApprovers="${PRODUCTION_APPROVERS}" \
    changeTicket=PORTFOLIO-DEMO
done

for env in dev qa prod; do
  create_or_update "terraform-${env}-config" \
    azureServiceConnection="${AZURE_SERVICE_CONNECTION}" \
    infrastructureApprovers="${INFRASTRUCTURE_APPROVERS}" \
    changeTicket=PORTFOLIO-DEMO \
    tfStateResourceGroup="${TF_STATE_RESOURCE_GROUP}" \
    tfStateStorageAccount="${TF_STATE_STORAGE_ACCOUNT}" \
    tfStateContainer="${TF_STATE_CONTAINER}" \
    tfStateKey="azure-devops-enterprise-pipelines-${env}.tfstate"
done
