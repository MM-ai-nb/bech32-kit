# MoonBit 八月黑客松项目申报书

## 一、项目基本信息

- 项目名称：bech32-kit
- 参赛者：卓娟
- 联系方式：见飞书报名表 / 正式提交材料
- GitHub 仓库：https://github.com/MM-ai-nb/bech32-kit
- Mooncakes 包名：MM-ai-nb/bech32-kit
- Mooncakes 页面：https://mooncakes.io/docs/MM-ai-nb/bech32-kit
- 主要实现语言：MoonBit
- 开源许可证：MIT
- 当前版本：0.1.0

## 二、项目简介

`bech32-kit` 是一个纯 MoonBit 实现的 Bech32 / Bech32m 编码、解码、校验、诊断、策略校验、文本扫描与 SegWit 地址验证库。项目面向 MoonBit CLI、WebAssembly 应用、钱包工具、链上数据工具和协议测试场景，解决上层项目重复实现 checksum、bit group 转换、地址规则验证和错误诊断的问题。

## 三、现有基础与本次工作

项目已具备可运行的 MoonBit 包结构、MIT 许可证、README、API 文档、设计说明、任务报告书、CHANGELOG、示例程序和 GitHub Actions CI 配置。本次黑客松重点完成并扩展以下能力：

- Bech32 与 Bech32m 编码、解码、checksum 校验和大小写规范化；
- 8-bit 字节与 5-bit data words 的可逆转换；
- SegWit v0 到 v16 地址编码、解码、网络识别和 witness program 类型判断；
- 结构化错误类型、稳定错误码、诊断报告、批量校验和可打印说明；
- `Bech32Policy` 策略校验，支持 variant、HRP、payload 长度、canonical、网络和 witness program 类型约束；
- 自由文本、多行日志和粘贴内容扫描，输出候选位置、重复候选、策略 lint issue 和统计结果。

## 四、技术路线

项目核心按 BIP-0173 与 BIP-0350 的公开规范实现多项式 checksum、HRP 展开、字符集映射和 bit group 转换。基础层提供编码、解码、checksum 与错误类型；SegWit 层处理 witness version、program 长度、网络 HRP 与 Bech32 / Bech32m 变体规则；扩展层提供诊断、策略校验、批量报告和文本扫描。项目只处理字符串格式和本地输入分析，不涉及私钥、助记词、联网请求、钱包账户或交易签名。

## 五、预期成果与验收方式

项目预期交付一个真实可复用、边界清晰、可测试、可发布的 MoonBit 基础库。当前本地验收结果如下：

- `moon fmt --check`、`moon check --deny-warn`、`moon build`、`moon test --deny-warn`、`moon run cmd/main`、`moon info` 均已通过；
- 单元测试与白盒测试共 28 个，结果为 `Total tests: 28, passed: 28, failed: 0.`；
- 示例程序输出 `bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4`；
- 当前有效 MoonBit 行数为 4258 行，统计时排除 `_build`、生成接口文件、空行和 `//` 注释行；
- README、API.md、DESIGN.md、TASK_REPORT.md、MOONCAKES.md 和 Word 版任务报告书已准备完成；
- GitHub 默认分支已推送到 `MM-ai-nb/bech32-kit`，GitHub Actions CI 已通过，Mooncakes `0.1.0` 已发布并可访问。

## 六、原创性与开源合规

本项目为原创 MoonBit 实现，不移植第三方源码，不包含来源不明素材、私有代码或商业代码。算法实现依据公开标准 BIP-0173 与 BIP-0350 的文字规范和公开测试向量，项目采用 MIT License，当前不引入额外第三方运行时依赖。项目差异点在于同时覆盖基础编码、SegWit 地址、诊断报告、策略校验、批量输入和文本扫描，适合作为 MoonBit 生态中可长期维护的编码基础库。
