# Application delivery

## Main pipeline

`azure-pipelines.yml` performs these stages:

1. Application and repository quality, with optional SonarQube Cloud analysis.
2. Immutable container release.
3. Development deployment.
4. QA promotion of the same digest.
5. Production manual validation.
6. Production promotion of the same digest for `v*` tags only.

## Build once

Docker Buildx pushes one image and records the registry digest in `image-digest.txt`. The release bundle also contains:

- Buildx metadata.
- Release metadata JSON.
- Trivy image report.
- CycloneDX SBOM.
- Optional Cosign verification result.

Every deployment stage downloads this bundle and reads the digest. There is no image build in a deployment stage.

## Deployment mechanics

A deployment job targets an Azure DevOps Environment. Within `AzureCLI@2`, the pipeline:

1. Acquires AKS credentials through the federated service connection.
2. Creates the namespace idempotently.
3. Runs `helm upgrade --install` with the environment values file.
4. Overrides the image with the immutable digest.
5. Uses `--atomic`, `--wait`, and a ten-minute timeout.
6. Waits for the Deployment rollout.
7. Runs an in-cluster smoke test using a short-lived curl pod.

## Why a release bundle

A release bundle decouples build evidence from deployment execution. It makes the promoted identity explicit and allows QA, Production, audit, rollback, and incident review to reference the same digest and reports.
