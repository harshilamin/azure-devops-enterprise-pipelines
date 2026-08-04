# ADR — Environment checks outside YAML

- **Status:** Accepted
- **Date:** 2026-08-04

## Context

The repository needs an enterprise pattern that is understandable in a portfolio and extensible to production.

## Decision

Use Azure DevOps Environments for deployment authorization and history.

## Rationale

Approvals defined only in the same repository can be removed by a pipeline change. External checks preserve separation of duties.

## Consequences

- The decision is enforced through templates and contract tests.
- Organization-specific setup remains explicit.
- Production adopters can strengthen identity, networking, and governance without replacing the delivery model.
