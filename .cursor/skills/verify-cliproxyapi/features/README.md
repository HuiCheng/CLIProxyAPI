# CLIProxyAPI 验证地图

本目录是校验 CLIProxyAPI **全部用户入口** 的维护源。驱动前先读本索引和 [路由清单](./routes.md)。清单列出的入口若未全部覆盖，证明不完整。

可隔离成功的路径、以及隔离下可观察失败的路径，都由 `scripts/drive-all` 一次跑完。会打公网、开浏览器或占用专用 PTY 的路径写在 [不可隔离驱动的入口](./blocked-surfaces.md)。禁止用另一条路径冒充已验证。

## 基线前置条件

- 用 `.cursor/skills/verify-cliproxyapi/scripts/launch` 启动隔离实例。
- `scripts/doctor` 必须 PASS。
- 客户端走 `scripts/http --api`。管理走 `scripts/http --mgmt`。
- 禁止驱动非本轮启动的实例。
- 不要使用 `your-api-key-1/2/3`。

## 驱动约定

- 默认从基线状态开始。
- 稳定句柄是路由路径与鉴权头。
- 命令按字面执行。
- 相对 `--save` 写入 `VERIFY_EVIDENCE_DIR`。
- cleanup 拆除实例，不删证据。

## 证明与跳过报告

- 同时记录动作与 HTTP 状态码 + 响应体。
- 鉴权要覆盖拒绝与接受。
- 写操作必须再 GET 一次。
- 聊天类断言 `pong-from-mock`（只存在于 mock 上游）。
- 隔离失败路径断言「不是 mock 成功」，并保存真实状态码。
- 跳过时写尝试过的命令与未满足前置。

## 功能条目约定

每个功能文件以 H1 开头，一段用户可见行为，然后恰好四个 H2：

1. `子功能`
2. `如何到达（用户视角）`
3. `用 scripts/http 驱动`
4. `注意事项`

路由对照表见 [routes.md](./routes.md)。

## 可隔离成功

- [健康检查与身份](./health-and-identity.md)
- [CLI 帮助](./cli-help.md)
- [客户端鉴权与模型](./client-auth-and-models.md)
- [聊天补全](./chat-completions.md)
- [Claude Messages](./claude-messages.md)
- [Gemini generateContent](./gemini-generate.md)
- [Gemini interactions](./gemini-interactions.md)
- [OpenAI Responses](./openai-responses.md)
- [Responses compact](./responses-compact.md)
- [OpenAI Completions](./openai-completions.md)
- [图片生成](./images-generations.md)
- [图片编辑](./images-edits.md)
- [管理 API](./management-api.md)
- [管理设置](./management-settings.md)
- [OAuth 回调页](./oauth-callbacks.md)

## 隔离下必须打一次（失败即证明）

- [隔离环境下的可观察失败](./isolated-errors.md)（alpha-search、视频、keep-alive、management.html）

## 必须登记但默认不调用

- [不可隔离驱动的入口](./blocked-surfaces.md)（OAuth 登录、TUI、Realtime/Live/WS、插件商店、latest-version、管理端 `*-auth-url`、`api-call`、`vertex/import`）
