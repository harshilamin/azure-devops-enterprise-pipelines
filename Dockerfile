# syntax=docker/dockerfile:1.7
FROM python:3.13.6-slim-bookworm AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    VIRTUAL_ENV=/opt/venv

RUN python -m venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /build
COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install --upgrade pip setuptools wheel \
    && pip install .

FROM python:3.13.6-slim-bookworm AS runtime

ARG APP_UID=10001
ARG APP_GID=10001

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH" \
    APP_PORT=8080

RUN groupadd --gid "$APP_GID" app \
    && useradd --uid "$APP_UID" --gid "$APP_GID" --no-create-home --shell /usr/sbin/nologin app

COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
USER app:app
EXPOSE 8080
STOPSIGNAL SIGTERM

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health/live', timeout=2)"

ENTRYPOINT ["pipeline-demo-api"]
