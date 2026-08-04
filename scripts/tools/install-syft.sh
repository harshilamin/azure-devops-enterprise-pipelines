#!/usr/bin/env bash
set -euo pipefail
version="${1:?Syft version is required}"
arch="$(uname -m)"
case "${arch}" in
  x86_64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;;
esac
asset="syft_${version}_linux_${arch}.tar.gz"
base="https://github.com/anchore/syft/releases/download/v${version}"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
curl -fsSL "${base}/${asset}" -o "${tmp}/${asset}"
curl -fsSL "${base}/syft_${version}_checksums.txt" -o "${tmp}/checksums.txt"
(
  cd "${tmp}"
  grep " ${asset}$" checksums.txt | sha256sum --check --strict
  tar -xzf "${asset}" syft
)
sudo install -m 0755 "${tmp}/syft" /usr/local/bin/syft
syft version
