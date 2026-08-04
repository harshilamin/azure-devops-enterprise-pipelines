# Local validation

## Windows

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
powershell.exe -ExecutionPolicy Bypass -File .\scripts\validate-repository.ps1
```

## Linux or macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e '.[dev]'
./scripts/validate-repository.sh
```

## Full tool validation

When Terraform, Helm, and MkDocs are present, the wrapper also runs format/validate, strict chart rendering, manifest contract checks, packaging, and strict documentation build. When a tool is absent, the wrapper prints a clear skip and the GitHub/Azure pipeline performs the authoritative check.

Generated output is written to `.artifacts/` and is excluded from Git.
