#!/usr/bin/env bash
set -euo pipefail
version="${1:?Trivy version is required}"
arch="$(uname -m)"
case "${arch}" in
  x86_64) arch=64bit ;;
  aarch64|arm64) arch=ARM64 ;;
  *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;;
esac
asset="trivy_${version}_Linux-${arch}.tar.gz"
base="https://github.com/aquasecurity/trivy/releases/download/v${version}"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
curl -fsSL "${base}/${asset}" -o "${tmp}/${asset}"
curl -fsSL "${base}/trivy_${version}_checksums.txt" -o "${tmp}/checksums.txt"
(
  cd "${tmp}"
  grep " ${asset}$" checksums.txt | sha256sum --check --strict
  tar -xzf "${asset}" trivy
)
sudo install -m 0755 "${tmp}/trivy" /usr/local/bin/trivy
trivy --version
