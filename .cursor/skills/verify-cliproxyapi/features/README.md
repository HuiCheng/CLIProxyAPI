# CLIProxyAPI verification map

This directory is the maintained source for verifying the user-facing HTTP behavior of CLIProxyAPI. Read the index before driving the app, then use the matching feature file as the recipe.

## Baseline preconditions

- Launch with `.cursor/skills/verify-cliproxyapi/scripts/launch` so the instance uses a disposable run directory under `/tmp/cliproxyapi-verify-<RUN_ID>/`.
- Run `.cursor/skills/verify-cliproxyapi/scripts/doctor` and require PASS before driving.
- Client calls use `Authorization: Bearer <VERIFY_API_KEY>` via `scripts/http --api`.
- Management calls use `Authorization: Bearer <VERIFY_MGMT_KEY>` via `scripts/http --mgmt`.
- Never drive an instance that was not started by this verification run.
- Do not use template api-keys from `config.example.yaml` (`your-api-key-1/2/3`).

## Driving conventions

- Start every recipe from the baseline state unless its preconditions say otherwise.
- Prefer route paths and auth headers over any UI.
- Treat every command as literal. Keep quoted JSON and flags unchanged.
- Run HTTP actions through `scripts/http`.
- Relative `--save` paths write under `VERIFY_EVIDENCE_DIR`.
- Restore no remote provider state; the mock upstream is local and disposable. Cleanup removes the instance, not evidence.

## Proof and skip reporting

- Capture the user/client action and the resulting HTTP status + body, not only a final "ok".
- Auth proofs include both the rejected and accepted paths when the map lists them.
- Mutation proofs (management writes) include a follow-up GET of the changed value.
- Record the feature ID and entry point used with every artifact.
- Report an unreachable path with the attempted command and unmet precondition.
- Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with scripts/http` starts with `Preconditions:` and uses labeled bullets that pair each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

Keep implementation details out of the map. Name only user paths, stable handles, required state, commands, and observable proof.

## Features

- [Health and identity](./health-and-identity.md) covers unauthenticated liveness and root identity.
- [Client auth and models](./client-auth-and-models.md) covers Bearer API key rejection/acceptance and `/v1/models`.
- [Management API](./management-api.md) covers management key auth and config/api-key reads.
- [Chat completions](./chat-completions.md) covers OpenAI-compatible chat through the configured mock upstream.
