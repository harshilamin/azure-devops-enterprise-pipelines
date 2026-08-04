# Required Azure DevOps Environments

Create these Environments before the pipelines are first compiled from an external editor:

- `pipeline-demo-dev`
- `pipeline-demo-qa`
- `pipeline-demo-prod`
- `infrastructure-dev`
- `infrastructure-qa`
- `infrastructure-prod`

Recommended checks:

| Environment | Checks |
|---|---|
| Development | Restrict pipeline permissions; no manual approval |
| QA | Release Approvers group approval; business-hours check if required |
| Production | Release Approvers approval, exclusive lock, branch control, optional change-management check |
| Infrastructure | Environment-specific Platform Approvers; Production also requires exclusive lock |

Environment checks are configured in the Azure DevOps UI/API and intentionally are not controlled by pipeline YAML, so a pipeline author cannot bypass them in the same pull request.
