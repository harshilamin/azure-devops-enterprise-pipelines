"""Validate security and environment contracts in rendered Helm manifests."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any

import yaml


def documents(path: Path) -> list[dict[str, Any]]:
    content = path.read_text(encoding="utf-8")
    return [doc for doc in yaml.safe_load_all(content) if isinstance(doc, dict)]


def one(items: list[dict[str, Any]], kind: str) -> dict[str, Any]:
    matches = [item for item in items if item.get("kind") == kind]
    if len(matches) != 1:
        raise AssertionError(f"Expected one {kind}; found {len(matches)}")
    return matches[0]


def validate(path: Path, environment: str) -> None:
    items = documents(path)
    deployment = one(items, "Deployment")
    pod_spec = deployment["spec"]["template"]["spec"]
    container = pod_spec["containers"][0]
    security = container["securityContext"]
    pod_security = pod_spec["securityContext"]

    assert pod_security["runAsNonRoot"] is True
    assert pod_security["seccompProfile"]["type"] == "RuntimeDefault"
    assert security["allowPrivilegeEscalation"] is False
    assert security["readOnlyRootFilesystem"] is True
    assert security["capabilities"]["drop"] == ["ALL"]
    assert container["image"].count("@sha256:") == 1
    assert container["resources"]["requests"]
    assert container["resources"]["limits"]
    assert container["startupProbe"]["httpGet"]["path"] == "/health/live"
    assert container["readinessProbe"]["httpGet"]["path"] == "/health/ready"
    assert any(volume.get("name") == "tmp" for volume in pod_spec["volumes"])
    assert one(items, "NetworkPolicy")
    assert one(items, "Service")

    replicas = deployment["spec"]["replicas"]
    expected = {"dev": 1, "qa": 2, "prod": 3}[environment]
    assert replicas == expected, (environment, replicas, expected)
    pdbs = [item for item in items if item.get("kind") == "PodDisruptionBudget"]
    assert (environment == "dev" and not pdbs) or (environment != "dev" and len(pdbs) == 1)
    print(f"Validated {len(items)} resources for {environment}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--environment", choices=("dev", "qa", "prod"), required=True)
    args = parser.parse_args()
    validate(args.manifest, args.environment)


if __name__ == "__main__":
    main()
