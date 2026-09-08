---
name: verify-cliproxyapi
description: "Drive CLIProxyAPI's HTTP surface (OpenAI/Gemini/Claude-compatible proxy + Management API) the way a client does — launch an isolated instance, doctor it, exercise mapped routes with curl helpers, and capture response evidence. Use when proving proxy behavior, auth, model listing, management endpoints, or chat completions after code changes."
---

# Verify CLIProxyAPI

CLIProxyAPI is a Go HTTP proxy that exposes OpenAI/Gemini/Claude/Codex-compatible APIs plus a Management API. The primary user surface for verification is **HTTP** (curl). Secondary surfaces exist (`--tui` terminal UI, optional `/management.html` control panel) but are out of scope for this skill's default harness — drive the HTTP routes clients actually call.

Never drive a shared or pre-existing instance. Always launch an isolated run under `/tmp/cliproxyapi-verify-<RUN_ID>/`.

## Launch

Exact sequence from the repo root:

```bash
.cursor/skills/verify-cliproxyapi/scripts/launch
.cursor/skills/verify-cliproxyapi/scripts/doctor
```

What `scripts/launch` does:

1. Allocates `VERIFY_RUN_ID` and free ports on `127.0.0.1`.
2. Writes verification scaffolding config (not for production) with non-template `api-keys`, a management `secret-key`, `disable-control-panel: true`, isolated `auth-dir`, and an `openai-compatibility` provider aimed at a local mock upstream.
3. Builds `./cmd/server` into the run dir.
4. Starts `scripts/mock-upstream` then the proxy with `--config <run>/config.yaml --local-model`.
5. Ready when log contains `API server started successfully on: 127.0.0.1:<port>` **and** `GET /healthz` returns `{"status":"ok"}`.

Environment overrides (optional): `VERIFY_RUN_ID`, `VERIFY_HOST`, `VERIFY_PORT`, `VERIFY_MOCK_PORT`, `VERIFY_API_KEY`, `VERIFY_MGMT_KEY`, `VERIFY_MODEL_ALIAS`.

Teardown:

```bash
.cursor/skills/verify-cliproxyapi/scripts/cleanup
```

Cleanup kills only the PIDs recorded for this run and deletes the `run/` directory. Evidence under `evidence/` is preserved.

Isolation rules:

- One active verification run at a time (`.cursor/skills/verify-cliproxyapi/.active-run`). Launch refuses if that run's server PID is still alive.
- Do not use `config.example.yaml` api-keys (`your-api-key-1/2/3`) — they enable example-api-key safe mode and block `/v1/*`.
- Do not reuse the user's real `~/.cli-proxy-api` auth dir or production `config.yaml`.

## Doctor

```bash
.cursor/skills/verify-cliproxyapi/scripts/doctor
```

Read-only checks: server + mock PIDs alive, `/healthz` ok, `/` identity message `CLI Proxy API Server`, `/v1/models` with the verification API key lists `VERIFY_MODEL_ALIAS`, `/v0/management/api-keys` accepts the management key. Exit `0` only when all pass. Run doctor first whenever anything looks off.

## Drive

Prefer the HTTP helper (loads active-run metadata, attaches Bearer auth, can save evidence):

```bash
.cursor/skills/verify-cliproxyapi/scripts/http GET /healthz
.cursor/skills/verify-cliproxyapi/scripts/http --api GET /v1/models
.cursor/skills/verify-cliproxyapi/scripts/http --mgmt GET /v0/management/api-keys
.cursor/skills/verify-cliproxyapi/scripts/http --api --save chat-completions/response.txt \
  POST /v1/chat/completions \
  --json '{"model":"verify-mock","messages":[{"role":"user","content":"ping"}]}'
```

Stable handles (paths / headers), not UI coordinates:

| Handle | Meaning |
|--------|---------|
| `GET /healthz` | Liveness JSON `{"status":"ok"}` |
| `GET /` | Identity JSON with `"message":"CLI Proxy API Server"` |
| `Authorization: Bearer <VERIFY_API_KEY>` | Client access to `/v1/*`, `/v1beta/*`, etc. |
| `GET /v1/models` | OpenAI-style model list |
| `POST /v1/chat/completions` | OpenAI chat completions |
| `Authorization: Bearer <VERIFY_MGMT_KEY>` or `X-Management-Key` | Management API `/v0/management/*` |
| `GET /v0/management/api-keys` | Configured client API keys |
| `GET /v0/management/config` | Sanitized runtime config snapshot |

Read `features/README.md` and the matching feature file before driving. A proof that only hits one convenient entry point is incomplete when the map lists others.

## Evidence

Store proof under `/tmp/cliproxyapi-verify-<RUN_ID>/evidence/<feature-id>/` (also available as `VERIFY_EVIDENCE_DIR` after launch). Relative `--save` paths for `scripts/http` land there automatically.

Proof standards:

- Exercise real client routes (`/v1/...`, `/v0/management/...`), not internal setters or test-only hooks.
- Capture the request action and the resulting HTTP status + body (and a second confirming read for mutations).
- For chat completions, prove the mock upstream path by asserting assistant content `pong-from-mock` in the proxy response — that string only exists in `scripts/mock-upstream`.
- Do not treat unit tests or `go test` as user-path proof for this skill.
- Mocks are allowed only at the production boundary already modeled by `openai-compatibility` (external provider HTTP). Do not stub Gin handlers inside the process.

Suggested artifact names:

- `evidence/<feature>/request.env` — method, path, auth mode used
- `evidence/<feature>/response.txt` — status, headers, body from `scripts/http --save`
- `evidence/<feature>/notes.txt` — feature ID and entry points covered

## Cleanup

```bash
.cursor/skills/verify-cliproxyapi/scripts/cleanup
```

Kills the server and mock PIDs from the run's pid files only (never `pkill cli-proxy-api`). Removes `/tmp/cliproxyapi-verify-<RUN_ID>/run/`. Leaves `/tmp/cliproxyapi-verify-<RUN_ID>/evidence/` intact. Clears `.active-run` when it matches.

After cleanup, confirm evidence files still exist before declaring success.

## Helpers

All scripts are executable and live in `.cursor/skills/verify-cliproxyapi/scripts/`:

| Script | Invocation | Role |
|--------|------------|------|
| `launch` | `scripts/launch` | Build, write scaffolding config, start mock + proxy |
| `doctor` | `scripts/doctor` | Read-only readiness / ownership check |
| `http` | `scripts/http [--api\|--mgmt] [--save PATH] [--json BODY] METHOD /path` | Drive authenticated HTTP |
| `cleanup` | `scripts/cleanup` | Stop this run's processes; keep evidence |
| `mock-upstream` | started by `launch` | Local OpenAI-compat stub (`pong-from-mock`) |
| `common.sh` | sourced by the others | Paths, ports, active-run resolution |

## Feature map

See [features/README.md](features/README.md).
