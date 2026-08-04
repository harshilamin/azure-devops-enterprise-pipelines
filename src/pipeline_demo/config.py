from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Settings:
    environment: str = "development"
    version: str = "1.0.0"
    commit_sha: str = "local"
    build_id: str = "local"
    port: int = 8080

    @classmethod
    def from_environment(cls) -> "Settings":
        raw_port = os.getenv("APP_PORT", "8080")
        try:
            port = int(raw_port)
        except ValueError as exc:
            raise ValueError("APP_PORT must be an integer") from exc
        if not 1 <= port <= 65535:
            raise ValueError("APP_PORT must be between 1 and 65535")

        environment = os.getenv("APP_ENVIRONMENT", "development").strip().lower()
        if environment not in {"development", "qa", "production"}:
            raise ValueError("APP_ENVIRONMENT must be development, qa, or production")

        return cls(
            environment=environment,
            version=os.getenv("APP_VERSION", "1.0.0").strip() or "1.0.0",
            commit_sha=os.getenv("COMMIT_SHA", "local").strip() or "local",
            build_id=os.getenv("BUILD_ID", "local").strip() or "local",
            port=port,
        )
