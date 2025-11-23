#!/usr/bin/env bash
set -euo pipefail

REPO="ChurchApps/FreeShow"
ASSET_PATTERN="x86_64.AppImage"

api="https://api.github.com/repos/${REPO}/releases/latest"

echo "Fetching latest release info from ${api}..." >&2

json="$(curl -sSL "${api}")"

tag="$(printf '%s' "${json}" | jq -r '.tag_name')"

if [ -z "${tag}" ] || [ "${tag}" = "null" ]; then
  echo "ERROR: Could not determine latest tag" >&2
  exit 1
fi

version="${tag#v}"

url="$(printf '%s' "${json}" | jq -r --arg pat "${ASSET_PATTERN}" '.assets[] | select(.name | test($pat)) | .browser_download_url' | head -n1)"

if [ -z "${url}" ] || [ "${url}" = "null" ]; then
  echo "ERROR: Could not find AppImage asset matching pattern '${ASSET_PATTERN}'" >&2
  exit 1
fi

echo "Latest version: ${version}"
echo "Asset URL: ${url}"

echo "Prefetching with nix-prefetch-url..." >&2
hash="$(nix-prefetch-url --type sha256 "${url}" 2>/dev/null | tail -n1)"

if [ -z "${hash}" ]; then
  echo "ERROR: Failed to compute sha256 hash with nix-prefetch-url" >&2
  exit 1
fi

echo "New sha256: ${hash}"

# Update version and sha256 in pkgs/freeshow.nix
sed -i -E \
  -e "s/version = \".*\";/version = \"${version}\";/" \
  -e "s#sha256 = \".*\";#sha256 = \"${hash}\";#" \
  pkgs/freeshow.nix

echo "pkgs/freeshow.nix updated."
