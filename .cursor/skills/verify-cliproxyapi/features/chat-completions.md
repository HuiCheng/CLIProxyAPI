# 聊天补全

聊天补全让 OpenAI 兼容客户端向 `/v1/chat/completions` 发送聊天请求，并收到经配置的 openai-compatibility 提供方路由后的助手消息（此处为本地验证 mock 上游）。

## 子功能

- `chat-auth`：需要有效的客户端 API key。
- `chat-unknown-model`：未列出的 model id 失败关闭。
- `chat-success`：对 `VERIFY_MODEL_ALIAS` 返回助手消息。
- `chat-stream`：`stream:true` 仍带出 `pong-from-mock`。
- `chat-mock-boundary`：证明响应内容来自 mock 上游（`pong-from-mock`）。

## 如何到达（用户视角）

- 使用 `Authorization: Bearer <VERIFY_API_KEY>`，JSON 体为 `{"model":"<alias>","messages":[{"role":"user","content":"ping"}]}`，调用 `POST /v1/chat/completions`。
- 使用同一路由，配合缺少/无效密钥或未知模型，观察错误。

## 用 scripts/http 驱动

前置条件：

- 验证实例健康（`scripts/doctor` PASS）。
- `GET /v1/models` 列出 `VERIFY_MODEL_ALIAS`（默认 `verify-mock`）。
- mock 上游是由 `scripts/launch` 启动的那一个。

- **鉴权成功。** 发送聊天。执行：

```bash
.cursor/skills/verify-cliproxyapi/scripts/http --api --save chat-completions/success.txt \
  POST /v1/chat/completions \
  --json '{"model":"verify-mock","messages":[{"role":"user","content":"ping"}]}'
```

  HTTP `200`。响应体含 `"object":"chat.completion"`（或等价 OpenAI 聊天形态）以及助手内容 `pong-from-mock`。

- **未知模型。** 将 `"model"` 换成 `"definitely-missing-model"` 再试。期望代理返回非 2xx（若 `scripts/http` 在保存前非零退出，可用仍会写 body 的包装或原始 curl，保存为 `chat-completions/unknown-model.txt`）。可观察结果：错误响应，而不是 `pong-from-mock`。
- **流式。** 同一路径加 `"stream":true`，保存 `chat-completions/stream.txt`。正文含 `pong-from-mock`。
- **缺少鉴权。** 不加 `--api` 发送相同 body。期望 HTTP `401`。
- **证明。** 保留 `success.txt` 与 `stream.txt`。确认路径 `/v1/chat/completions` 与 `pong-from-mock`。该字符串只定义在 `scripts/mock-upstream`。

## 注意事项

- 调用的是**别名**（`verify-mock`），不是上游名（`mock-model`），除非你故意把二者配成相同。
- 流式（`"stream":true`）是另一种响应形态；本功能的基线证明是非流式。
- 若聊天返回连接错误，说明 mock 上游已挂——先重跑 doctor，并检查 `run/mock-upstream.log`，再决定是否 relaunch。
- 本映射功能不需要、也不应引入真实提供方凭据；mock 是 openai-compatibility 在生产边界上的有意替身。
