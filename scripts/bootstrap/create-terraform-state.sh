#!/usr/bin/env bash
set -euo pipefail
: "${TF_STATE_RESOURCE_GROUP:?Set TF_STATE_RESOURCE_GROUP}"
: "${TF_STATE_STORAGE_ACCOUNT:?Set TF_STATE_STORAGE_ACCOUNT}"
: "${AZURE_LOCATION:=eastus2}"
container="${TF_STATE_CONTAINER:-tfstate}"
az group create --name "${TF_STATE_RESOURCE_GROUP}" --location "${AZURE_LOCATION}" >/dev/null
az storage account create \
  --resource-group "${TF_STATE_RESOURCE_GROUP}" \
  --name "${TF_STATE_STORAGE_ACCOUNT}" \
  --location "${AZURE_LOCATION}" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --https-only true >/dev/null
az storage container create \
  --name "${container}" \
  --account-name "${TF_STATE_STORAGE_ACCOUNT}" \
  --auth-mode login >/dev/null
printf 'Terraform state container ready: %s/%s\n' "${TF_STATE_STORAGE_ACCOUNT}" "${container}"
