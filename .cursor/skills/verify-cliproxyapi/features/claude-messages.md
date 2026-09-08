# Claude Messages

Claude Messages 让 Anthropic 兼容客户端向 `/v1/messages` 发送对话，并由代理路由到已配置提供方。隔离验证中该提供方是本地 openai-compatibility mock。

## 子功能

- `claude-auth` 要求客户端 API key。
- `claude-success` 对 `VERIFY_MODEL_ALIAS` 返回助手内容。
- `claude-count-tokens` 走 `/v1/messages/count_tokens`。

## 如何到达（用户视角）

- `POST /v1/messages`，头为 `Authorization: Bearer <VERIFY_API_KEY>`，JSON 含 `model`、`max_tokens`、`messages`。
- `POST /v1/messages/count_tokens`，同一鉴权。
- 不带 key 再打一次 `/v1/messages`，观察 401。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。
- `GET /v1/models` 含 `verify-mock`。

- **鉴权成功。** 执行 `scripts/http --api --save claude-messages/success.txt POST /v1/messages --json '{"model":"verify-mock","max_tokens":32,"messages":[{"role":"user","content":"ping"}]}'`。HTTP `200`。响应是 Claude message 形态或经翻译后的助手文本，且能追到 `pong-from-mock` 或等价 mock 跃点。
- **计 token。** 执行 `scripts/http --api --save claude-messages/count-tokens.txt POST /v1/messages/count_tokens --json '{"model":"verify-mock","messages":[{"role":"user","content":"ping"}]}'`。记录状态码与 body。2xx 或明确的协议错误都要落盘，不能静默跳过。
- **缺少鉴权。** 不加 `--api` 再 POST 同一 body。期望 HTTP `401`。
- **证明。** 保留 `success.txt`。注明入口 `POST /v1/messages`。

## 注意事项

- 客户端必须用别名 `verify-mock`。
- 代理会把 Claude 请求翻译成 openai-compatibility 的 `/chat/completions`。mock 只站在该边界。
- `count_tokens` 若对 openai-compat 未实现，记为该入口的可观察失败，不要改成只测 chat。
