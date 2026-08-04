from fastapi.testclient import TestClient

from pipeline_demo.config import Settings
from pipeline_demo.main import create_app


def test_root_contains_environment_and_version() -> None:
    client = TestClient(create_app(Settings(environment="qa", version="2.3.4")))
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["environment"] == "qa"
    assert response.json()["version"] == "2.3.4"


def test_health_endpoints() -> None:
    client = TestClient(create_app(Settings()))
    assert client.get("/health/live").json() == {"status": "live"}
    assert client.get("/health/ready").json() == {"status": "ready"}


def test_build_metadata() -> None:
    settings = Settings(environment="production", commit_sha="abc123", build_id="42")
    response = TestClient(create_app(settings)).get("/api/v1/build")
    assert response.status_code == 200
    assert response.json()["commitSha"] == "abc123"
    assert response.json()["buildId"] == "42"


def test_production_disables_openapi() -> None:
    client = TestClient(create_app(Settings(environment="production")))
    assert client.get("/docs").status_code == 404
    assert client.get("/openapi.json").status_code == 404


def test_non_production_exposes_openapi() -> None:
    client = TestClient(create_app(Settings(environment="development")))
    assert client.get("/openapi.json").status_code == 200
