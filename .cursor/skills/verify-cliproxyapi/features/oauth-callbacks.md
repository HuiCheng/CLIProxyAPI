# OAuth 回调页

OAuth 回调页接收提供方重定向。用户在浏览器里看到成功 HTML。隔离验证只打回调路径本身，不启动真实 OAuth。

## 子功能

- `callback-anthropic` 打开 `/anthropic/callback`。
- `callback-codex` 打开 `/codex/callback`。
- `callback-antigravity` 打开 `/antigravity/callback`。

## 如何到达（用户视角）

- 浏览器或客户端 GET `/anthropic/callback`。
- GET `/codex/callback`。
- GET `/antigravity/callback`。
- 可选 query `code` 与 `state`。无 pending session 时仍应返回成功 HTML。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。
- 这些路径不需要 API key。

- **Anthropic。** 执行 `scripts/http --save oauth-callbacks/anthropic.txt GET /anthropic/callback`。HTTP `200`。正文含 `Authentication successful`。
- **Codex。** 执行 `scripts/http --save oauth-callbacks/codex.txt GET /codex/callback`。同样 HTML。
- **Antigravity。** 执行 `scripts/http --save oauth-callbacks/antigravity.txt GET /antigravity/callback`。同样 HTML。
- **证明。** 三个入口各留一份响应。只打其中一个不算覆盖。

## 注意事项

- 这不是 `--claude-login` / `--codex-login` 登录流。登录流见 blocked-surfaces。
- 带伪造 `state` 不会完成真实换票。本证明只覆盖回调页用户可见 HTML。
