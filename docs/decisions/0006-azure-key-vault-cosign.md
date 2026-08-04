# ADR — Azure Key Vault Cosign signing

- **Status:** Accepted
- **Date:** 2026-08-04

## Context

The repository needs an enterprise pattern that is understandable in a portfolio and extensible to production.

## Decision

Use an Azure Key Vault key through `azurekms://` for optional image signing and attestation.

## Rationale

A managed key avoids long-lived private signing material in source control or pipeline variables.

## Consequences

- The decision is enforced through templates and contract tests.
- Organization-specific setup remains explicit.
- Production adopters can strengthen identity, networking, and governance without replacing the delivery model.
