# Client auth and models

Client auth and models let an API client authenticate with a configured top-level API key and discover models exposed by the proxy, including openai-compatibility aliases.

## Sub-features

- `auth-missing` rejects `/v1/models` without a Bearer token.
- `auth-invalid` rejects `/v1/models` with a wrong Bearer token.
- `auth-valid` accepts `/v1/models` with `VERIFY_API_KEY`.
- `models-list` returns the verification model alias from the openai-compatibility provider.

## How to get to it (user POV)

- Call `GET /v1/models` without `Authorization`.
- Call `GET /v1/models` with `Authorization: Bearer <wrong-key>`.
- Call `GET /v1/models` with `Authorization: Bearer <VERIFY_API_KEY>`.

## Driving it with scripts/http

Preconditions:

- Verification instance is healthy (`scripts/doctor` PASS).
- `VERIFY_MODEL_ALIAS` defaults to `verify-mock` from launch metadata.

- **Missing key.** Call models with no auth. Run `scripts/http --save client-auth-and-models/missing.txt GET /v1/models`. Expect non-zero exit from `scripts/http` and HTTP `401` with body mentioning a missing API key.
- **Invalid key.** Call models with a wrong key. Run `curl -sS -D - -o evidence/client-auth-and-models/invalid.body.json -w '\nHTTP %{http_code}\n' -H 'Authorization: Bearer definitely-wrong-key' "$VERIFY_BASE_URL/v1/models"` after loading meta (`verify_load_meta`). Expect HTTP `401`.
- **Valid key + list.** Call models with the verification key. Run `scripts/http --api --save client-auth-and-models/models.txt GET /v1/models`. HTTP `200`, body `"object":"list"`, and a data item `"id":"verify-mock"` (or current `VERIFY_MODEL_ALIAS`).
- **Proof.** Save missing, invalid, and valid responses. The valid list must include the alias that chat completions will call.

## Gotchas

- `scripts/http` without `--api` intentionally omits the Bearer header — use that for the missing-key case.
- `scripts/http` exits non-zero on non-2xx; for negative cases, capture status from the printed `HTTP` line or use raw `curl`.
- An empty model list usually means the mock openai-compatibility provider did not load — re-run doctor and check `server.log` for `OpenAI-compat`.
- Template example keys disable `/v1/*` with `403 unsafe_example_api_key`; that is not a successful auth proof.
