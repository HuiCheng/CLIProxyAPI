# 图片编辑

图片编辑让客户端调用 `POST /v1/images/edits`。验证 launch 把 `verify-mock` 标为 `image: true`，请求经 openai-compatibility 落到本地 mock。

## 子功能

- `images-edits-success` 返回 data 列表。
- `images-edits-auth` 无 key 时拒绝。

## 如何到达（用户视角）

- `POST /v1/images/edits`，Bearer `VERIFY_API_KEY`，JSON 含 `model`、`prompt`、以及一张输入图。
- 不带 Authorization 再打一次。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。
- launch 配置里该模型 `image: true`。

- **成功。** 执行 `scripts/http --api --save images-edits/success.txt POST /v1/images/edits --json '{"model":"verify-mock","prompt":"a dot","image":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="}'`。HTTP `200`。data 中有 mock 标记（`revised_prompt` 或 `b64_json`）。
- **缺少鉴权。** 不加 `--api`。期望 HTTP `401`。
- **证明。** 保留 success。不要用 `/v1/images/generations` 冒充本入口。

## 注意事项

- 未声明 `image: true` 的别名会被图片路由拒绝。
- multipart `image` 字段是另一客户端形态。本基线用 JSON。
- 视频编辑不在本文件。见 isolated-errors。
