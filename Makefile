.PHONY: install format lint test validate helm terraform docs clean

install:
	python -m pip install -e '.[dev]'

format:
	python -m ruff format .
	python -m ruff check . --fix

lint:
	python -m ruff format --check .
	python -m ruff check .
	python -m mypy src scripts

test:
	python -m pytest

validate:
	./scripts/validate-repository.sh

helm:
	helm lint --strict deploy/helm/pipeline-demo-api

terraform:
	terraform -chdir=infra/terraform/live fmt -check -recursive
	terraform -chdir=infra/terraform/live init -backend=false
	terraform -chdir=infra/terraform/live validate

docs:
	mkdocs build --strict

clean:
	rm -rf .rendered .packaged reports site coverage.xml .coverage .pytest_cache .mypy_cache .ruff_cache
