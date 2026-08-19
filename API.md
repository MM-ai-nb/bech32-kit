# API 说明

## 数据类型

`Variant` 表示 checksum 变体：

- `Bech32`
- `Bech32m`

`Decoded` 是普通 Bech32 / Bech32m 解码结果：

- `hrp : String`
- `data : Array[Int]`
- `variant : Variant`

`SegwitAddress` 是 SegWit 地址解码结果：

- `hrp : String`
- `version : Int`
- `program : Array[Int]`
- `variant : Variant`

`CaseStyle` 表示输入字符串的 ASCII 字母大小写状态：

- `CaseNoLetters`
- `CaseLower`
- `CaseUpper`
- `CaseMixed`

`SegwitNetwork` 表示从 HRP 推断出的常见 SegWit 网络：

- `NetworkBitcoinMainnet`
- `NetworkBitcoinTestnet`
- `NetworkBitcoinRegtest`
- `NetworkUnknown(String)`

`WitnessProgramKind` 表示常见 witness program 类型：

- `WitnessProgramP2WPKH`
- `WitnessProgramP2WSH`
- `WitnessProgramTaproot`
- `WitnessProgramOther`

`InputProfile` 是不依赖 checksum 的输入结构画像，包含总长度、分隔符位置、HRP 长度、数据段长度、payload 长度、checksum 长度、大小写状态等字段。

`Bech32Info` 是有效 Bech32 / Bech32m 字符串的诊断结果，包含规范化文本、HRP、payload words、checksum words、variant、长度信息和是否为有效 SegWit 地址。

`SegwitInfo` 是有效 SegWit 地址的诊断结果，包含网络分类、witness version、program、program 长度、checksum variant 和 witness program 类型。

`ValidationReport` 是面向批量工具的稳定报告结构，包含 `valid`、`segwit_valid`、`variant`、`hrp`、`error_code`、`error_message` 和基础长度信息。

`Diagnostic` 是更高层的诊断结果，包含严重级别、推荐修复动作、提示信息、SegWit 网络和 witness program 类型。

`Bech32Policy` 用于表达业务侧验收规则，例如是否只接受 lowercase canonical、是否只允许 Bech32m、是否必须是 mainnet SegWit 地址。

`PolicyCheck` / `PolicySummary` 用于单条或批量策略校验。

`ScanOptions` / `ScanReport` / `ScanFinding` / `ScanIssue` 用于从普通文本、多行日志或提交材料中抽取 Bech32 候选并生成扫描报告。

`Bech32Error` 覆盖空输入、长度超限、分隔符缺失、HRP 错误、数据字符错误、checksum 错误、bit group 错误、padding 错误和 SegWit 规则错误。

## 编码与解码

```moonbit
encode(hrp, data)
encode_m(hrp, data)
encode_with_variant(hrp, data, variant)
decode(input)
```

`data` 是 5-bit 数组，每个值必须在 `0..31`。编码输出统一为小写字符串；解码接受全大写或全小写输入，并返回小写 HRP。

## 规范化、提取与诊断

```moonbit
variant_name(variant)
case_style_name(style)
network_name(network)
witness_program_kind_name(kind)
classify_case(input)
profile(input)
normalize(input)
is_canonical(input)
is_bech32(input)
is_bech32m(input)
hrp_of(input)
data_words_of(input)
checksum_words_of(input)
decode_with_hrp(input, expected_hrp)
inspect(input)
validation_report(input)
validate_many(inputs)
valid_count(inputs)
invalid_count(inputs)
all_valid(inputs)
diagnose(input)
diagnose_segwit(input)
diagnose_many(inputs)
diagnose_segwit_many(inputs)
summarize_inputs(inputs)
summarize_segwit_inputs(inputs)
summarize_diagnostics(diagnostics)
compare_inputs(left, right)
compare_diagnostics(left, right)
comparison_hints(report)
render_diagnostic(diagnostic)
render_validation_summary(summary)
render_comparison(report)
summary_has_errors(summary)
summary_is_clean(summary)
summary_has_segwit(summary)
```

`profile` 不做 checksum 校验，适合在错误提示中展示输入结构；`inspect` 会先完成完整校验，再返回 HRP、payload、checksum 和 variant 信息。`validation_report` 和 `validate_many` 适合 CLI、网页表单或批量导入工具使用，错误码由 `error_code` 保持稳定。

