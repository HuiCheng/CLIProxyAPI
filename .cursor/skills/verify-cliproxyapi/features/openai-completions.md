# OpenAI Completions

Completions 让旧版 OpenAI 客户端调用 `POST /v1/completions`，用 `prompt` 而不是 `messages`。

## 子功能

- `completions-success` 对 `verify-mock` 返回文本选择。
- `completions-auth` 无 key 时拒绝。

## 如何到达（用户视角）

- `POST /v1/completions`，Bearer `VERIFY_API_KEY`，JSON `{"model":"verify-mock","prompt":"ping"}`。
- 不带 Authorization 再打一次。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。

- **成功。** 执行 `scripts/http --api --save openai-completions/success.txt POST /v1/completions --json '{"model":"verify-mock","prompt":"ping"}'`。HTTP `200`。choices 文本含 `pong-from-mock` 或经翻译后的等价助手文本。
- **缺少鉴权。** 不加 `--api`。期望 HTTP `401`。
- **证明。** 保留 success 响应。不要用 chat/completions 的证据代替本入口。

## 注意事项

- 这不是 chat completions。客户端字段是 `prompt`。
- 流式 completions 不在本基线。
