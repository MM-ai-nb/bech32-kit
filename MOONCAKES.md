# Mooncakes 发布记录

## 当前包信息

- 包名：`MM-ai-nb/bech32-kit`
- 版本：`0.1.0`
- 仓库：`https://github.com/MM-ai-nb/bech32-kit.git`
- Mooncakes 页面：`https://mooncakes.io/docs/MM-ai-nb/bech32-kit`
- README：`README.md`
- License：`MIT`
- 主要语言：MoonBit

以上信息已写入 `moon.mod`。`0.1.0` 已使用 `MM-ai-nb` 对应的 Mooncakes 登录会话发布。

## 发布前本地检查

发布前建议在仓库根目录执行：

```bash
moon fmt --check
moon check
moon build
moon test
moon run cmd/main
moon check --deny-warn
moon test --deny-warn
moon info
```

2026-08-20 本地检查记录：

- `moon fmt --check`：通过
- `moon check`：通过
- `moon build`：通过
- `moon test`：通过，28 个测试全部通过
- `moon run cmd/main`：通过，输出 `bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4`
- `moon check --deny-warn`：通过
- `moon test --deny-warn`：通过
- `moon info`：通过

## 发布记录

2026-08-20 发布确认：

- `moon whoami`：`MM-ai-nb`
- `moon publish --dry-run`：服务器返回 `202 Accepted`，detail 为 `Dry run completed successfully`
- `moon publish`：服务器返回 `200 OK`
- Mooncakes 页面访问检查：`https://mooncakes.io/docs/MM-ai-nb/bech32-kit` 返回 200

## 当前状态

- Mooncakes 元数据：已配置。
- 本地构建测试：已通过。
- GitHub 远程仓库：已推送到 `https://github.com/MM-ai-nb/bech32-kit.git` 的默认分支。
- GitHub Actions CI：已通过。
- Mooncakes 正式发布：已完成，版本 `0.1.0`。

后续发布新版本前仍需确认 GitHub 浏览器授权页和 Mooncakes 登录会话显示的是 `MM-ai-nb`，避免账号与包名混淆。
