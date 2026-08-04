# Application promotion

## Standard release

1. Merge a reviewed change to `main`.
2. Quality gates create a release bundle and deploy the digest to Development.
3. The same bundle is promoted to QA.
4. Review QA smoke-test and Environment history.
5. Tag the reviewed commit with `v<major>.<minor>.<patch>`.
6. Review the vulnerability report, SBOM, digest, change record, and rollback target.
7. Complete agentless manual validation.
8. Complete the Production Environment check.
9. Verify the Production Helm rollout and smoke test.

## Build-once evidence

The digest in each environment deployment log must match `image-digest.txt` from the release bundle. No deployment template contains `docker build`.

## Failed promotion

Because Helm uses `--atomic`, a failed upgrade automatically rolls back that release attempt. Investigate the failed stage, correct source or configuration through a pull request, and run a new release. Do not edit the live Deployment to force success.
