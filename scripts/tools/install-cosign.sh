#!/usr/bin/env bash
set -euo pipefail
version="${1:?Cosign version is required}"
arch="$(uname -m)"
case "${arch}" in
  x86_64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;;
esac
asset="cosign-linux-${arch}"
base="https://github.com/sigstore/cosign/releases/download/v${version}"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
curl -fsSL "${base}/${asset}" -o "${tmp}/cosign"
curl -fsSL "${base}/cosign_checksums.txt" -o "${tmp}/checksums.txt"
expected="$(grep " ${asset}$" "${tmp}/checksums.txt" | awk '{print $1}')"
actual="$(sha256sum "${tmp}/cosign" | awk '{print $1}')"
[[ -n "${expected}" && "${actual}" == "${expected}" ]] || {
  echo 'Cosign checksum verification failed.' >&2
  exit 1
}
sudo install -m 0755 "${tmp}/cosign" /usr/local/bin/cosign
cosign version