`diagnose` 在 `validation_report` 基础上补充严重级别、推荐动作和 hints；`summarize_inputs` 适合批量质量统计；`compare_inputs` 可用于判断两个候选字符串在 HRP、variant、网络、canonical 状态或错误类型上是否一致。

## 策略校验

```moonbit
any_bech32_policy()
canonical_bech32_policy()
bech32_only_policy()
bech32m_only_policy()
bitcoin_segwit_policy()
bitcoin_mainnet_segwit_policy()
bitcoin_testnet_segwit_policy()
bitcoin_regtest_segwit_policy()
taproot_mainnet_policy()
policy_with_name(policy, name)
policy_with_hrps(policy, hrps)
policy_with_payload_bounds(policy, min_payload_words, max_payload_words)
policy_requiring_canonical(policy, required)
check_with_policy(input, policy)
check_many_with_policy(inputs, policy)
summarize_policy_checks(checks)
summarize_policy_inputs(inputs, policy)
policy_accepts(input, policy)
policy_rejects(input, policy)
accepted_inputs(inputs, policy)
rejected_inputs(inputs, policy)
first_policy_failure(inputs, policy)
policy_failure_code(failure)
policy_failure_message(failure)
policy_failure_recommendation(failure)
render_policy_check(check)
render_policy_summary(summary)
```

策略层不会替代底层 checksum 校验，而是在底层结果之上增加业务约束。例如钱包可以使用 `bitcoin_mainnet_segwit_policy` 阻止 testnet 地址进入 mainnet 流程，也可以使用 `taproot_mainnet_policy` 只接受 Bech32m Taproot 地址。

## bit group 与字节

```moonbit
convert_bits(data, from_bits, to_bits, pad)
encode_bytes(hrp, bytes, variant)
decode_bytes(input)
```

字节接口使用 `Array[Int]` 表示 octet，每个值必须在 `0..255`。`convert_bits(..., pad=false)` 会拒绝非规范 padding。

## SegWit 地址

```moonbit
encode_segwit(hrp, version, program)
decode_segwit(input)
is_valid(input)
is_valid_segwit(input)
segwit_network(hrp)
is_standard_segwit_hrp(hrp)
segwit_network_of(input)
witness_program_kind(version, program_length)
inspect_segwit(input)
decode_segwit_on_network(input, expected)
```

`encode_segwit` 会根据版本自动选择 checksum：version `0` 使用 Bech32，version `1..16` 使用 Bech32m。`decode_segwit` 会验证 witness version、program 长度和 checksum 变体是否匹配。

`segwit_network` 会识别 `bc`、`tb`、`bcrt`，其余 HRP 返回 `NetworkUnknown`。`witness_program_kind` 会标识 P2WPKH、P2WSH、Taproot 或其他 witness program。`decode_segwit_on_network` 可用于避免把 mainnet / testnet / regtest 地址误用于错误环境。

## 文本扫描

```moonbit
default_scan_options()
segwit_scan_options()
scan_options_with_min_length(options, min_length)
scan_options_with_max_length(options, max_length)
scan_options_include_invalid(options, include_invalid)
scan_options_mode(options, mode)
scan_options_require_canonical(options, require_canonical)
scan_options_require_standard_segwit_hrp(options, require_standard_segwit_hrp)
scan_options_expected_hrp(options, expected_hrp)
scan_options_expected_network(options, expected_network)
scan_options_accept_uppercase(options, accept_uppercase)
scan_options_accept_mixed_case(options, accept_mixed_case)
scan_options_boundary_style(options, boundary_style)
scan_options_deduplicate(options, deduplicate)
scan_text(text)
scan_segwit_text(text)
scan_text_with_options(text, options)
scan_lines(lines)
scan_segwit_lines(lines)
scan_lines_with_options(lines, options)
lint_scan_report(report, options)
render_scan_report(report)
render_scan_finding(finding)
render_scan_issue(issue)
render_scan_issues(issues)
```

扫描层适合处理日志、README 片段、导入表格文本或用户粘贴内容。默认扫描只返回被接受的候选；如果要收集错误候选用于提示，可通过 `scan_options_include_invalid(..., true)` 开启。

## 错误码与错误文案

```moonbit
error_code(err)
error_message(err)
```

错误码用于日志、批量报告和 UI 分支判断；错误文案用于直接展示给用户。新增的 HRP 与网络防误用错误包括：

- `UnexpectedHrp(expected, actual)`
- `UnexpectedNetwork(expected, actual)`
