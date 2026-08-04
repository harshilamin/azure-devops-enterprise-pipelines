from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[2]


def load(path: str) -> dict[str, Any]:
    value = yaml.safe_load((ROOT / path).read_text(encoding="utf-8"))
    assert isinstance(value, dict)
    return value


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_all_pipeline_entry_points_exist() -> None:
    expected = {
        "azure-pipelines.yml",
        "azure-pipelines-pr.yml",
        "azure-pipelines-infrastructure.yml",
        "azure-pipelines-drift.yml",
        "azure-pipelines-rollback.yml",
        "azure-pipelines-security.yml",
    }
    assert all((ROOT / item).is_file() for item in expected)


def test_pr_pipeline_has_no_ci_trigger() -> None:
    pipeline = load("azure-pipelines-pr.yml")
    assert pipeline["trigger"] == "none"
    assert pipeline["pr"] == "none"


def test_main_pipeline_promotes_one_release_bundle() -> None:
    pipeline = text("azure-pipelines.yml")
    assert "Container_Release" in pipeline
    assert pipeline.count("releaseBundleArtifact") == 0  # referenced inside templates
    deployment = text("pipelines/templates/stages/deploy-aks.yml")
    assert "download: current" in deployment
    assert "image-digest.txt" in deployment
    assert "docker build" not in deployment


def test_manual_validation_is_agentless_and_prevents_self_approval() -> None:
    template = text("pipelines/templates/stages/manual-validation.yml")
    assert "pool: server" in template
    assert "ManualValidation@1" in template
    assert "allowApproversToApproveTheirOwnRuns: false" in template


def test_terraform_uses_workload_identity_federation() -> None:
    template = text("pipelines/templates/steps/terraform-oidc-environment.yml")
    assert "addSpnToEnvironment: true" in template
    for name in ("servicePrincipalId", "idToken", "tenantId"):
        assert name in template
    plan = text("pipelines/templates/jobs/terraform-plan.yml")
    assert "ARM_OIDC_TOKEN" in plan
    assert "ARM_USE_OIDC" in plan


def test_exact_plan_is_published_and_applied() -> None:
    infrastructure = text("azure-pipelines-infrastructure.yml")
    plan = text("pipelines/templates/jobs/terraform-plan.yml")
    assert "-out='$(Build.ArtifactStagingDirectory)/tfplan'" in plan
    assert "artifact: $(terraformPlanArtifact)" in plan
    assert "terraform -chdir='$(terraformRoot)' apply" in infrastructure
    assert "tfplan" in infrastructure


def test_optional_sonarqube_cloud_quality_gate() -> None:
    quality = text("pipelines/templates/jobs/application-quality.yml")
    for task in ("SonarCloudPrepare@4", "SonarCloudAnalyze@4", "SonarCloudPublish@4"):
        assert task in quality
    assert "sonarEnabled" in quality


def test_supply_chain_contains_required_controls() -> None:
    release = text("pipelines/templates/jobs/container-release.yml")
    for required in (
        "docker buildx build",
        "--provenance=true",
        "--sbom=true",
        "trivy image",
        "--severity CRITICAL",
        "syft",
        "cosign sign",
        "cosign attest",
        "cosign verify",
    ):
        assert required in release


def test_production_is_tag_gated_and_manually_validated() -> None:
    pipeline = text("azure-pipelines.yml")
    assert "startsWith(variables['Build.SourceBranch'], 'refs/tags/v')" in pipeline
    assert "Production_Approval" in pipeline
    assert "Deploy_Production" in pipeline


def test_rollback_requires_digest_and_does_not_rebuild() -> None:
    rollback = text("azure-pipelines-rollback.yml")
    assert "targetDigest" in rollback
    assert "validate_digest.py" in rollback
    assert "docker build" not in rollback


def test_secret_material_is_not_committed() -> None:
    forbidden = (
        "client" + "Secret",
        "servicePrincipal" + "Key",
        "BEGIN " + "PRIVATE KEY",
    )
    for path in ROOT.rglob("*"):
        if path.is_file() and ".git" not in path.parts:
            if path in {
                Path(__file__).resolve(),
                (ROOT / "scripts/validate_repository.py").resolve(),
            }:
                continue
            try:
                body = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            assert not any(item in body for item in forbidden), path
