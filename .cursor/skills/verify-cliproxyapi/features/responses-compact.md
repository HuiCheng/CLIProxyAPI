# Responses compact

Responses compact 让 Responses / Codex 客户端压缩上下文。路径是 `POST /v1/responses/compact`，Codex CLI 还走 `POST /backend-api/codex/responses/compact`。

## 子功能

- `responses-compact` 对 `verify-mock` 返回 compact 输出。
- `responses-compact-codex` 走 Codex 别名。
- `responses-compact-auth` 无 key 时拒绝。

## 如何到达（用户视角）

- `POST /v1/responses/compact`，Bearer `VERIFY_API_KEY`，JSON `{"model":"verify-mock","input":"ping"}`。
- `POST /backend-api/codex/responses/compact`，同一 body。
- 不带 Authorization 再打 `/v1/responses/compact`。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。

- **主入口。** 执行 `scripts/http --api --save responses-compact/success.txt POST /v1/responses/compact --json '{"model":"verify-mock","input":"ping"}'`。HTTP `200`。正文含 mock 跃点或 Responses `output`。
- **Codex 别名。** 执行 `scripts/http --api --save responses-compact/codex-alias.txt POST /backend-api/codex/responses/compact --json '{"model":"verify-mock","input":"ping"}'`。
- **缺少鉴权。** 不加 `--api`。期望 HTTP `401`。
- **证明。** 两份入口都要保留。不要用 `/v1/responses` 的 success 冒充 compact。

## 注意事项

- `"stream":true` 在 compact 上会被拒绝。本基线不发送 stream。
- `GET /v1/responses` WebSocket 不在本文件。见 blocked-surfaces。
