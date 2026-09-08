# 管理 API

管理 API 让运维人员使用管理密钥完成鉴权，并在不依赖可选控制面板 HTML 资源的情况下检查运行时配置（例如客户端 API keys）。

## 子功能

- `mgmt-missing`：无管理密钥时拒绝 `/v0/management/api-keys`。
- `mgmt-invalid`：错误密钥时拒绝 `/v0/management/api-keys`。
- `mgmt-api-keys`：有效管理密钥下返回已配置的客户端 API keys。
- `mgmt-config`：有效管理密钥下返回配置快照。

## 如何到达（用户视角）

- 使用 `Authorization: Bearer <VERIFY_MGMT_KEY>` 调用 `GET /v0/management/api-keys`。
- 使用请求头 `X-Management-Key: <VERIFY_MGMT_KEY>` 调用 `GET /v0/management/api-keys`。
- 使用相同管理鉴权调用 `GET /v0/management/config`。
- 不带密钥或带错误密钥调用上述路由，观察拒绝行为。

## 用 scripts/http 驱动

前置条件：

- 验证实例健康（`scripts/doctor` PASS）。
- launch 已将 `remote-management.secret-key` 设为 `VERIFY_MGMT_KEY`，并设置 `disable-control-panel: true`。

- **缺少密钥。** 未鉴权调用 api-keys。执行 `scripts/http --save management-api/missing.txt GET /v0/management/api-keys`。期望 HTTP `401` 与缺少密钥错误。
- **Bearer 成功。** 读取 api-keys。执行 `scripts/http --mgmt --save management-api/api-keys.txt GET /v0/management/api-keys`。HTTP `200`，响应体含 `VERIFY_API_KEY`。
- **备用请求头。** 用 `X-Management-Key` 再测一次。`verify_load_meta` 后执行 `curl -sS -H "X-Management-Key: $VERIFY_MGMT_KEY" "$VERIFY_BASE_URL/v0/management/api-keys"`。JSON 载荷应与 Bearer 一致。
- **配置快照。** 读取 config。执行 `scripts/http --mgmt --save management-api/config.txt GET /v0/management/config`。HTTP `200` JSON 配置对象。
- **证明。** 保存成功的 `api-keys` 与 `config` 响应。确认 api-keys 列表匹配 launch 密钥，而不是示例模板。

## 注意事项

- 未配置 secret 时管理路由不会注册（404）。验证 launch 总会设置 secret。
- 非本机远端客户端需要 `allow-remote: true`；验证绑定 `127.0.0.1` 并保持 allow-remote 为 false。
- 失败鉴权次数过多可能临时封禁客户端 IP——请使用正确的 `VERIFY_MGMT_KEY`。
- 不要把 `/management.html` 面板下载当作必需项；launch 已禁用控制面板资源路径。
