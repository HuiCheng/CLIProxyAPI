---
name: verify-cliproxyapi
description: "按真实客户端方式驱动 CLIProxyAPI 的全部用户入口（OpenAI/Gemini/Claude/Responses/图片、Gemini interactions、管理设置、CLI --help，以及隔离下的视频/alpha-search 失败）。启动隔离实例、doctor、按路由清单或 drive-all 取证。代码变更后证明代理行为时使用。文档与脚本输出为中文。"
---

# 验证 CLIProxyAPI

CLIProxyAPI 的主用户面是 HTTP。客户端打 OpenAI / Claude / Gemini / Responses / 图片等路径。运维打 `/v0/management`。浏览器会碰到 OAuth 回调 HTML。

次要面是 `--tui` 与 `/management.html`。它们列在功能地图的跳过文件里。默认编排不假装已经验证它们。

禁止驱动共享实例。只启动 `/tmp/cliproxyapi-verify-<RUN_ID>/`。

## 启动（Launch）

```bash
.cursor/skills/verify-cliproxyapi/scripts/launch
.cursor/skills/verify-cliproxyapi/scripts/doctor
```

`scripts/launch` 会：

1. 分配 `VERIFY_RUN_ID` 与 `127.0.0.1` 空闲端口。
2. 写入脚手架配置。非模板 `api-keys`。管理 `secret-key`。`disable-control-panel: true`。隔离 `auth-dir`。`openai-compatibility` 指向本地 mock。`verify-mock` 带 `image: true`。
3. 构建 `./cmd/server` 到运行目录。
4. 启动 `scripts/mock-upstream`，再以 `--config <run>/config.yaml --local-model` 启动代理。
5. 就绪条件。日志含 `API server started successfully on: 127.0.0.1:<port>`，且 `GET /healthz` 返回 `{"status":"ok"}`。

可选覆盖。`VERIFY_RUN_ID`、`VERIFY_HOST`、`VERIFY_PORT`、`VERIFY_MOCK_PORT`、`VERIFY_API_KEY`、`VERIFY_MGMT_KEY`、`VERIFY_MODEL_ALIAS`。

拆除。

```bash
.cursor/skills/verify-cliproxyapi/scripts/cleanup
```

cleanup 只杀本轮 PID，删 `run/`，保留 `evidence/`。

隔离规则：

- 同时一个活动运行（`.active-run`）。旧 PID 仍在则拒绝 launch。
- 禁止模板 api-keys。
- 禁止复用 `~/.cli-proxy-api` 或生产 `config.yaml`。

## 诊断（Doctor）

```bash
.cursor/skills/verify-cliproxyapi/scripts/doctor
```

只读。服务与 mock PID、`/healthz`、`/` 身份、`/v1/models` 列出别名、管理 api-keys 可读。全过才退出 0。

## 驱动（Drive）

一次覆盖全部可隔离入口。

```bash
.cursor/skills/verify-cliproxyapi/scripts/drive-all
```

单条仍用 `scripts/http`。

```bash
.cursor/skills/verify-cliproxyapi/scripts/http GET /healthz
.cursor/skills/verify-cliproxyapi/scripts/http --api GET /v1/models
.cursor/skills/verify-cliproxyapi/scripts/http --mgmt GET /v0/management/api-keys
.cursor/skills/verify-cliproxyapi/scripts/http --api --save chat-completions/success.txt \
  POST /v1/chat/completions \
  --json '{"model":"verify-mock","messages":[{"role":"user","content":"ping"}]}'
```

负面用例加 `--allow-fail`，否则非 2xx 会非零退出。

稳定句柄：

| 句柄 | 含义 |
|------|------|
| `GET /healthz` | 存活 `{"status":"ok"}` |
| `GET /` | `"message":"CLI Proxy API Server"` |
| `Authorization: Bearer <VERIFY_API_KEY>` | `/v1/*`、`/v1beta/*`、`/backend-api/codex/*`、`/openai/v1/*` |
| `GET /v1/models` | OpenAI 模型列表 |
| `POST /v1/chat/completions` | 聊天。可加 `"stream":true` |
| `POST /v1/completions` | 旧版 completions |
| `POST /v1/messages` | Claude |
| `POST /v1/messages/count_tokens` | Claude 计 token |
| `POST /v1/responses` | Responses |
| `POST /v1/responses/compact` | Responses compact |
| `POST /backend-api/codex/responses` | Codex CLI 别名 |
| `GET /v1beta/models` | Gemini 模型列表 |
| `GET /v1beta/models/{alias}` | Gemini 单个模型 |
| `POST /v1beta/models/{alias}:generateContent` | Gemini 生成 |
| `POST /v1beta/models/{alias}:streamGenerateContent` | Gemini 流式 |
| `POST /v1beta/interactions` | Gemini interactions |
| `POST /v1/images/generations` | 图片生成 |
| `POST /v1/images/edits` | 图片编辑 |
| `GET /anthropic/callback` 等 | OAuth 回调 HTML |
| `"$VERIFY_BIN" --help` | CLI 旗标 |
| `Authorization: Bearer <VERIFY_MGMT_KEY>` 或 `X-Management-Key` | `/v0/management/*` |

先读 `features/README.md` 与 `features/routes.md`。清单列出的入口漏一个，证明就不完整。

## 证据（Evidence）

目录。`/tmp/cliproxyapi-verify-<RUN_ID>/evidence/<feature-id>/`。也就是 `VERIFY_EVIDENCE_DIR`。

标准：

- 走真实客户端路由。
- 记录动作与结果状态码 + body。写操作再 GET。
- 聊天类断言 `pong-from-mock`。
- 不要用 `go test` 代替用户路径。
- mock 只站在 openai-compatibility 边界。

## 清理（Cleanup）

```bash
.cursor/skills/verify-cliproxyapi/scripts/cleanup
```

只按 pid 文件杀进程。保留 evidence。清理后必须还能读到证据文件。

## 辅助脚本（Helpers）

| 脚本 | 调用 | 作用 |
|------|------|------|
| `launch` | `scripts/launch` | 构建、写配置、启动 mock + 代理 |
| `doctor` | `scripts/doctor` | 只读就绪检查 |
| `http` | `scripts/http [--api\|--mgmt] [--allow-fail] [--save PATH] [--json BODY] METHOD /path` | 单次 HTTP |
| `drive-all` | `scripts/drive-all` | 跑完全部可隔离功能 |
| `cleanup` | `scripts/cleanup` | 停本轮进程，留证据 |
| `mock-upstream` | 由 launch 启动 | 本地 OpenAI 兼容桩 |
| `common.sh` | 被 source | 路径与活动运行 |

## 功能地图

见 [features/README.md](features/README.md) 与 [features/routes.md](features/routes.md)。
