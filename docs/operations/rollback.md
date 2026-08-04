# Immutable digest rollback

## Trigger

Run `azure-pipelines-rollback.yml` manually with:

- Target environment.
- Known-good digest in `sha256:<64 lowercase hex>` form.
- Incident number or rollback reason.

## Controls

- The digest is validated before deployment.
- A rollback evidence JSON file is published.
- Production uses manual validation and the Production Environment checks.
- The rollback uses the same Helm chart and environment values.
- The image is not rebuilt.

## Verification

1. Confirm the Helm deployment succeeds atomically.
2. Confirm the pod image ID contains the requested digest.
3. Run the in-cluster smoke test.
4. Confirm availability and latency recover.
5. Record the forward-fix owner and timeline.

## Forward fix

Rollback stabilizes service; it is not the final correction. Reproduce the defect, implement a reviewed fix, create a new immutable release, and promote it through the normal route.
