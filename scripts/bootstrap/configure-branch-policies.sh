#!/usr/bin/env bash
set -euo pipefail
: "${AZDO_ORG_URL:?Set AZDO_ORG_URL}"
: "${AZDO_PROJECT:?Set AZDO_PROJECT}"
: "${AZDO_REPOSITORY_ID:?Set AZDO_REPOSITORY_ID}"
: "${PR_VALIDATION_BUILD_ID:?Set PR_VALIDATION_BUILD_ID}"
common=(--organization "${AZDO_ORG_URL}" --project "${AZDO_PROJECT}")
az repos policy approver-count create "${common[@]}" \
  --repository-id "${AZDO_REPOSITORY_ID}" \
  --branch main \
  --minimum-approver-count 2 \
  --creator-vote-counts false \
  --allow-downvotes false \
  --reset-on-source-push true \
  --blocking true \
  --enabled true
az repos policy build create "${common[@]}" \
  --repository-id "${AZDO_REPOSITORY_ID}" \
  --branch main \
  --build-definition-id "${PR_VALIDATION_BUILD_ID}" \
  --display-name 'Repository 3 PR validation' \
  --manual-queue-only false \
  --queue-on-source-update-only true \
  --valid-duration 0 \
  --blocking true \
  --enabled true
az repos policy work-item-linking create "${common[@]}" \
  --repository-id "${AZDO_REPOSITORY_ID}" \
  --branch main \
  --blocking true \
  --enabled true
az repos policy comment-required create "${common[@]}" \
  --repository-id "${AZDO_REPOSITORY_ID}" \
  --branch main \
  --blocking true \
  --enabled true
