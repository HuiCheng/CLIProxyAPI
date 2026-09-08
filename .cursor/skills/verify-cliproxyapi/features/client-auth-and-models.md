# 客户端鉴权与模型

客户端鉴权与模型让 API 客户端使用配置的顶层 API key 完成鉴权，并发现代理对外暴露的模型（含 openai-compatibility 别名）。

## 子功能

- `auth-missing`：无 Bearer token 时拒绝 `/v1/models`。
- `auth-invalid`：错误 Bearer token 时拒绝 `/v1/models`。
- `auth-valid`：使用 `VERIFY_API_KEY` 时接受 `/v1/models`。
- `models-list`：返回 openai-compatibility 提供方的验证模型别名。

## 如何到达（用户视角）

- 不带 `Authorization` 调用 `GET /v1/models`。
- 使用 `Authorization: Bearer <wrong-key>` 调用 `GET /v1/models`。
- 使用 `Authorization: Bearer <VERIFY_API_KEY>` 调用 `GET /v1/models`。

## 用 scripts/http 驱动

前置条件：

- 验证实例健康（`scripts/doctor` PASS）。
- `VERIFY_MODEL_ALIAS` 默认来自 launch 元数据，为 `verify-mock`。

- **缺少密钥。** 无鉴权调用 models。执行 `scripts/http --save client-auth-and-models/missing.txt GET /v1/models`。期望 `scripts/http` 非零退出，且 HTTP `401`，响应体提到缺少 API key。
- **无效密钥。** 用错误密钥调用 models。加载元数据（`verify_load_meta`）后执行 `curl -sS -D - -o evidence/client-auth-and-models/invalid.body.json -w '\nHTTP %{http_code}\n' -H 'Authorization: Bearer definitely-wrong-key' "$VERIFY_BASE_URL/v1/models"`。期望 HTTP `401`。
- **有效密钥 + 列表。** 用验证密钥调用 models。执行 `scripts/http --api --save client-auth-and-models/models.txt GET /v1/models`。HTTP `200`，响应体含 `"object":"list"`，且 data 中有 `"id":"verify-mock"`（或当前 `VERIFY_MODEL_ALIAS`）。
- **证明。** 保存缺少、无效、有效三类响应。有效列表必须包含聊天补全将要调用的别名。

## 注意事项

- 不加 `--api` 的 `scripts/http` 会故意省略 Bearer 头——用于缺少密钥场景。
- `scripts/http` 在非 2xx 时非零退出；负面用例请从打印的 `HTTP` 行取状态码，或改用原始 `curl`。
- 模型列表为空通常表示 mock openai-compatibility 提供方未加载——重新跑 doctor，并在 `server.log` 中查找 `OpenAI-compat`。
- 模板示例密钥会以 `403 unsafe_example_api_key` 禁用 `/v1/*`；那不算成功的鉴权证明。
