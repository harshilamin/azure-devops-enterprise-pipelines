"""Extract an immutable image digest from Docker Buildx metadata."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

DIGEST_RE = re.compile(r"^sha256:[0-9a-f]{64}$")


def extract_digest(metadata: dict[str, Any]) -> str:
    candidates = (
        metadata.get("containerimage.digest"),
        metadata.get("containerimage.config.digest"),
    )
    for candidate in candidates:
        if isinstance(candidate, str) and DIGEST_RE.fullmatch(candidate):
            return candidate
    descriptor = metadata.get("containerimage.descriptor")
    if isinstance(descriptor, dict):
        candidate = descriptor.get("digest")
        if isinstance(candidate, str) and DIGEST_RE.fullmatch(candidate):
            return candidate
    raise ValueError("Buildx metadata does not contain a valid sha256 digest")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata", type=Path, required=True)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--digest-output", type=Path, required=True)
    args = parser.parse_args()

    metadata = json.loads(args.metadata.read_text(encoding="utf-8"))
    digest = extract_digest(metadata)
    release = {
        "repository": args.repository,
        "digest": digest,
        "reference": f"{args.repository}@{digest}",
    }
    args.output.write_text(json.dumps(release, indent=2) + "\n", encoding="utf-8")
    args.digest_output.write_text(digest + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
