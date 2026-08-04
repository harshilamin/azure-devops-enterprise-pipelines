from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts.parse_buildx_metadata import extract_digest
from scripts.validate_digest import is_valid_digest


def test_digest_validation() -> None:
    assert is_valid_digest("sha256:" + "a" * 64)
    assert not is_valid_digest("sha256:" + "A" * 64)
    assert not is_valid_digest("latest")


def test_extract_digest_from_buildx_metadata() -> None:
    digest = "sha256:" + "1" * 64
    assert extract_digest({"containerimage.digest": digest}) == digest


def test_extract_digest_rejects_missing_digest() -> None:
    with pytest.raises(ValueError):
        extract_digest({"containerimage.digest": "sha256:nope"})


def test_release_metadata_example_round_trip(tmp_path: Path) -> None:
    digest = "sha256:" + "2" * 64
    payload = {"repository": "example.azurecr.io/app", "digest": digest}
    target = tmp_path / "release.json"
    target.write_text(json.dumps(payload), encoding="utf-8")
    assert json.loads(target.read_text(encoding="utf-8"))["digest"] == digest
