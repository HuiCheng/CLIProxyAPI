# 不可隔离驱动的入口

这些是真实用户入口，但隔离 mock 无法安全或完整证明。必须登记。未满足前置时按跳过报告，禁止用 chat/completions 冒充已验证。

## 子功能

- `oauth-login` CLI 登录旗标。
- `tui` 终端管理 UI。
- `management-panel` `/management.html` 控制面板资源。
- `realtime-live` Realtime / Live / WebSocket。
- `videos` 视频生成与检索。
- `plugins` 插件与插件商店。
- `keep-alive` 仅在 keep-alive 选项打开时注册。
- `mgmt-latest-version` 管理端拉 GitHub 最新版本。
- `mgmt-oauth-url` 管理端发起真实 OAuth URL。

## 如何到达（用户视角）

- `cli-proxy-api --claude-login` / `--codex-login` / `--codex-device-login` / `--antigravity-login` / `--kimi-login` / `--xai-login`，可选 `--no-browser`、`--oauth-callback-port`。
- `cli-proxy-api --tui` 或 `--tui --standalone`。
- 浏览器打开 `/management.html`。
- `GET /v1/responses` WebSocket、`GET /v1/realtime`、`POST /v1/live`。
- `POST /v1/videos`、`POST /openai/v1/videos` 及检索路径。
- `GET /v0/management/plugins`、`GET /v0/management/plugin-store`。
- `GET /keep-alive`。
- `GET /v0/management/latest-version`。
- `GET /v0/management/anthropic-auth-url` 等 `*-auth-url`。

## 用 scripts/http 驱动

前置条件：

- 下列前置**当前默认不成立**。先记录跳过，再停止。

- **OAuth 登录。** 需要真实提供方账号与回调。不要在验证机上对公网发起登录。尝试命令示例：`VERIFY_BIN --config $VERIFY_CONFIG --no-browser --claude-login`。未满足「真实账号」则跳过。
- **TUI。** 需要独立 PTY/tmux，且不要复用验证 HTTP 实例的端口。未满足「专用 PTY」则跳过。
- **管理面板。** launch 设置了 `disable-control-panel: true`。`GET /management.html` 不是本轮要证明的面板下载。若要证明面板，必须另起允许下载 GitHub 资源的运行。
- **Realtime / Live / WS。** 需要 Codex/Live 凭据与 WebSocket 客户端。`scripts/http` 不够。未满足则跳过。
- **视频。** 需要 xAI/OpenAI 视频上游。mock 不提供该边界。未满足则跳过。
- **插件商店。** `GET /v0/management/plugin-store` 与 install 会访问网络仓库。隔离运行默认不装插件。
- **keep-alive。** 默认 launch 不 `enableKeepAlive`。路由不存在时的 404 只能证明「未启用」，不能证明心跳语义。
- **latest-version / *-auth-url。** 会打公网或打开 OAuth。隔离验证禁止当成功路径执行。
- **证明。** 跳过条目写入 `evidence/blocked-surfaces/notes.txt`，列出入口与未满足前置。

## 注意事项

- 跳过不是失败。漏记跳过才是失败。
- 给某入口补上隔离 mock 后，应把它从本文件移到可驱动功能文件，并加入 `scripts/drive-all`。
