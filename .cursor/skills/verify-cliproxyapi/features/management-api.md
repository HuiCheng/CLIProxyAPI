# 管理 API

管理 API 让运维用管理密钥检查并改运行时配置。隔离验证覆盖读取、轮换客户端 api-keys、列出/上传 auth 文件。不覆盖会打公网或启动 OAuth 的管理路由。

## 子功能

- `mgmt-missing` 无管理密钥时拒绝。
- `mgmt-api-keys` Bearer 读取 api-keys。
- `mgmt-x-header` 用 `X-Management-Key` 读取。
- `mgmt-config` 读取配置快照。
- `mgmt-put-keys` PUT 轮换 api-keys 后再 GET。
- `mgmt-auth-files` 上传夹具 JSON 并 LIST。

## 如何到达（用户视角）

- `GET /v0/management/api-keys`，`Authorization: Bearer <VERIFY_MGMT_KEY>`。
- 同一路径用 `X-Management-Key`。
- `GET /v0/management/config`。
- `PUT /v0/management/api-keys`，body 为字符串数组。
- `POST /v0/management/auth-files` multipart 上传 `.json`，再 `GET /v0/management/auth-files`。
- 不带密钥调用上述 GET。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。
- launch 已设置 `secret-key` 与 `disable-control-panel: true`。

- **缺少密钥。** `scripts/http --allow-fail --save management-api/missing.txt GET /v0/management/api-keys`。HTTP `401`。
- **Bearer 读取。** `scripts/http --mgmt --save management-api/api-keys.txt GET /v0/management/api-keys`。body 含 `VERIFY_API_KEY`。
- **备用头。** `curl -H "X-Management-Key: $VERIFY_MGMT_KEY" "$VERIFY_BASE_URL/v0/management/api-keys"`。载荷与 Bearer 一致。
- **配置。** `scripts/http --mgmt --save management-api/config.txt GET /v0/management/config`。HTTP `200`。
- **写入再读。** PUT `["$VERIFY_API_KEY","verify-rotated-key"]`，再 GET。第二次 GET 必须含 rotated key。然后 PUT 回只含原 key。
- **auth 文件。** multipart 上传夹具 JSON，再 GET list。
- **证明。** 保留 missing、api-keys、after-put、auth-files。

## 注意事项

- 未配置 secret 时整组路由 404。
- PUT api-keys 会改客户端鉴权。必须恢复原 key，否则后续 `--api` 失败。
- 本地布尔/列表读取见 [management-settings](./management-settings.md)。
- `*-auth-url`、`plugin-store`、`latest-version`、`api-call` 不在本文件。见 blocked-surfaces。
