---
name: verify-cliproxyapi
description: "按真实客户端方式驱动 CLIProxyAPI 的 HTTP 面（OpenAI/Gemini/Claude 兼容代理 + 管理 API）：启动隔离实例、做 doctor 检查、用 curl 辅助脚本演练已映射路由并保存响应证据。在证明代理行为、鉴权、模型列表、管理端点或聊天补全时使用。文档与脚本面向输出为中文。"
---

# 验证 CLIProxyAPI

CLIProxyAPI 是一个 Go HTTP 代理，对外提供 OpenAI/Gemini/Claude/Codex 兼容 API 以及管理 API。本技能默认验证的主用户面是 **HTTP**（curl）。次要面（`--tui` 终端 UI、可选的 `/management.html` 控制面板）不在默认编排范围内——请驱动客户端实际调用的 HTTP 路由。

禁止驱动共享或已有实例。必须启动隔离运行目录：`/tmp/cliproxyapi-verify-<RUN_ID>/`。

## 启动（Launch）

在仓库根目录执行：

```bash
.cursor/skills/verify-cliproxyapi/scripts/launch
.cursor/skills/verify-cliproxyapi/scripts/doctor
```

`scripts/launch` 会：

1. 分配 `VERIFY_RUN_ID` 以及 `127.0.0.1` 上的空闲端口。
2. 写入仅用于验证的脚手架配置（非生产）：非模板 `api-keys`、管理 `secret-key`、`disable-control-panel: true`、隔离 `auth-dir`，以及指向本地 mock 上游的 `openai-compatibility` 提供方。
3. 将 `./cmd/server` 构建到运行目录。
4. 先启动 `scripts/mock-upstream`，再以 `--config <run>/config.yaml --local-model` 启动代理。
5. 就绪条件：日志出现 `API server started successfully on: 127.0.0.1:<port>`，且 `GET /healthz` 返回 `{"status":"ok"}`。

可选环境变量覆盖：`VERIFY_RUN_ID`、`VERIFY_HOST`、`VERIFY_PORT`、`VERIFY_MOCK_PORT`、`VERIFY_API_KEY`、`VERIFY_MGMT_KEY`、`VERIFY_MODEL_ALIAS`。

拆除：

```bash
.cursor/skills/verify-cliproxyapi/scripts/cleanup
```

cleanup 只杀死本轮记录的 PID，并删除 `run/` 目录；`evidence/` 下的证据保留。

隔离规则：

- 同时只允许一个活动验证运行（`.cursor/skills/verify-cliproxyapi/.active-run`）。若该运行的服务 PID 仍存活，launch 会拒绝启动。
- 不要使用 `config.example.yaml` 中的 api-keys（`your-api-key-1/2/3`）——会触发示例密钥安全模式并拦截 `/v1/*`。
- 不要复用用户真实的 `~/.cli-proxy-api` 鉴权目录或生产 `config.yaml`。

## 诊断（Doctor）

```bash
.cursor/skills/verify-cliproxyapi/scripts/doctor
```

只读检查：服务与 mock 的 PID 存活、`/healthz` 正常、`/` 身份文案为 `CLI Proxy API Server`、带验证 API key 的 `/v1/models` 列出 `VERIFY_MODEL_ALIAS`、`/v0/management/api-keys` 接受管理密钥。全部通过才以退出码 `0` 结束。任何异常时先跑 doctor。

## 驱动（Drive）

优先使用 HTTP 辅助脚本（加载活动运行元数据、附加 Bearer 鉴权、可保存证据）：

```bash
.cursor/skills/verify-cliproxyapi/scripts/http GET /healthz
.cursor/skills/verify-cliproxyapi/scripts/http --api GET /v1/models
.cursor/skills/verify-cliproxyapi/scripts/http --mgmt GET /v0/management/api-keys
.cursor/skills/verify-cliproxyapi/scripts/http --api --save chat-completions/response.txt \
  POST /v1/chat/completions \
  --json '{"model":"verify-mock","messages":[{"role":"user","content":"ping"}]}'
```

稳定句柄（路径 / 请求头），不要用 UI 坐标：

| 句柄 | 含义 |
|------|------|
| `GET /healthz` | 存活 JSON `{"status":"ok"}` |
| `GET /` | 身份 JSON，含 `"message":"CLI Proxy API Server"` |
| `Authorization: Bearer <VERIFY_API_KEY>` | 客户端访问 `/v1/*`、`/v1beta/*` 等 |
| `GET /v1/models` | OpenAI 风格模型列表 |
| `POST /v1/chat/completions` | OpenAI 聊天补全 |
| `Authorization: Bearer <VERIFY_MGMT_KEY>` 或 `X-Management-Key` | 管理 API `/v0/management/*` |
| `GET /v0/management/api-keys` | 已配置的客户端 API keys |
| `GET /v0/management/config` | 脱敏后的运行时配置快照 |

驱动前先读 `features/README.md` 与对应功能文件。若功能图列出多个入口，只打一个方便入口的证明不完整。

## 证据（Evidence）

证明材料放在 `/tmp/cliproxyapi-verify-<RUN_ID>/evidence/<feature-id>/`（launch 后也可用 `VERIFY_EVIDENCE_DIR`）。`scripts/http` 的相对 `--save` 路径会自动落到该目录。

证明标准：

- 走真实客户端路由（`/v1/...`、`/v0/management/...`），不要走内部 setter 或仅测试钩子。
- 同时记录请求动作与结果 HTTP 状态码 + 响应体（写操作还要有二次确认读取）。
- 对聊天补全，通过断言代理响应中的助手内容 `pong-from-mock` 证明经过 mock 上游——该字符串只存在于 `scripts/mock-upstream`。
- 不要把单元测试或 `go test` 当作本技能的用户路径证明。
- mock 只允许出现在 `openai-compatibility` 已建模的生产边界（外部提供方 HTTP）。不要在进程内 stub Gin handler。

建议产物名：

- `evidence/<feature>/request.env` — 方法、路径、鉴权模式
- `evidence/<feature>/response.txt` — `scripts/http --save` 的状态码、头、体
- `evidence/<feature>/notes.txt` — 功能 ID 与覆盖的入口

## 清理（Cleanup）

```bash
.cursor/skills/verify-cliproxyapi/scripts/cleanup
```

只按本轮 pid 文件杀死服务与 mock（绝不 `pkill cli-proxy-api`）。删除 `/tmp/cliproxyapi-verify-<RUN_ID>/run/`。保留 `/tmp/cliproxyapi-verify-<RUN_ID>/evidence/`。匹配时清除 `.active-run`。

清理后须确认证据文件仍在，再宣布成功。

## 辅助脚本（Helpers）

可执行脚本均在 `.cursor/skills/verify-cliproxyapi/scripts/`：

| 脚本 | 调用方式 | 作用 |
|------|----------|------|
| `launch` | `scripts/launch` | 构建、写入脚手架配置、启动 mock + 代理 |
| `doctor` | `scripts/doctor` | 只读就绪 / 归属检查 |
| `http` | `scripts/http [--api\|--mgmt] [--save PATH] [--json BODY] METHOD /path` | 驱动带鉴权的 HTTP |
| `cleanup` | `scripts/cleanup` | 停止本轮进程；保留证据 |
| `mock-upstream` | 由 `launch` 启动 | 本地 OpenAI 兼容桩（`pong-from-mock`） |
| `common.sh` | 被其他脚本 source | 路径、端口、活动运行解析 |

## 功能地图

见 [features/README.md](features/README.md)。
