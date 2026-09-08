# 健康检查与身份

健康检查与身份让客户端在不发送 API key 的情况下，确认代理进程已启动，且响应方是 CLIProxyAPI。

## 子功能

- `healthz-get`：`GET /healthz` 返回 JSON 存活状态。
- `healthz-head`：接受 `HEAD /healthz`，状态码 200，不要求响应体。
- `root-identity`：根路径 JSON 消息标明 CLI Proxy API Server，并列出核心端点。

## 如何到达（用户视角）

- 对代理 base URL 调用 `GET /healthz`。
- 对代理 base URL 调用 `HEAD /healthz`。
- 对代理 base URL 调用 `GET /`。

## 用 scripts/http 驱动

前置条件：

- 验证实例健康（`scripts/doctor` PASS）。
- 这些路由不需要 API key。

- **存活 GET。** 请求健康检查。执行 `scripts/http --save health-and-identity/healthz.txt GET /healthz`。HTTP `200`，响应体含 `"status":"ok"`。
- **存活 HEAD。** 确认 HEAD 可用。在 `source scripts/common.sh && verify_load_meta` 之后执行 `curl -sS -o /dev/null -w '%{http_code}\n' -I "$VERIFY_BASE_URL/healthz"`。HTTP `200`。
- **根身份。** 请求根路径。执行 `scripts/http --save health-and-identity/root.txt GET /`。HTTP `200`，响应体含 `"message":"CLI Proxy API Server"` 以及端点字符串 `GET /v1/models`。
- **证明。** 将两份已保存响应保留在 `evidence/health-and-identity/`。必须能看到 status `ok` 与身份文案。

## 注意事项

- `/healthz` 是公开的；这里出现 401 说明打到了错误进程或同端口上的其他服务。
- 配置了模板密钥时，示例 API key 安全模式可能把 `GET /` 换成 HTML 警告页——验证 launch 绝不能使用那些密钥。
- doctor 已检查这些路由；功能证明仍需要保存响应产物。
