# CLIProxyAPI 验证地图

本目录是校验 CLIProxyAPI **全部用户入口** 的维护源。驱动前先读本索引。地图列出的入口若未全部覆盖，证明不完整。

可隔离驱动的路径用 `scripts/drive-all` 一次跑完。不能隔离驱动的路径写在 [不可隔离驱动的入口](./blocked-surfaces.md)，必须按「跳过报告」记录未满足的前置条件，禁止用另一条路径冒充已验证。

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
- 跳过时写尝试过的命令与未满足前置。

## 功能条目约定

每个功能文件以 H1 开头，一段用户可见行为，然后恰好四个 H2：

1. `子功能`
2. `如何到达（用户视角）`
3. `用 scripts/http 驱动`
4. `注意事项`

## 可隔离驱动

- [健康检查与身份](./health-and-identity.md)
- [客户端鉴权与模型](./client-auth-and-models.md)
- [聊天补全](./chat-completions.md)
- [Claude Messages](./claude-messages.md)
- [Gemini generateContent](./gemini-generate.md)
- [OpenAI Responses](./openai-responses.md)
- [OpenAI Completions](./openai-completions.md)
- [图片生成](./images-generations.md)
- [管理 API](./management-api.md)
- [OAuth 回调页](./oauth-callbacks.md)

## 必须登记但默认跳过

- [不可隔离驱动的入口](./blocked-surfaces.md)（OAuth 登录、TUI、管理面板下载、Realtime/Live、视频、插件商店、keep-alive、管理端拉 GitHub 版本）
