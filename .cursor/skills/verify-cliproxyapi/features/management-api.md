# Management API

Management API lets an operator authenticate with the management secret and inspect runtime configuration such as client API keys without using the optional control-panel HTML asset.

## Sub-features

- `mgmt-missing` rejects `/v0/management/api-keys` without a management key.
- `mgmt-invalid` rejects `/v0/management/api-keys` with a wrong key.
- `mgmt-api-keys` returns the configured client API keys with a valid management key.
- `mgmt-config` returns a config snapshot with a valid management key.

## How to get to it (user POV)

- Call `GET /v0/management/api-keys` with `Authorization: Bearer <VERIFY_MGMT_KEY>`.
- Call `GET /v0/management/api-keys` with header `X-Management-Key: <VERIFY_MGMT_KEY>`.
- Call `GET /v0/management/config` with the same management authentication.
- Call those routes without a key or with a wrong key to observe rejection.

## Driving it with scripts/http

Preconditions:

- Verification instance is healthy (`scripts/doctor` PASS).
- Launch configured `remote-management.secret-key` to `VERIFY_MGMT_KEY` and `disable-control-panel: true`.

- **Missing key.** Call api-keys unauthenticated. Run `scripts/http --save management-api/missing.txt GET /v0/management/api-keys`. Expect HTTP `401` and a missing-key error.
- **Bearer success.** Read api-keys. Run `scripts/http --mgmt --save management-api/api-keys.txt GET /v0/management/api-keys`. HTTP `200` and body contains `VERIFY_API_KEY`.
- **Alternate header.** Repeat with `X-Management-Key`. Run `curl -sS -H "X-Management-Key: $VERIFY_MGMT_KEY" "$VERIFY_BASE_URL/v0/management/api-keys"` after `verify_load_meta`. Same JSON payload as Bearer.
- **Config snapshot.** Read config. Run `scripts/http --mgmt --save management-api/config.txt GET /v0/management/config`. HTTP `200` JSON config object.
- **Proof.** Save the successful `api-keys` and `config` responses. Confirm the api-keys list matches the launch key, not example templates.

## Gotchas

- Management routes are unregistered when no secret is configured (404). Verification launch always sets a secret.
- Remote non-localhost clients need `allow-remote: true`; verification binds `127.0.0.1` and keeps allow-remote false.
- Too many failed auth attempts can temporarily ban the client IP — use the correct `VERIFY_MGMT_KEY`.
- Do not treat `/management.html` panel download as required; launch disables the control panel asset path.
