# bech32-kit 任务报告书

## 一、基本信息

- 项目名称：bech32-kit
- 项目类型：MoonBit 原生编码解码基础库
- 参赛者：卓娟
- 联系电话：13855703757
- 邮箱：609588498@qq.com
- GitHub 仓库：https://github.com/MM-ai-nb/bech32-kit
- Mooncakes 包名：MM-ai-nb/bech32-kit
- 当前版本：0.1.0
- 开源许可证：MIT
- 报告日期：2026-08-20

## 二、项目背景与用途

Bech32 和 Bech32m 是常用于区块链地址、协议字段和低误读率短字符串的编码格式。MoonBit 生态中同类基础库仍然较少，上层项目如果需要处理 checksum、bit group 转换、SegWit 地址校验或批量输入诊断，通常需要重复实现相关逻辑。

bech32-kit 的目标是提供一个纯 MoonBit、可测试、可发布、可复用的 Bech32 / Bech32m 工具库，方便 MoonBit CLI、WebAssembly 应用、钱包工具、链上数据工具、文档扫描工具和教学项目直接使用。

## 三、主要功能

- Bech32 编码、解码和 checksum 校验；
- Bech32m 编码、解码和 checksum 校验；
- 8-bit 字节与 5-bit Bech32 数据之间的 bit group 转换；
- SegWit v0 到 v16 地址编码与验证；
- 结构化错误类型，便于区分非法字符、大小写混用、checksum 错误、padding 错误和 SegWit 规则错误；
- 输入 profile、规范化、checksum words 提取和 canonical 判断；
- 批量校验报告、有效数量统计、稳定错误码和错误文案；
- 诊断 severity、recommendation、hints、对比报告和可渲染文本输出；
- 可配置策略校验，支持 HRP、variant、canonical、payload 长度、SegWit 网络和 witness program 类型约束；
- 文本扫描能力，可从普通文本、多行日志或粘贴内容中抽取 Bech32 候选并生成 lint issue；
- SegWit mainnet / testnet / regtest 网络识别和 witness program 分类；
- HRP guard 与 SegWit network guard，降低地址用于错误命名空间或网络的风险；
- 可运行示例，输出标准 SegWit v0 地址；
- 单元测试与白盒测试覆盖正常路径、错误路径和边界输入；
- GitHub Actions 持续集成，自动执行 check、build、test 和示例运行。

## 四、使用方法

安装 Mooncakes 包：

```bash
moon add MM-ai-nb/bech32-kit
```

本地构建与测试：

```bash
moon check
moon build
moon test
moon run cmd/main
```

最小使用示例：

```moonbit
let encoded = @bech32.encode("moon", [0, 1, 2, 3, 4]).unwrap()
let decoded = @bech32.decode(encoded).unwrap()
println(decoded.hrp)
```

策略校验示例：

```moonbit
let policy = @bech32.bitcoin_mainnet_segwit_policy()
let check = @bech32.check_with_policy(address, policy)
println(check.accepted)
```

文本扫描示例：

```moonbit
let report = @bech32.scan_text("address=" + address)
println(report.total_candidates)
println(report.accepted)
```

示例程序输出：

```text
bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4
```

## 五、项目结构

```text
.
├── bech32-kit.mbt             # 核心编码、解码、SegWit 和基础诊断接口
├── bech32-kit_diagnostics.mbt # 诊断、汇总、对比和文本渲染
├── bech32-kit_policy.mbt      # 可配置策略校验和策略汇总
├── bech32-kit_scan.mbt        # 文本扫描、finding 和 lint issue
├── bech32-kit_test.mbt        # 黑盒公开 API 测试
├── bech32-kit_wbtest.mbt      # 白盒与边界测试
├── cmd/main                   # 可运行示例
├── README.md                  # 项目说明与使用方法
├── API.md                     # API 文档
├── SUBMISSION.md              # 项目申报信息
├── 卓娟-MoonBit八月黑客松项目申报书.md # 可提交的 Markdown 版申报书
├── MOONCAKES.md               # Mooncakes 发布准备说明
├── TASK_REPORT.md             # 任务报告书
├── DESIGN.md                  # 技术方案与功能边界
├── CHANGELOG.md               # 更新日志
├── moon.mod                   # MoonBit 包与 Mooncakes 元数据
└── .github/workflows/ci.yml   # 持续集成配置
```

