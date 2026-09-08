# Gemini generateContent

Gemini 兼容客户端通过 `/v1beta/models` 发现模型，再向 `/v1beta/models/{model}:generateContent` 发内容生成请求。

## 子功能

- `gemini-models` 列出 Gemini 视图中的模型。
- `gemini-get-model` 读取单个模型。
- `gemini-generate` 对 `verify-mock` 生成内容。
- `gemini-stream` 走 `:streamGenerateContent`。
- `gemini-count-tokens` 走 `:countTokens`。
- `gemini-auth` 无 key 时拒绝 `/v1beta/*`。

## 如何到达（用户视角）

- `GET /v1beta/models`，Bearer `VERIFY_API_KEY`。
- `GET /v1beta/models/verify-mock`。
- `POST /v1beta/models/verify-mock:generateContent`，JSON `{"contents":[{"parts":[{"text":"ping"}]}]}`。
- `POST /v1beta/models/verify-mock:streamGenerateContent`，同一 body。
- `POST /v1beta/models/verify-mock:countTokens`，同一 body。
- 同一 generate 路径不带 Authorization。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。

- **模型列表。** 执行 `scripts/http --api --save gemini-generate/models.txt GET /v1beta/models`。HTTP `200`。
- **单个模型。** 执行 `scripts/http --api --save gemini-generate/get-model.txt GET /v1beta/models/verify-mock`。HTTP `200`。
- **生成。** 执行 `scripts/http --api --save gemini-generate/generate.txt POST /v1beta/models/verify-mock:generateContent --json '{"contents":[{"parts":[{"text":"ping"}]}]}'`。记录 2xx 与候选文本，或协议错误全文。
- **流式。** 同一 body 打 `:streamGenerateContent`，保存 `gemini-generate/stream.txt`。
- **计 token。** 同一 body 打 `:countTokens`，保存 `gemini-generate/count-tokens.txt`。2xx 或明确协议错误都要落盘。
- **缺少鉴权。** 不加 `--api` 再 POST generate。期望 HTTP `401`。
- **证明。** 保留 models、get-model、generate、stream。

## 注意事项

- 路径里的模型名是客户端别名，不是上游 `mock-model`。
- 代理会翻译成 openai-compat `/chat/completions`。
- `/v1beta/interactions` 见 [gemini-interactions](./gemini-interactions.md)。
