"""Run a temporary in-cluster smoke test against a Kubernetes Service."""

from __future__ import annotations

import argparse
import json
import subprocess
import time
from typing import Sequence


def run(command: Sequence[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, check=True, text=True, capture_output=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--namespace", required=True)
    parser.add_argument("--service", required=True)
    parser.add_argument("--path", default="/health/ready")
    parser.add_argument("--api-key", default="")
    parser.add_argument("--attempts", type=int, default=10)
    args = parser.parse_args()

    headers: list[str] = []
    if args.api_key:
        headers.extend(["-H", f"X-API-Key: {args.api_key}"])
    url = f"http://{args.service}{args.path}"
    pod_name = f"smoke-{int(time.time())}"
    command = [
        "kubectl",
        "run",
        pod_name,
        "--namespace",
        args.namespace,
        "--image",
        "curlimages/curl:8.16.0",
        "--restart",
        "Never",
        "--rm",
        "--attach",
        "--quiet",
        "--command",
        "--",
        "curl",
        "--fail",
        "--show-error",
        "--silent",
        "--retry",
        str(args.attempts),
        "--retry-connrefused",
        "--retry-delay",
        "3",
        *headers,
        url,
    ]
    result = run(command)
    output = result.stdout.strip()
    try:
        parsed = json.loads(output)
        print(json.dumps(parsed, indent=2))
    except json.JSONDecodeError:
        print(output)


if __name__ == "__main__":
    main()
