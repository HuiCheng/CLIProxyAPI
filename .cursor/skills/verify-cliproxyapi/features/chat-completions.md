# Chat completions

Chat completions let an OpenAI-compatible client send a chat request to `/v1/chat/completions` and receive an assistant message routed through the configured openai-compatibility provider (here, the local verification mock upstream).

## Sub-features

- `chat-auth` requires a valid client API key.
- `chat-unknown-model` fails closed for a model id that is not listed.
- `chat-success` returns an assistant message for `VERIFY_MODEL_ALIAS`.
- `chat-mock-boundary` proves the response content originates from the mock upstream (`pong-from-mock`).

## How to get to it (user POV)

- `POST /v1/chat/completions` with `Authorization: Bearer <VERIFY_API_KEY>` and JSON body `{"model":"<alias>","messages":[{"role":"user","content":"ping"}]}`.
- Use the same route with a missing/invalid key or an unknown model to observe errors.

## Driving it with scripts/http

Preconditions:

- Verification instance is healthy (`scripts/doctor` PASS).
- `GET /v1/models` lists `VERIFY_MODEL_ALIAS` (default `verify-mock`).
- Mock upstream is the one started by `scripts/launch`.

- **Authenticated success.** Send a chat. Run:

```bash
.cursor/skills/verify-cliproxyapi/scripts/http --api --save chat-completions/success.txt \
  POST /v1/chat/completions \
  --json '{"model":"verify-mock","messages":[{"role":"user","content":"ping"}]}'
```

  HTTP `200`. Body includes `"object":"chat.completion"` (or equivalent OpenAI chat shape) and assistant content `pong-from-mock`.

- **Unknown model.** Repeat with `"model":"definitely-missing-model"`. Expect non-2xx from the proxy (save as `chat-completions/unknown-model.txt` using raw curl if `scripts/http` exits non-zero before save — prefer `--save` on a wrapper that still writes the body). Observable: error response, not `pong-from-mock`.
- **Missing auth.** `POST` the same body without `--api`. Expect HTTP `401`.
- **Proof.** Keep `success.txt`. Confirm it shows both the request path `/v1/chat/completions` and content `pong-from-mock`. That string is defined only in `scripts/mock-upstream`, proving the openai-compatibility hop.

## Gotchas

- Call the **alias** (`verify-mock`), not the upstream name (`mock-model`), unless you intentionally configured them identically.
- Streaming (`"stream":true`) is a different response shape; this feature's baseline proof is non-streaming.
- If chat returns connection errors, the mock upstream died — re-run doctor and check `run/mock-upstream.log` before relaunching.
- Real provider credentials are not required and must not be introduced for this mapped feature; the mock is the intentional production-boundary stand-in for openai-compatibility.
