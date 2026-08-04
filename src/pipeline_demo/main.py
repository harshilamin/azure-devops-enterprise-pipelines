from __future__ import annotations

from fastapi import FastAPI
from fastapi.responses import JSONResponse

from pipeline_demo import __version__
from pipeline_demo.config import Settings


def create_app(settings: Settings | None = None) -> FastAPI:
    runtime = settings or Settings.from_environment()
    docs_url = None if runtime.environment == "production" else "/docs"
    openapi_url = None if runtime.environment == "production" else "/openapi.json"

    app = FastAPI(
        title="Azure DevOps Pipeline Demo API",
        version=runtime.version,
        docs_url=docs_url,
        openapi_url=openapi_url,
    )
    app.state.settings = runtime

    @app.get("/", tags=["application"])
    async def root() -> dict[str, str]:
        return {
            "service": "pipeline-demo-api",
            "status": "ok",
            "environment": runtime.environment,
            "version": runtime.version,
        }

    @app.get("/health/live", tags=["health"])
    async def live() -> dict[str, str]:
        return {"status": "live"}

    @app.get("/health/ready", tags=["health"])
    async def ready() -> dict[str, str]:
        return {"status": "ready"}

    @app.get("/api/v1/build", tags=["application"])
    async def build() -> JSONResponse:
        return JSONResponse(
            {
                "packageVersion": __version__,
                "releaseVersion": runtime.version,
                "commitSha": runtime.commit_sha,
                "buildId": runtime.build_id,
                "environment": runtime.environment,
            }
        )

    return app


app = create_app()
