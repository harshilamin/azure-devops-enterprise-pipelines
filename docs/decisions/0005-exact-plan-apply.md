# ADR — Exact Terraform plan apply

- **Status:** Accepted
- **Date:** 2026-08-04

## Context

The repository needs an enterprise pattern that is understandable in a portfolio and extensible to production.

## Decision

Publish the binary plan and apply the approved artifact without replanning.

## Rationale

An approval must correspond to a known change set. Replanning after approval can change the authorized action.

## Consequences

- The decision is enforced through templates and contract tests.
- Organization-specific setup remains explicit.
- Production adopters can strengthen identity, networking, and governance without replacing the delivery model.
