# 图片生成

图片生成让客户端调用 `POST /v1/images/generations`。验证 launch 把 `verify-mock` 标为 `image: true`，以便该别名进入图片路由。

## 子功能

- `images-success` 返回 data 列表。
- `images-auth` 无 key 时拒绝。

## 如何到达（用户视角）

- `POST /v1/images/generations`，Bearer `VERIFY_API_KEY`，JSON `{"model":"verify-mock","prompt":"a dot"}`。
- 不带 Authorization 再打一次。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。
- launch 配置里该模型 `image: true`。

- **成功。** 执行 `scripts/http --api --save images-generations/success.txt POST /v1/images/generations --json '{"model":"verify-mock","prompt":"a dot"}'`。HTTP `200`。data 中有 mock 标记（如 `revised_prompt` 或 `b64_json`）。
- **缺少鉴权。** 不加 `--api`。期望 HTTP `401`。
- **证明。** 保留 success。`/v1/images/edits` 见 [images-edits](./images-edits.md)。不要用 generations 冒充 edits。

## 注意事项

- 未声明 `image: true` 的别名会被图片路由拒绝。
- 视频路由不在本文件。见 blocked-surfaces。