## 六、测试与构建记录

2026-08-20 已在本地执行以下命令：

```bash
moon check
moon build
moon test
moon run cmd/main
moon check --deny-warn
moon test --deny-warn
moon fmt --check
moon info
```

执行结果：

- `moon check` 通过；
- `moon build` 通过；
- `moon test` 通过，结果为 `Total tests: 28, passed: 28, failed: 0.`；
- `moon run cmd/main` 通过，输出 `bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4`；
- `moon check --deny-warn`、`moon test --deny-warn`、`moon fmt --check` 和 `moon info` 均通过。

当前有效 MoonBit 库核心实现约 3662 行，含可运行示例约 3670 行，含测试与示例共 4258 行。统计时排除了 `_build` 生成目录、生成接口文件、空行和 `//` 注释行。核心实现不依赖第三方运行时，新增代码集中在诊断、批量校验、策略校验、文本扫描和 SegWit 元信息能力上。

## 七、持续集成

项目已配置 GitHub Actions 工作流 `.github/workflows/ci.yml`。当仓库发生 push 或 pull request 时，CI 会自动执行：

1. 安装 MoonBit 工具链；
2. 执行 `moon check`；
3. 执行 `moon build`；
4. 执行 `moon test`；
5. 执行 `moon run cmd/main` 验证示例可运行。

## 八、Mooncakes 发布准备

项目已在 `moon.mod` 中配置 Mooncakes 元数据：

- 包名：`MM-ai-nb/bech32-kit`
- 版本：`0.1.0`
- 仓库：`https://github.com/MM-ai-nb/bech32-kit.git`
- 许可证：`MIT`
- README：`README.md`

正式发布需要使用具有对应 owner 权限的 Mooncakes 账号登录后执行：

```bash
moon login
moon publish --dry-run
moon publish
```

当前尚未执行正式发布，原因是发布步骤需要先登录 `MM-ai-nb` 对应的 Mooncakes 账号，避免账号与包名、参赛者信息混淆。发布完成后应补充 mooncakes.io 包页面链接和版本发布记录。

## 九、开源许可证与第三方依赖

项目采用 MIT License。实现依据公开标准 BIP-0173 与 BIP-0350 的算法说明和公开测试向量，不移植第三方源码，不包含外部素材或私有代码。项目当前没有引入额外第三方运行时依赖。

## 十、功能边界

项目专注于 Bech32 / Bech32m 字符串处理、checksum 验证、bit group 转换、SegWit 地址校验、输入诊断、策略校验和文本扫描，不处理私钥、助记词、网络请求、钱包账户管理或链上交易签名。这样的边界可以降低安全风险，也便于后续作为独立基础库维护。

## 十一、后续维护计划

- 补充更多公开测试向量与 fuzz 风格边界测试；
- 根据 MoonBit 生态变化维护 Mooncakes 包元数据；
- 在真实钱包工具、CLI 或 WebAssembly 应用中验证 API 易用性；
- 根据使用反馈扩展策略模板、错误信息和文档示例；
- 保持语义化版本发布和 CHANGELOG 记录。

## 十二、验收条件对照

| 验收条件 | 当前状态 |
| --- | --- |
| 以 MoonBit 作为主要实现语言 | 已满足 |
| 代码仓库公开且可以正常访问 | 本地目标远端已配置为 https://github.com/MM-ai-nb/bech32-kit，推送后需检查默认分支和 CI |
| 提供清晰、完整的 README | 已满足 |
| 说明项目用途、主要功能及使用方法 | 已满足 |
| 提供可以实际运行的示例 | 已满足 |
| 配置持续集成 CI | 已满足 |
| 提供可运行的测试 | 已满足 |
| 项目能够正常构建 | 已满足 |
| 按要求发布至 mooncakes.io | 元数据已配置，待使用 MM-ai-nb 对应 Mooncakes 账号登录发布 |
| 开发过程和提交记录可以追踪 | 当前分支基于 MM-ai-nb/main 整理，本次新增提交将使用卓娟身份信息 |
| 项目具有明确的功能边界和后续维护价值 | 已满足 |
| 第三方代码、素材和依赖符合开源许可证要求 | 已满足 |
