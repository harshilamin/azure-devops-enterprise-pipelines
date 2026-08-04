#!/usr/bin/env bash
set -euo pipefail
: "${AZDO_ORG_URL:?Set AZDO_ORG_URL}"
: "${AZDO_PROJECT:?Set AZDO_PROJECT}"
: "${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID}"
: "${AZURE_SUBSCRIPTION_NAME:?Set AZURE_SUBSCRIPTION_NAME}"
: "${AZURE_TENANT_ID:?Set AZURE_TENANT_ID}"
: "${AZURE_CLIENT_ID:?Set AZURE_CLIENT_ID}"
name="${SERVICE_CONNECTION_NAME:-sc-azure-wif-platform}"
tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT
python - "${tmp}" <<'PYJSON'
import json, os, sys
payload = {
  "authorization": {
    "parameters": {
      "tenantid": os.environ["AZURE_TENANT_ID"],
      "serviceprincipalid": os.environ["AZURE_CLIENT_ID"],
      "authenticationType": "WorkloadIdentityFederation",
    },
    "scheme": "WorkloadIdentityFederation",
  },
  "data": {
    "subscriptionId": os.environ["AZURE_SUBSCRIPTION_ID"],
    "subscriptionName": os.environ["AZURE_SUBSCRIPTION_NAME"],
    "environment": "AzureCloud",
    "scopeLevel": "Subscription",
    "creationMode": "Manual",
  },
  "name": os.environ.get("SERVICE_CONNECTION_NAME", "sc-azure-wif-platform"),
  "type": "azurerm",
  "url": "https://management.azure.com/",
  "isShared": False,
  "isReady": True,
}
open(sys.argv[1], "w", encoding="utf-8").write(json.dumps(payload))
PYJSON
response="$(az devops service-endpoint create --organization "${AZDO_ORG_URL}" --project "${AZDO_PROJECT}" --service-endpoint-configuration "${tmp}" -o json)"
echo "${response}" | python -m json.tool
issuer="$(echo "${response}" | python -c 'import json,sys; print(json.load(sys.stdin)["authorization"]["parameters"]["workloadIdentityFederationIssuer"])')"
subject="$(echo "${response}" | python -c 'import json,sys; print(json.load(sys.stdin)["authorization"]["parameters"]["workloadIdentityFederationSubject"])')"
printf '\nCreate a Microsoft Entra federated identity credential with:\nIssuer: %s\nSubject: %s\nAudience: api://AzureADTokenExchange\n' "${issuer}" "${subject}"
