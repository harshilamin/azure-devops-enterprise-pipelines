import pytest

from pipeline_demo.config import Settings


def test_defaults(monkeypatch: pytest.MonkeyPatch) -> None:
    for key in ("APP_PORT", "APP_ENVIRONMENT", "APP_VERSION", "COMMIT_SHA", "BUILD_ID"):
        monkeypatch.delenv(key, raising=False)
    settings = Settings.from_environment()
    assert settings.environment == "development"
    assert settings.port == 8080


def test_environment_values(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("APP_PORT", "9090")
    monkeypatch.setenv("APP_ENVIRONMENT", "QA")
    monkeypatch.setenv("APP_VERSION", "9.9.9")
    settings = Settings.from_environment()
    assert settings.port == 9090
    assert settings.environment == "qa"
    assert settings.version == "9.9.9"


@pytest.mark.parametrize("value", ["abc", "0", "65536"])
def test_invalid_port(monkeypatch: pytest.MonkeyPatch, value: str) -> None:
    monkeypatch.setenv("APP_PORT", value)
    with pytest.raises(ValueError, match="APP_PORT"):
        Settings.from_environment()


def test_invalid_environment(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("APP_ENVIRONMENT", "staging")
    with pytest.raises(ValueError, match="APP_ENVIRONMENT"):
        Settings.from_environment()
