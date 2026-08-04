# Terraform drift detection

The scheduled drift pipeline runs Terraform plan with detailed exit codes for Development, QA, and Production.

## Response

| Result | Action |
|---|---|
| No drift | No action; retain run history |
| Planning error | Investigate identity, backend, provider, configuration, or Azure availability |
| Drift detected | Review JSON/plan output, identify authorized vs unauthorized change, reconcile through Terraform |

## Do not auto-apply drift

Automatic application of a drift plan can convert an unreviewed live change into the intended state or destroy emergency mitigation. The default repository behavior fails and requires human review.

## Emergency changes

Document the incident, make the smallest live change, then immediately create a Terraform pull request representing the intended final state. The next drift run should return clean.
