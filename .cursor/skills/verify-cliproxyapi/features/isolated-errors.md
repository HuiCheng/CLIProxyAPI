# 隔离环境下的可观察失败

这些入口已注册。隔离 mock 给不出成功语义。必须打一次并保存真实状态码。禁止把 chat 成功当成这些入口已验证。

## 子功能

- `alpha-search` 与 Codex 别名，无 Codex 凭据。
- `videos` 与 `/openai/v1/videos*`，无视频上游。
- `keep-alive` 默认未注册。
- `management-html` 本轮关闭面板下载。

## 如何到达（用户视角）

- `POST /v1/alpha/search` 与 `POST /backend-api/codex/alpha/search`。
- `POST /v1/videos`、`/videos/generations`、`/videos/edits`、`/videos/extensions`，以及 `GET /v1/videos/:request_id`。
- `POST /openai/v1/videos`，以及 `GET /openai/v1/videos/:id` 与 `/content`。
- `GET /keep-alive`。
- 浏览器打开 `/management.html`。

## 用 scripts/http 驱动

前置条件：

- `scripts/doctor` PASS。
- 下列成功前置**当前不成立**。本文件要证明的是隔离结果，不是上游成功。

- **alpha-search。** `scripts/http --allow-fail --api --save isolated-errors/alpha-search.txt POST /v1/alpha/search --json '{"id":"verify-search","model":"verify-mock"}'`。Codex 别名同样保存。正文不得含 `pong-from-mock` 当成功。
- **视频。** 对上表视频路径 `--allow-fail --api` 各打一次。保存状态码。
- **keep-alive。** `scripts/http --allow-fail --save isolated-errors/keep-alive.txt GET /keep-alive`。期望 HTTP `404`。
- **面板。** `scripts/http --allow-fail --save isolated-errors/management-html.txt GET /management.html`。本轮 `disable-control-panel: true`，这不是面板下载成功。
- **证明。** 每条入口一份响应。notes 写清「隔离失败，不是功能成功」。

## 注意事项

- 跳过真实 OAuth / TUI / 插件商店仍在 blocked-surfaces。那些路径连隔离探测都不要发，因为会打公网或开浏览器。
- 若以后给视频或 alpha-search 补了隔离 mock，把对应行移出本文件，加入可驱动表。
