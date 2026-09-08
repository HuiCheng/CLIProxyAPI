# OpenAI Responses

Responses 让 Responses API 客户端调用 `POST /v1/responses`。Codex CLI 还走别名 `POST /backend-api/codex/responses`。

## 子功能

- `responses-success` 对 `verify-mock` 返回完成态输出。
- `responses-codex-alias` 走 `/backend-api/codex/responses`。
- `responses-auth` 无 key 时拒绝。

## 如何到达（用户视角）

- `POST /v1/responses`，Bearer `VERIFY_API_KEY`，JSON `{"model":"verify-mock","input":"ping"}`。
- `POST /backend-api/codex/responses`，同一 body。
- 不带 Authorization 再打 `/v1/responses`。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。

- **主入口。** 执行 `scripts/http --api --save openai-responses/success.txt POST /v1/responses --json '{"model":"verify-mock","input":"ping"}'`。HTTP `200` 或可观察的协议错误必须落盘。成功时正文含 mock 跃点文本或 Responses `output`。
- **Codex 别名。** 执行 `scripts/http --api --save openai-responses/codex-alias.txt POST /backend-api/codex/responses --json '{"model":"verify-mock","input":"ping"}'`。
- **缺少鉴权。** 不加 `--api`。期望 HTTP `401`。
- **证明。** 两份入口的响应都要保留。只打 `/v1/responses` 不算覆盖 Codex 别名。

## 注意事项

- `GET /v1/responses` 是 WebSocket。隔离 HTTP 配方不覆盖它。见 blocked-surfaces。
- `POST /v1/responses/compact` 见 [responses-compact](./responses-compact.md)。不要用 success 冒充 compact。
- 流式 Responses 与非流式不同形。本基线是非流式。
