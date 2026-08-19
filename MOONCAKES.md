# Mooncakes 发布准备说明

## 当前包信息

- 包名：`MM-ai-nb/bech32-kit`
- 版本：`0.1.0`
- 仓库：`https://github.com/MM-ai-nb/bech32-kit.git`
- README：`README.md`
- License：`MIT`
- 主要语言：MoonBit

以上信息已写入 `moon.mod`，满足 Mooncakes 发布前的基础元数据要求。发布前最后核对浏览器授权和 `moon` 登录会话均指向 `MM-ai-nb`。

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

## 发布命令

正式发布需要使用 `MM-ai-nb` 对应的 Mooncakes 登录会话：

```bash
moon login
moon publish --dry-run
moon publish
```

建议流程：

1. 推送到 GitHub 仓库 `https://github.com/MM-ai-nb/bech32-kit` 的默认分支。
2. 使用 `MM-ai-nb` 对应的 Mooncakes 账号执行 `moon login`。
3. 执行 `moon publish --dry-run` 检查包内容。
4. dry run 通过后执行 `moon publish`。
5. 发布完成后记录 mooncakes.io 包页面链接，并更新 `CHANGELOG.md`、`TASK_REPORT.md` 和 README。

## 当前状态

- Mooncakes 元数据：已配置。
- 本地构建测试：已通过。
- GitHub 远程仓库：已配置为 `https://github.com/MM-ai-nb/bech32-kit.git`，仍需把本地新增提交推送到默认分支。
- Mooncakes 正式发布：待登录正确账号后执行。

执行发布前需确认 GitHub 浏览器授权页和 Mooncakes 登录会话显示的是 `MM-ai-nb`，避免账号与包名混淆。
