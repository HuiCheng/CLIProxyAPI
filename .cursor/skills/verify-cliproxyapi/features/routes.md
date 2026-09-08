# 路由清单

本文件对照 `internal/api/server_routes.go` 与 `internal/api/server_management.go`。每条已注册用户入口必须落在「可驱动」或「跳过」。漏记即证明不完整。

`scripts/drive-all` 按本清单执行。功能文件解释用户怎么到达。本文件只记账。

## 公开与身份

| 入口 | 功能文件 | drive-all |
|------|----------|-----------|
| `GET /healthz` | [health-and-identity](./health-and-identity.md) | `healthz-get` |
| `HEAD /healthz` | [health-and-identity](./health-and-identity.md) | `healthz-head` |
| `GET /` | [health-and-identity](./health-and-identity.md) | `root-identity` |
| `cli-proxy-api --help` | [cli-help](./cli-help.md) | `cli-help` |

## 客户端 OpenAI / Claude / Gemini / Responses / 图片

| 入口 | 功能文件 | drive-all |
|------|----------|-----------|
| `GET /v1/models` | [client-auth-and-models](./client-auth-and-models.md) | `auth-missing` `auth-invalid` `models-list` |
| `POST /v1/chat/completions` | [chat-completions](./chat-completions.md) | `chat-success` `chat-unknown` `chat-auth` `chat-stream` |
| `POST /v1/completions` | [openai-completions](./openai-completions.md) | `completions` |
| `POST /v1/images/generations` | [images-generations](./images-generations.md) | `images` |
| `POST /v1/images/edits` | [images-edits](./images-edits.md) | `images-edits` |
| `POST /v1/messages` | [claude-messages](./claude-messages.md) | `claude-messages` |
| `POST /v1/messages/count_tokens` | [claude-messages](./claude-messages.md) | `claude-count-tokens` |
| `POST /v1/responses` | [openai-responses](./openai-responses.md) | `responses` |
| `POST /backend-api/codex/responses` | [openai-responses](./openai-responses.md) | `responses-codex-alias` |
| `POST /v1/responses/compact` | [responses-compact](./responses-compact.md) | `responses-compact` |
| `POST /backend-api/codex/responses/compact` | [responses-compact](./responses-compact.md) | `responses-compact-codex` |
| `GET /v1beta/models` | [gemini-generate](./gemini-generate.md) | `gemini-models` |
| `GET /v1beta/models/{alias}` | [gemini-generate](./gemini-generate.md) | `gemini-get-model` |
| `POST /v1beta/models/{alias}:generateContent` | [gemini-generate](./gemini-generate.md) | `gemini-generate` |
| `POST /v1beta/models/{alias}:streamGenerateContent` | [gemini-generate](./gemini-generate.md) | `gemini-stream` |
| `POST /v1beta/models/{alias}:countTokens` | [gemini-generate](./gemini-generate.md) | `gemini-count-tokens` |
| `POST /v1beta/interactions` | [gemini-interactions](./gemini-interactions.md) | `gemini-interactions` |

## 隔离环境下的可观察失败

这些路由已注册。隔离 mock 不能给出成功语义。drive-all 必须打一次并保存真实状态码。禁止用 chat 成功冒充。

| 入口 | 功能文件 | drive-all | 隔离期望 |
|------|----------|-----------|----------|
| `POST /v1/alpha/search` | [isolated-errors](./isolated-errors.md) | `alpha-search` | 无 Codex 凭据，非 mock 成功 |
| `POST /backend-api/codex/alpha/search` | [isolated-errors](./isolated-errors.md) | `alpha-search-codex` | 同上 |
| `POST /v1/videos` | [isolated-errors](./isolated-errors.md) | `videos` | 无视频上游 |
| `POST /v1/videos/generations` | [isolated-errors](./isolated-errors.md) | `videos-generations` | 同上 |
| `POST /v1/videos/edits` | [isolated-errors](./isolated-errors.md) | `videos-edits` | 同上 |
| `POST /v1/videos/extensions` | [isolated-errors](./isolated-errors.md) | `videos-extensions` | 同上 |
| `GET /v1/videos/:request_id` | [isolated-errors](./isolated-errors.md) | `videos-retrieve` | 同上 |
| `POST /openai/v1/videos` | [isolated-errors](./isolated-errors.md) | `openai-videos` | 同上 |
| `GET /openai/v1/videos/:id` | [isolated-errors](./isolated-errors.md) | `openai-videos-get` | 同上 |
| `GET /openai/v1/videos/:id/content` | [isolated-errors](./isolated-errors.md) | `openai-videos-content` | 同上 |
| `GET /keep-alive` | [isolated-errors](./isolated-errors.md) | `keep-alive` | 默认未注册，404 |
| `GET /management.html` | [isolated-errors](./isolated-errors.md) | `management-html` | `disable-control-panel: true` |

## OAuth 回调页

| 入口 | 功能文件 | drive-all |
|------|----------|-----------|
| `GET /anthropic/callback` | [oauth-callbacks](./oauth-callbacks.md) | `oauth-anthropic` |
| `GET /codex/callback` | [oauth-callbacks](./oauth-callbacks.md) | `oauth-codex` |
| `GET /antigravity/callback` | [oauth-callbacks](./oauth-callbacks.md) | `oauth-antigravity` |

## 管理 API（隔离可读 / 可写）

| 入口 | 功能文件 | drive-all |
|------|----------|-----------|
| `GET/PUT /v0/management/api-keys` | [management-api](./management-api.md) | `mgmt-api-keys` `mgmt-put-keys` |
| `GET /v0/management/config` | [management-api](./management-api.md) | `mgmt-config` |
| `POST/GET /v0/management/auth-files` | [management-api](./management-api.md) | `mgmt-auth-list` |
| `GET /v0/management/config.yaml` 与本地布尔/列表读取 | [management-settings](./management-settings.md) | `mgmt-settings-reads` |
| `PUT /v0/management/debug` 再恢复 | [management-settings](./management-settings.md) | `mgmt-debug-put` |

完整本地 GET 列表在 [management-settings](./management-settings.md)。

## 必须跳过（禁止当成功路径执行）

见 [blocked-surfaces](./blocked-surfaces.md)。

| 入口 | 原因 |
|------|------|
| CLI `--*-login`、`--vertex-import`、`--home-jwt` | 真实账号或改写凭据 |
| `--tui` / `--standalone` | 需要专用 PTY，且会占用端口 |
| `GET /v1/responses` WebSocket | `scripts/http` 不够 |
| `GET /backend-api/codex/responses` WebSocket | 同上 |
| `GET /v1/ws` | AI Studio / wsrelay，需要 WS 客户端 |
| `POST /v1/live`、`GET /v1/live/:id`、全部 `/v1/realtime*` | 需要 Codex/Live 凭据与 WS |
| `GET /v0/resource/plugins/…` | 需要已加载插件资源 |
| `GET /v0/management/latest-version` | 打 GitHub |
| `GET /v0/management/plugin-store` 与 install | 打网络仓库 |
| `GET /v0/management/*-auth-url` | 启动真实 OAuth |
| `GET|POST /v0/management/oauth-callback` | 完成进行中的 OAuth，无管理密钥 |
| `POST /v0/management/api-call` | 向任意上游发请求 |
| `POST /v0/management/vertex/import` | 导入真实密钥文件 |
| 已删除的 Amp `/api/*` | 本分支无代码，404 不计入覆盖 |
