#!/usr/bin/env bash
# Shared helpers for build.sh and start.sh.

RUNNER_DIR="${RUNNER_DIR:-${APP_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/.runner}"

log() { echo "[github-runner] $*" >&2; }

# GitHub API base URL for GITHUB_URL's host (github.com or GHES).
github_api() {
  local host
  host=$(echo "${GITHUB_URL}" | cut -d/ -f3)
  if [ "${host}" = "github.com" ]; then
    echo "https://api.github.com"
  else
    echo "https://${host}/api/v3"
  fi
}

# API path of the runner scope: /repos/owner/repo or /orgs/org.
github_scope() {
  local path
  path=$(echo "${GITHUB_URL%/}" | cut -d/ -f4-)
  if [[ "${path}" == */* ]]; then
    echo "/repos/${path}"
  else
    echo "/orgs/${path}"
  fi
}

# Request a short-lived token: kind is registration-token or remove-token.
# Without GITHUB_TOKEN, fall back to the RUNNER_TOKEN given by the GitHub UI.
runner_token() {
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "${RUNNER_TOKEN:?GITHUB_TOKEN or RUNNER_TOKEN is required}"
    return
  fi
  curl -fsSL -X POST \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "$(github_api)$(github_scope)/actions/runners/$1" \
    | sed -n 's/.*"token": *"\([^"]*\)".*/\1/p'
}
