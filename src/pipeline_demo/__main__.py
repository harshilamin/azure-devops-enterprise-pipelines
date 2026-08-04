from __future__ import annotations

import uvicorn

from pipeline_demo.config import Settings


def main() -> None:
    settings = Settings.from_environment()
    uvicorn.run(
        "pipeline_demo.main:app",
        host="0.0.0.0",
        port=settings.port,
        proxy_headers=True,
        access_log=True,
    )


if __name__ == "__main__":
    main()
