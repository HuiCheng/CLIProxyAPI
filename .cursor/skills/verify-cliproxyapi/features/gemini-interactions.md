# Gemini interactions

Gemini Interactions 客户端调用 `POST /v1beta/interactions`。隔离验证把 `model` 设成 `verify-mock`，由代理翻译到 openai-compatibility `/chat/completions`。

## 子功能

- `gemini-interactions` 对 `verify-mock` 返回 interactions 输出。
- `gemini-interactions-auth` 无 key 时拒绝。

## 如何到达（用户视角）

- `POST /v1beta/interactions`，Bearer `VERIFY_API_KEY`，JSON `{"model":"verify-mock","input":"ping"}`。
- 不带 Authorization 再打一次。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。

- **成功。** 执行 `scripts/http --api --save gemini-interactions/success.txt POST /v1beta/interactions --json '{"model":"verify-mock","input":"ping"}'`。HTTP `200`。正文含 `pong-from-mock` 或经翻译后的 interactions 步骤文本。
- **缺少鉴权。** 不加 `--api`。期望 HTTP `401`。
- **证明。** 保留 success。不要用 `:generateContent` 冒充本入口。

## 注意事项

- body 必须恰好有 `model` 或 `agent` 之一。本基线用 `model`。
- `agent` 会强制 Gemini Interactions 提供方，隔离 mock 覆盖不了。
- 流式 `"stream":true` 不在本基线。
