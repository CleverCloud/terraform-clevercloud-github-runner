#!/usr/bin/env bash
# Run phase: register the runner, run it, and answer the platform health check on 8080.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

: "${GITHUB_URL:?GITHUB_URL is required}"
if [ -z "${GITHUB_TOKEN:-}" ] && [ -z "${RUNNER_TOKEN:-}" ]; then
  log "GITHUB_TOKEN or RUNNER_TOKEN is required"
  exit 1
fi

# The runner is .NET; don't depend on libicu being present.
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
export RUNNER_ALLOW_RUNASROOT=1

name="${RUNNER_NAME:-github-runner}-${INSTANCE_NUMBER:-0}"
cd "${RUNNER_DIR}"

# Already registered on this instance (process restart): RUNNER_TOKEN may have
# expired since, so keep the existing registration.
if [ -f .runner ]; then
  log "${name} already registered, skipping configuration"
else
  log "registering ${name} on ${GITHUB_URL}"
  config_args=(
    --unattended
    --replace
    --url "${GITHUB_URL}"
    --token "$(runner_token registration-token)"
    --name "${name}"
    --labels "${RUNNER_LABELS:-clever-cloud}"
    --work _work
  )
  [ -n "${RUNNER_GROUP:-}" ] && config_args+=(--runnergroup "${RUNNER_GROUP}")
  ./config.sh "${config_args[@]}"
fi

runner_pid=""
health_pid=""

cleanup() {
  log "stopping, unregistering ${name}"
  [ -n "${runner_pid}" ] && kill "${runner_pid}" 2>/dev/null || true
  [ -n "${health_pid}" ] && kill "${health_pid}" 2>/dev/null || true
  wait || true
  # A UI registration token can't remove the runner, only an API token can.
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    ./config.sh remove --token "$(runner_token remove-token)" || true
  fi
  exit "${1:-0}"
}
trap cleanup TERM INT

# Health check: Clever Cloud expects something listening on 0.0.0.0:8080.
mkdir -p "${RUNNER_DIR}/health"
echo ok > "${RUNNER_DIR}/health/index.html"
python3 -m http.server 8080 --bind 0.0.0.0 --directory "${RUNNER_DIR}/health" >/dev/null 2>&1 &
health_pid=$!

# Don't hand the admin token over to workflow jobs.
env -u GITHUB_TOKEN -u RUNNER_TOKEN ./run.sh &
runner_pid=$!

# Exit (and let the platform restart the instance) as soon as either process dies.
wait -n
log "runner or health check exited"
cleanup 1
