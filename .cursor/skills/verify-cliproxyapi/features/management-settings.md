# 管理设置

管理设置让运维读取本地配置快照，并改不会打公网的布尔项。api-keys 与 auth-files 在 [management-api](./management-api.md)。

## 子功能

- `mgmt-settings-reads` 读取本地 GET。
- `mgmt-debug-put` PUT `debug` 后再读，并恢复。

## 如何到达（用户视角）

- `GET /v0/management/config.yaml`，Bearer `VERIFY_MGMT_KEY`。
- `GET /v0/management/debug`、`logging-to-file`、`request-log`、`ws-auth`、`request-retry`、`usage-statistics-enabled`、`proxy-url`、`routing/strategy`、各提供方 `*-api-key`、`openai-compatibility`、`logs`、`usage-queue`、`get-auth-status`、`plugins`。
- `PUT /v0/management/debug`，body `{"value":true}`，再 GET，再 PUT 回 `false`。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。
- launch 已设置 `secret-key`。

- **本地读取。** 对下列路径各 `GET` 一次，保存到 `management-settings/<name>.txt`。期望 HTTP `200`。

  `config.yaml`、`debug`、`logging-to-file`、`logs-max-total-size-mb`、`error-logs-max-files`、`usage-statistics-enabled`、`proxy-url`、`quota-exceeded/switch-project`、`quota-exceeded/switch-preview-model`、`api-key-usage`、`usage-queue`、`gemini-api-key`、`interactions-api-key`、`request-error-logs`、`request-log`、`ws-auth`、`request-retry`、`max-retry-credentials`、`max-retry-interval`、`force-model-prefix`、`routing/strategy`、`claude-api-key`、`codex-api-key`、`xai-api-key`、`openai-compatibility`、`vertex-api-key`、`oauth-excluded-models`、`oauth-model-alias`、`oauth-request-scoped-errors`、`get-auth-status`、`plugins`。

- **日志关闭。** launch 把 `logging-to-file` 设为 false。`GET /v0/management/logs` 期望 HTTP `400`，正文含 `logging to file disabled`。
- **auth 文件模型。** `GET /v0/management/auth-files/models?name=verify-auth-upload.json`（先完成 management-api 上传）。HTTP `200`。

- **写入再读。** PUT `/v0/management/debug` `{"value":true}`。GET 必须含 `"debug":true`。再 PUT `{"value":false}`。
- **证明。** 保留 `config.yaml`、`debug`、`debug-after-put`。

## 注意事项

- `latest-version`、`plugin-store`、`*-auth-url`、`POST /api-call` 不在本文件。见 blocked-surfaces。
- PUT debug 会改运行时配置。必须恢复。
- `GET /plugins` 只证明本地空列表，不证明商店安装。
