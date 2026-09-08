# 不可隔离驱动的入口

这些是真实用户入口。隔离探测会打公网、打开浏览器，或需要专用 PTY。必须登记。未满足前置时按跳过报告。禁止用 chat/completions 冒充已验证。

视频、alpha-search、keep-alive、`/management.html` 已移到 [isolated-errors](./isolated-errors.md)。那些路径可以安全打一次。

## 子功能

- `oauth-login` CLI 登录旗标。
- `tui` 终端管理 UI。
- `realtime-live` Realtime / Live / WebSocket。
- `plugins-store` 插件商店与安装。
- `mgmt-latest-version` 管理端拉 GitHub 最新版本。
- `mgmt-oauth-url` 管理端发起真实 OAuth URL。
- `mgmt-api-call` 管理端向任意上游发请求。
- `vertex-import` 导入服务账号密钥。

## 如何到达（用户视角）

- `cli-proxy-api --claude-login` / `--codex-login` / `--codex-device-login` / `--antigravity-login` / `--kimi-login` / `--xai-login`，可选 `--no-browser`、`--oauth-callback-port`。
- `cli-proxy-api --vertex-import <file>`。
- `cli-proxy-api --tui` 或 `--tui --standalone`。
- `GET /v1/responses` WebSocket、`GET /backend-api/codex/responses` WebSocket、`GET /v1/realtime`、`POST /v1/live`。
- `GET /v0/management/plugin-store`、`POST /v0/management/plugin-store/:id/install`。
- `GET /v0/management/latest-version`。
- `GET /v0/management/anthropic-auth-url` 等 `*-auth-url`。
- `POST /v0/management/api-call`。
- `POST /v0/management/vertex/import`。

## 用 scripts/http 驱动

前置条件：

- 下列前置**当前默认不成立**。先记录跳过，再停止。不要发这些请求。

- **OAuth 登录。** 需要真实提供方账号与回调。不要在验证机上对公网发起登录。尝试命令示例：`VERIFY_BIN --config $VERIFY_CONFIG --no-browser --claude-login`。未满足「真实账号」则跳过。
- **TUI。** 需要独立 PTY/tmux，且不要复用验证 HTTP 实例的端口。未满足「专用 PTY」则跳过。
- **Realtime / Live / WS。** 需要 Codex/Live 凭据与 WebSocket 客户端。`scripts/http` 不够。未满足则跳过。
- **插件商店。** `GET /v0/management/plugin-store` 与 install 会访问网络仓库。隔离运行默认不装插件。
- **latest-version / *-auth-url / api-call / vertex/import。** 会打公网、打开 OAuth，或写入真实密钥。隔离验证禁止当成功路径执行。
- **证明。** 跳过条目写入 `evidence/blocked-surfaces/notes.txt`，列出入口与未满足前置。

## 注意事项

- 跳过不是失败。漏记跳过才是失败。
- `--help` 里出现登录旗标只证明帮助文本，不证明登录流。
- 给某入口补上隔离 mock 后，应把它从本文件移到可驱动功能文件，并加入 `scripts/drive-all`。
