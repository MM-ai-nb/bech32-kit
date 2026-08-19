# Changelog

## Unreleased - 2026-08-19

- 增加输入 profile、规范化、checksum words 提取和 canonical 判断接口。
- 增加 `Diagnostic`、`ValidationSummary`、诊断 severity、recommendation、hints、结果对比和可打印报告。
- 增加 `Bech32Policy`、`PolicyCheck` 和 `PolicySummary`，支持按 variant、canonical、HRP、payload 长度、SegWit 网络和 witness program 类型做策略校验。
- 增加文本扫描模块，可从自由文本或多行文本中提取候选串，记录 offset、行号、列号、重复候选、网络过滤和策略 lint 问题。
- 增加 SegWit 网络识别、witness program 分类和网络防误用校验。
- 扩充黑盒与白盒测试，覆盖诊断、批量报告、policy、scan、HRP guard 和 SegWit network guard 场景。
- 同步更新 README、API 文档、技术方案说明和任务报告书。
- 补充正式格式的八月黑客松项目申报书和 Mooncakes 发布准备说明。

## 0.1.0 - 2026-08-09

- 初始化 MoonBit 包元数据与 MIT License。
- 实现 Bech32 / Bech32m 编码、解码和 checksum 校验。
- 实现 bit group 转换、字节编码解码与 SegWit 地址处理。
- 增加单元测试、白盒测试和可运行示例。
- 增加 README、API 文档、申报书、任务报告书和设计说明。
- 配置 GitHub Actions CI，覆盖 check、build、test 和示例运行。

## 后续计划

- 发布至 mooncakes.io 后补充版本发布记录。
- 增加更多公开测试向量和边界测试。
- 根据使用反馈维护 API 与错误类型。
