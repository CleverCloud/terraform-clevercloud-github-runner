#!/usr/bin/env bash
# Build phase: download the actions runner.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

version="${RUNNER_VERSION:-latest}"
if [ "${version}" = "latest" ]; then
  version=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest \
    | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
fi

case "$(uname -m)" in
  x86_64) arch=x64 ;;
  aarch64) arch=arm64 ;;
  *) log "unsupported architecture $(uname -m)"; exit 1 ;;
esac

tarball="actions-runner-linux-${arch}-${version}.tar.gz"
log "installing actions/runner ${version} (${arch}) in ${RUNNER_DIR}"
rm -rf "${RUNNER_DIR}"
mkdir -p "${RUNNER_DIR}"
curl -fsSL -o "${RUNNER_DIR}/${tarball}" \
  "https://github.com/actions/runner/releases/download/v${version}/${tarball}"

if [ -n "${RUNNER_SHA256:-}" ]; then
  echo "${RUNNER_SHA256}  ${RUNNER_DIR}/${tarball}" | sha256sum -c -
fi

tar -xzf "${RUNNER_DIR}/${tarball}" -C "${RUNNER_DIR}"
rm "${RUNNER_DIR}/${tarball}"
