# ADR — Workload Identity Federation

- **Status:** Accepted
- **Date:** 2026-08-04

## Context

The repository needs an enterprise pattern that is understandable in a portfolio and extensible to production.

## Decision

Use federated Azure Resource Manager service connections and short-lived tokens.

## Rationale

Stored client secrets create rotation, leakage, and ownership risk. WIF aligns Azure access with pipeline identity.

## Consequences

- The decision is enforced through templates and contract tests.
- Organization-specific setup remains explicit.
- Production adopters can strengthen identity, networking, and governance without replacing the delivery model.
