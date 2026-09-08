#!/usr/bin/env bash
# Shared paths and helpers for verify-cliproxyapi.
# Source from other scripts:  . "$(dirname "$0")/common.sh"

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "${SKILL_DIR}/../../.." && pwd)"
SCRIPTS_DIR="${SKILL_DIR}/scripts"
ACTIVE_RUN_FILE="${SKILL_DIR}/.active-run"

DEFAULT_HOST="127.0.0.1"
DEFAULT_PORT_BASE=18317

verify_require_cmd() {
  local cmd
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "doctor/launch: missing required command: $cmd" >&2
      return 1
    fi
  done
}

verify_new_run_id() {
  date +%Y%m%d%H%M%S-"$$"
}

verify_resolve_run_id() {
  if [[ -n "${VERIFY_RUN_ID:-}" ]]; then
    printf '%s\n' "$VERIFY_RUN_ID"
    return 0
  fi
  if [[ -f "$ACTIVE_RUN_FILE" ]]; then
    tr -d '[:space:]' <"$ACTIVE_RUN_FILE"
    return 0
  fi
  echo "No active verification run. Export VERIFY_RUN_ID or run scripts/launch first." >&2
  return 1
}

verify_paths_for_run() {
  local run_id="$1"
  VERIFY_ROOT="/tmp/cliproxyapi-verify-${run_id}"
  VERIFY_RUN_DIR="${VERIFY_ROOT}/run"
  VERIFY_EVIDENCE_DIR="${VERIFY_ROOT}/evidence"
  VERIFY_CONFIG="${VERIFY_RUN_DIR}/config.yaml"
  VERIFY_AUTH_DIR="${VERIFY_RUN_DIR}/auth"
  VERIFY_LOG="${VERIFY_RUN_DIR}/server.log"
  VERIFY_MOCK_LOG="${VERIFY_RUN_DIR}/mock-upstream.log"
  VERIFY_META="${VERIFY_RUN_DIR}/meta.env"
  VERIFY_PID_FILE="${VERIFY_RUN_DIR}/server.pid"
  VERIFY_MOCK_PID_FILE="${VERIFY_RUN_DIR}/mock.pid"
  VERIFY_BIN="${VERIFY_RUN_DIR}/cli-proxy-api"
}

verify_load_meta() {
  local run_id
  run_id="$(verify_resolve_run_id)"
  verify_paths_for_run "$run_id"
  if [[ ! -f "$VERIFY_META" ]]; then
    echo "Missing run metadata: $VERIFY_META" >&2
    return 1
  fi
  # shellcheck disable=SC1090
  set -a
  # shellcheck disable=SC1090
  . "$VERIFY_META"
  set +a
  VERIFY_RUN_ID="$run_id"
}

verify_base_url() {
  printf 'http://%s:%s\n' "${VERIFY_HOST}" "${VERIFY_PORT}"
}

verify_pick_free_port() {
  local preferred="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$preferred" <<'PY'
import socket, sys
preferred = int(sys.argv[1])
for port in range(preferred, preferred + 200):
    s = socket.socket()
    try:
        s.bind(("127.0.0.1", port))
    except OSError:
        continue
    else:
        print(port)
        break
    finally:
        s.close()
else:
    raise SystemExit("no free port found")
PY
    return
  fi
  printf '%s\n' "$preferred"
}

verify_wait_http_ok() {
  local url="$1"
  local attempts="${2:-40}"
  local i
  for i in $(seq 1 "$attempts"); do
    if curl -sf "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.25
  done
  echo "Timed out waiting for $url" >&2
  return 1
}
