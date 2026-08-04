# ADR — Build once and promote by digest

- **Status:** Accepted
- **Date:** 2026-08-04

## Context

The repository needs an enterprise pattern that is understandable in a portfolio and extensible to production.

## Decision

Build one OCI image and promote its SHA-256 digest through all environments.

## Rationale

Rebuilding per environment can produce different bits from the same source and weakens rollback and audit evidence.

## Consequences

- The decision is enforced through templates and contract tests.
- Organization-specific setup remains explicit.
- Production adopters can strengthen identity, networking, and governance without replacing the delivery model.
