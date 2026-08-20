# bech32-kit

bech32-kit 是一个纯 MoonBit 实现的 Bech32 / Bech32m 编码、解码、校验、诊断分析、策略校验、文本扫描和 SegWit 地址验证库。它面向需要在 MoonBit 或 WebAssembly 场景中处理紧凑校验字符串、钱包地址、链上工具、配置短码、日志文本和协议字段的开发者。

## 项目解决的问题

Bech32 和 Bech32m 常用于低误读率的人类可读编码。MoonBit 生态中这类基础编码库仍然较少，项目提供可复用的 MoonBit 原生实现，避免上层项目临时复制 checksum 逻辑或依赖外部运行时。库会返回结构化错误、稳定的校验报告、策略拒绝原因和文本扫描结果，便于调用者区分 checksum 错误、大小写错误、非法字符、bit 转换错误、HRP 不匹配、网络不匹配、非规范地址和 SegWit 规则错误。

## 适用场景

- MoonBit 钱包工具或链上数据工具；
- SegWit 地址编码、解码和输入校验；
- WebAssembly 应用中的地址格式检查；
- CLI 工具中的 Bech32 / Bech32m 字符串处理；
- 日志、剪贴板文本、表单备注中的地址候选串扫描；
- 地址导入流程中的 HRP / 网络 / Taproot 策略校验；
- 协议测试 fixture 生成和教学项目中的编码算法演示。

## 安装方式

```bash
moon add MM-ai-nb/bech32-kit
```

Mooncakes 包名：

```text
MM-ai-nb/bech32-kit
```

Mooncakes 页面：

```text
https://mooncakes.io/docs/MM-ai-nb/bech32-kit
```

> `0.1.0` 已使用 `MM-ai-nb` 对应的 Mooncakes 登录会话发布。

## 最小使用示例

```moonbit
let encoded = @bech32.encode("moon", [0, 1, 2, 3, 4]).unwrap()
let decoded = @bech32.decode(encoded).unwrap()
println(decoded.hrp)
```

诊断示例：

```moonbit
let report = @bech32.validation_report("A12UEL5L")
println(report.valid)
println(report.variant)

let info = @bech32.inspect("A12UEL5L").unwrap()
println(@bech32.case_style_name(info.case_style))
```

文本扫描和策略校验示例：

```moonbit
let report = @bech32.scan_segwit_text("pay bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4")
println(report.segwit_valid)

let policy = @bech32.bitcoin_mainnet_segwit_policy()
let check = @bech32.check_with_policy(
  "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4",
  policy,
)
println(check.accepted)
```

可运行示例：

```bash
moon run cmd/main
```

示例会输出一个 Bech32 SegWit v0 地址：

```text
bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4
```

## 核心功能

- `encode` / `decode`：Bech32 编码、解码与 checksum 验证；
- `encode_m` / `encode_with_variant`：Bech32m 或显式变体编码；
- `convert_bits`：通用 bit group 转换，支持 canonical padding 校验；
- `encode_bytes` / `decode_bytes`：字节数组与 Bech32 数据互转；
- `encode_segwit` / `decode_segwit`：BIP-0173 和 BIP-0350 SegWit 地址编码与验证；
- `is_valid` / `is_valid_segwit`：快速布尔校验接口；
- `profile` / `inspect`：输入结构分析、checksum word 提取和规范化信息；
- `validation_report` / `validate_many`：面向 CLI 或 UI 的单条与批量校验报告；
- `diagnose` / `diagnose_segwit` / `summarize_diagnostics`：带 severity、recommendation 和 hints 的诊断报告；
- `check_with_policy` / `summarize_policy_inputs`：按 Bech32、Bech32m、HRP、payload 长度、SegWit 网络和 program kind 执行高层策略校验；
- `scan_text` / `scan_segwit_text` / `scan_lines_with_options`：从自由文本或多行文本中提取候选串并批量诊断；
- `lint_scan_report` / `render_scan_report`：对扫描结果输出策略问题、重复候选和可打印报告；
- `normalize` / `is_canonical` / `hrp_of` / `data_words_of` / `checksum_words_of`：常用提取和规范化工具；
- `segwit_network` / `inspect_segwit` / `decode_segwit_on_network`：SegWit 网络识别、witness program 分类和网络防误用校验；
- `error_code` / `error_message`：稳定错误码和可展示错误文案；
- `Bech32Error`：结构化错误枚举，覆盖主要失败路径。

## 项目文档

- `API.md`：公开 API、数据类型和错误说明；
- `DESIGN.md`：技术方案、测试策略和功能边界；
- `TASK_REPORT.md`：任务报告书与验收条件对照；
- `SUBMISSION.md`：项目申报书；
- `卓娟-MoonBit八月黑客松项目申报书.md`：可直接提交的 Markdown 版申报书；
- `MOONCAKES.md`：Mooncakes 发布准备、命令和状态记录；
- `CHANGELOG.md`：版本更新记录；
- `docs/任务报告书-卓娟-bech32-kit.docx`：可提交的 Word 版任务报告书。

## 支持范围

- Bech32 checksum 常量 `1`；
- Bech32m checksum 常量 `0x2bc830a3`；
- HRP 可打印 ASCII 范围校验；
- 整串大小写一致性校验与小写规范化输出；
- 5-bit 数据值范围校验；
- SegWit witness version `0..16`；
- SegWit v0 程序长度 `20` 或 `32` 字节；
- SegWit v1 到 v16 使用 Bech32m 的规则校验；
- Bitcoin mainnet / testnet / regtest HRP 识别；
- P2WPKH、P2WSH、Taproot 常见 witness program 分类；
- 批量输入校验统计和稳定错误报告输出；
- 可配置策略校验，覆盖 canonical、variant、HRP、payload 长度、SegWit 网络和 witness program 类型；
- 文本候选串扫描，支持普通 Bech32、SegWit 专用模式、网络过滤、HRP 过滤、重复候选识别和无效候选诊断。

## 暂不支持范围

- 自动纠错或错误位置建议；
- 文件系统扫描、网络请求或钱包私钥处理；文本扫描仅处理调用者传入的字符串；
- Unicode HRP，Bech32 标准 HRP 使用可打印 ASCII；
- 超出 90 字符限制的非标准扩展编码。

## 本地运行与验收

```bash
moon fmt --check
moon check --deny-warn
moon build
moon test --deny-warn
moon run cmd/main
moon info
```

`0.1.0` 已发布到 Mooncakes；后续版本发布仍需使用 `MM-ai-nb` 对应的 Mooncakes 登录会话，避免账号信息混淆。

测试覆盖正常向量、错误输入、边界条件、bit 转换、字节导出、诊断报告、批量校验、策略校验、文本扫描、SegWit v0/v1 编解码、网络识别与主要错误路径。

## 开源许可证与参考说明

项目采用 MIT License。实现参考公开标准 BIP-0173（Bech32）与 BIP-0350（Bech32m）的算法描述和测试向量，未移植第三方源码，不包含外部素材或私有代码。
