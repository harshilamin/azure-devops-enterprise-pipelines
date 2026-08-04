# ADR — Template hierarchy

- **Status:** Accepted
- **Date:** 2026-08-04

## Context

The repository needs an enterprise pattern that is understandable in a portfolio and extensible to production.

## Decision

Use variables, steps, jobs, and stages as separate reuse boundaries.

## Rationale

A single large template would hide policy, while copied YAML would drift. Entry pipelines stay readable and implementation details remain testable.

## Consequences

- The decision is enforced through templates and contract tests.
- Organization-specific setup remains explicit.
- Production adopters can strengthen identity, networking, and governance without replacing the delivery model.
