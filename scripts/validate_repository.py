"""Static repository validation for local development and CI."""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

import yaml
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]


class MkDocsLoader(yaml.SafeLoader):
    """Safe loader that preserves MkDocs Python-name tags as strings."""


def _python_name(loader: yaml.Loader, suffix: str, node: yaml.Node) -> str:
    del loader, node
    return suffix


MkDocsLoader.add_multi_constructor(
    "tag:yaml.org,2002:python/name:",
    _python_name,
)
REQUIRED = (
    "README.md",
    "CHANGELOG.md",
    "RELEASE_NOTES_V1.0.0.md",
    "SETUP_V1.0.0.md",
    "SECURITY.md",
    "CONTRIBUTING.md",
    "mkdocs.yml",
    "azure-pipelines.yml",
    "azure-pipelines-pr.yml",
    "azure-pipelines-infrastructure.yml",
    "azure-pipelines-drift.yml",
    "azure-pipelines-rollback.yml",
    "azure-pipelines-security.yml",
    "pipelines/templates/stages/deploy-aks.yml",
    "pipelines/templates/stages/manual-validation.yml",
    "pipelines/templates/jobs/container-release.yml",
    "pipelines/templates/jobs/terraform-plan.yml",
    "deploy/helm/pipeline-demo-api/Chart.yaml",
    "deploy/helm/pipeline-demo-api/values.schema.json",
    "infra/terraform/live/main.tf",
    "docs/portfolio/walkthrough.md",
)


def yaml_documents() -> list[Path]:
    return sorted(
        path
        for path in ROOT.rglob("*")
        if path.is_file()
        and path.suffix.lower() in {".yml", ".yaml"}
        and not any(part in {".git", ".venv", ".artifacts"} for part in path.parts)
        and "deploy/helm/pipeline-demo-api/templates" not in path.as_posix()
    )


def assert_required_files() -> None:
    missing = [item for item in REQUIRED if not (ROOT / item).is_file()]
    if missing:
        raise AssertionError(f"Missing required files: {missing}")


def assert_yaml_syntax() -> None:
    for path in yaml_documents():
        try:
            if path.name == "mkdocs.yml":
                yaml.load(path.read_text(encoding="utf-8"), Loader=MkDocsLoader)
            else:
                list(yaml.safe_load_all(path.read_text(encoding="utf-8")))
        except yaml.YAMLError as error:
            raise AssertionError(f"Invalid YAML: {path.relative_to(ROOT)}: {error}") from error


def assert_json_syntax() -> None:
    for path in ROOT.rglob("*.json"):
        if any(part in {".git", ".venv", ".artifacts"} for part in path.parts):
            continue
        json.loads(path.read_text(encoding="utf-8"))


def assert_values_schema() -> None:
    chart = ROOT / "deploy/helm/pipeline-demo-api"
    schema = json.loads((chart / "values.schema.json").read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema)
    base = yaml.safe_load((chart / "values.yaml").read_text(encoding="utf-8"))
    assert isinstance(base, dict)
    for environment in ("dev", "qa", "prod"):
        overlay = yaml.safe_load((chart / f"values-{environment}.yaml").read_text(encoding="utf-8"))
        assert isinstance(overlay, dict)
        merged = deep_merge(base, overlay)
        errors = sorted(validator.iter_errors(merged), key=lambda item: list(item.path))
        if errors:
            raise AssertionError(f"Schema failure for {environment}: {errors[0].message}")


def deep_merge(left: dict[str, Any], right: dict[str, Any]) -> dict[str, Any]:
    result = dict(left)
    for key, value in right.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = value
    return result


def assert_mkdocs_nav() -> None:
    config = yaml.load(
        (ROOT / "mkdocs.yml").read_text(encoding="utf-8"),
        Loader=MkDocsLoader,
    )
    assert isinstance(config, dict)

    def paths(value: Any) -> list[str]:
        found: list[str] = []
        if isinstance(value, str):
            found.append(value)
        elif isinstance(value, list):
            for item in value:
                found.extend(paths(item))
        elif isinstance(value, dict):
            for item in value.values():
                found.extend(paths(item))
        return found

    missing = [
        item for item in paths(config.get("nav", [])) if not (ROOT / "docs" / item).is_file()
    ]
    if missing:
        raise AssertionError(f"MkDocs nav targets missing: {missing}")


def assert_template_references() -> None:
    """Ensure every local Azure Pipelines template reference resolves."""
    pattern = re.compile(r"^[ \t-]*template:[ \t]*['\"]?([^'\"\r\n#]+)", re.MULTILINE)
    missing: list[str] = []
    for path in yaml_documents():
        body = path.read_text(encoding="utf-8")
        for raw_reference in pattern.findall(body):
            reference = raw_reference.strip()
            if "@" in reference or "${{" in reference or "$[" in reference:
                continue
            reference = reference.split("?", maxsplit=1)[0].strip()
            target = (path.parent / reference).resolve()
            try:
                target.relative_to(ROOT.resolve())
            except ValueError:
                missing.append(f"{path.relative_to(ROOT)} -> {reference} (outside repository)")
                continue
            if not target.is_file():
                missing.append(f"{path.relative_to(ROOT)} -> {reference}")
    if missing:
        raise AssertionError(f"Missing local pipeline templates: {missing}")


def assert_no_placeholders_in_executable_defaults() -> None:
    allowed = {
        ROOT / "pipelines/templates/variables/global.yml",
        ROOT / ".azuredevops/service-connections/azure-wif.template.json",
        ROOT / ".azuredevops/variable-groups/build-config.example.yml",
        ROOT / ".azuredevops/variable-groups/environment-config.example.yml",
        ROOT / "scripts/validate_repository.py",
    }
    for path in ROOT.rglob("*"):
        if not path.is_file() or path in allowed:
            continue
        if any(part in {".git", ".venv", ".artifacts"} for part in path.parts):
            continue
        try:
            body = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if "replace-me" in body and path.suffix not in {".md"}:
            raise AssertionError(f"Unexpected executable placeholder: {path.relative_to(ROOT)}")


def assert_security_contracts() -> None:
    forbidden = re.compile(r"(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|servicePrincipalKey\s*[:=])")
    for path in ROOT.rglob("*"):
        excluded = any(part in {".git", ".venv", ".artifacts"} for part in path.parts)
        if not path.is_file() or excluded:
            continue
        if path == Path(__file__).resolve():
            continue
        try:
            body = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if forbidden.search(body):
            raise AssertionError(f"Potential committed secret material: {path.relative_to(ROOT)}")
    manual = (ROOT / "pipelines/templates/stages/manual-validation.yml").read_text(encoding="utf-8")
    assert "pool: server" in manual
    assert "allowApproversToApproveTheirOwnRuns: false" in manual
    deploy = (ROOT / "pipelines/templates/stages/deploy-aks.yml").read_text(encoding="utf-8")
    assert "image-digest.txt" in deploy
    assert "docker build" not in deploy


def main() -> None:
    assert_required_files()
    assert_yaml_syntax()
    assert_json_syntax()
    assert_values_schema()
    assert_mkdocs_nav()
    assert_template_references()
    assert_no_placeholders_in_executable_defaults()
    assert_security_contracts()
    print("Repository 3 static validation passed.")


if __name__ == "__main__":
    main()
