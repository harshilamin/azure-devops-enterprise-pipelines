"""Validate an OCI SHA-256 digest."""

from __future__ import annotations

import re
import sys

DIGEST_PATTERN = re.compile(r"^sha256:[0-9a-f]{64}$")


def is_valid_digest(value: str) -> bool:
    return DIGEST_PATTERN.fullmatch(value.strip()) is not None


def main() -> None:
    if len(sys.argv) != 2 or not is_valid_digest(sys.argv[1]):
        raise SystemExit("Expected digest in the form sha256:<64 lowercase hex characters>")
    print(sys.argv[1].strip())


if __name__ == "__main__":
    main()
