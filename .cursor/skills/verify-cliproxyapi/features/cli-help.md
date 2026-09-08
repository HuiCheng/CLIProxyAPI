# CLI 帮助

运维用 `cli-proxy-api --help` 看启动旗标。这是二进制的用户入口，不是 HTTP。

## 子功能

- `cli-help` 打印 Usage 与核心旗标。

## 如何到达（用户视角）

- 在仓库根执行构建出的二进制 `cli-proxy-api --help`。
- 验证运行里该二进制是 `VERIFY_BIN`（launch 写入 `run/cli-proxy-api`）。

## 用 scripts/http 驱动

前置条件：

- `scripts/launch` 已构建 `VERIFY_BIN`。
- 本条不走 HTTP。drive-all 直接跑二进制。

- **帮助。** 执行 `"$VERIFY_BIN" --help`，保存到 `cli-help/help.txt`。退出码 0。正文含 Go flag 写法 `-config`、`-local-model`、`-tui`。
- **证明。** 保留 `help.txt`。不要用 README 摘录代替。

## 注意事项

- `--help` 不启动服务，也不占用验证端口。
- `--claude-login` 等登录旗标只应出现在帮助文本里。不要在验证机上真的执行登录。见 blocked-surfaces。
- cleanup 会删 `VERIFY_BIN`。本条必须在 cleanup 之前跑。
