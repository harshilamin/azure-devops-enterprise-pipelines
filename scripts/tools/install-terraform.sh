#!/usr/bin/env bash
set -euo pipefail
version="${1:?Terraform version is required}"
arch="$(uname -m)"
case "${arch}" in
  x86_64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;;
esac
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
asset="terraform_${version}_${os}_${arch}.zip"
base="https://releases.hashicorp.com/terraform/${version}"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
curl --fail --silent --show-error --location "${base}/${asset}" --output "${tmp}/${asset}"
curl --fail --silent --show-error --location "${base}/terraform_${version}_SHA256SUMS" --output "${tmp}/SHA256SUMS"
(
  cd "${tmp}"
  grep " ${asset}$" SHA256SUMS | sha256sum --check --strict
  unzip -q "${asset}"
)
sudo install -m 0755 "${tmp}/terraform" /usr/local/bin/terraform
terraform version
