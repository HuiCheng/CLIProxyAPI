# Health and identity

Health and identity let a client confirm the proxy process is up and that the responding server is CLIProxyAPI, without sending an API key.

## Sub-features

- `healthz-get` returns JSON liveness on `GET /healthz`.
- `healthz-head` accepts `HEAD /healthz` with status 200 and no body requirement.
- `root-identity` returns the root JSON message naming CLI Proxy API Server and listing core endpoints.

## How to get to it (user POV)

- Call `GET /healthz` on the proxy base URL.
- Call `HEAD /healthz` on the proxy base URL.
- Call `GET /` on the proxy base URL.

## Driving it with scripts/http

Preconditions:

- Verification instance is healthy (`scripts/doctor` PASS).
- No API key is required for these routes.

- **Liveness GET.** Request health. Run `scripts/http --save health-and-identity/healthz.txt GET /healthz`. HTTP `200` and body contain `"status":"ok"`.
- **Liveness HEAD.** Confirm HEAD works. After `source scripts/common.sh && verify_load_meta`, run `curl -sS -o /dev/null -w '%{http_code}\n' -I "$VERIFY_BASE_URL/healthz"`. HTTP `200`.
- **Root identity.** Request root. Run `scripts/http --save health-and-identity/root.txt GET /`. HTTP `200`, body contains `"message":"CLI Proxy API Server"` and endpoint string `GET /v1/models`.
- **Proof.** Keep both saved response files under `evidence/health-and-identity/`. They must show status `ok` and the identity message.

## Gotchas

- `/healthz` is public; a 401 here means you hit the wrong process or a different service on the port.
- Example-api-key safe mode can replace `GET /` with an HTML warning page when template keys are configured — verification launch must not use those keys.
- Doctor already checks these routes; a feature proof still needs saved response artifacts.
