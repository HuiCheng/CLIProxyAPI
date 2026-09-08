# CLIProxyAPI 验证地图

本目录是校验 CLIProxyAPI 用户可见 HTTP 行为的维护源。驱动应用前先读本索引，再按对应功能文件执行配方。

## 基线前置条件

- 用 `.cursor/skills/verify-cliproxyapi/scripts/launch` 启动，使实例使用 `/tmp/cliproxyapi-verify-<RUN_ID>/` 下的一次性运行目录。
- 先跑 `.cursor/skills/verify-cliproxyapi/scripts/doctor`，必须 PASS 再驱动。
- 客户端调用经 `scripts/http --api`，使用 `Authorization: Bearer <VERIFY_API_KEY>`。
- 管理调用经 `scripts/http --mgmt`，使用 `Authorization: Bearer <VERIFY_MGMT_KEY>`。
- 禁止驱动非本验证运行启动的实例。
- 不要使用 `config.example.yaml` 中的模板 api-keys（`your-api-key-1/2/3`）。

## 驱动约定

- 除非功能文件另有前置说明，每个配方都从基线状态开始。
- 优先使用路由路径与鉴权头，而不是任何 UI。
- 命令按字面执行；带引号的 JSON 与参数保持不变。
- HTTP 动作通过 `scripts/http` 执行。
- 相对 `--save` 路径写入 `VERIFY_EVIDENCE_DIR`。
- 无需恢复远端提供方状态；mock 上游是本地一次性资源。cleanup 拆除实例，不删除证据。

## 证明与跳过报告

- 同时记录用户/客户端动作与结果 HTTP 状态码 + 响应体，不能只有最终 “ok”。
- 功能图列出拒绝与接受路径时，鉴权证明两者都要覆盖。
- 变更证明（管理写入）须包含对变更值的后续 GET。
- 每份产物都记录功能 ID 与所用入口。
- 无法到达的路径：报告尝试过的命令与未满足的前置条件。
- 不要把跳过的入口报成已通过另一条路径验证。

## 功能条目约定

每个功能文件以 H1 标题开头，并用一段话描述用户可见行为；随后按固定顺序使用恰好四个 H2：

1. `子功能`：短 ID + 一行行为说明。
2. `如何到达（用户视角）`：列出全部用户入口。
3. `用 scripts/http 驱动`：以 `前置条件：` 开头；用带标签的条目把每个用户动作与精确命令、可观察结果配对。
4. `注意事项`：会浪费或使验证无效的陷阱。

不要把实现细节写进地图。只写用户路径、稳定句柄、所需状态、命令与可观察证明。

## 功能列表

- [健康检查与身份](./health-and-identity.md)：未鉴权存活探测与根路径身份。
- [客户端鉴权与模型](./client-auth-and-models.md)：Bearer API key 拒绝/接受与 `/v1/models`。
- [管理 API](./management-api.md)：管理密钥鉴权与配置/API key 读取。
- [聊天补全](./chat-completions.md)：经配置的 mock 上游走 OpenAI 兼容聊天。
