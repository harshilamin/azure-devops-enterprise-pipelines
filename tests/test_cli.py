from __future__ import annotations

from typing import Any

from pipeline_demo import __main__


def test_main_starts_uvicorn(monkeypatch: Any) -> None:
    captured: dict[str, Any] = {}

    def fake_run(app: str, **kwargs: Any) -> None:
        captured["app"] = app
        captured.update(kwargs)

    monkeypatch.setenv("APP_PORT", "9090")
    monkeypatch.setattr(__main__.uvicorn, "run", fake_run)
    __main__.main()

    assert captured["app"] == "pipeline_demo.main:app"
    assert captured["host"] == "0.0.0.0"
    assert captured["port"] == 9090
    assert captured["proxy_headers"] is True
    assert captured["access_log"] is True
