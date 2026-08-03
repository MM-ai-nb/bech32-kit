# bech32-kit 项目申报书

## 基本信息

- 项目名称：bech32-kit：纯 MoonBit Bech32/Bech32m 编码解码与 SegWit 地址校验库
- 参赛者：卓娟
- 联系方式：13855703757，609588498@qq.com
- GitHub 仓库链接：<待填写>
- 项目方向：MoonBit 原生编码解码基础库 / WebAssembly 可复用组件
- 是否为移植项目：否，原创 MoonBit 开源项目
- 开源许可证：MIT

## 项目简介

bech32-kit 提供纯 MoonBit 的 Bech32/Bech32m 编码、解码、checksum 校验、bit group 转换和 SegWit 地址验证能力。项目解决 MoonBit 生态中缺少该类基础编码库的问题，让钱包工具、链上数据处理、WebAssembly 应用和命令行工具可以直接复用可靠的地址与校验字符串处理逻辑。

## 项目方向与适用场景

项目适合 MoonBit 库作者、区块链工具开发者、WebAssembly 应用开发者和 CLI 工具开发者。典型场景包括 SegWit 地址校验、Bech32m 编码字段生成、紧凑校验字符串解析、协议测试 fixture 生成和教学项目中的编码算法演示。

## 拟实现的核心功能

- Bech32 与 Bech32m 编码、解码和 checksum 验证；
- 结构化错误类型，区分大小写、非法字符、padding、checksum 与 SegWit 规则错误；
- 8-bit 字节与 5-bit Bech32 数据的可逆转换；
- SegWit v0 到 v16 地址编码与验证，自动匹配 Bech32/Bech32m；
- 提供测试、示例、README、API 文档、CI 和 Mooncakes 发布配置。

## 项目现有基础与本次计划

当前已完成 MoonBit 工程、核心源码、可运行示例、单元测试、README、API 文档、MIT 许可证和 GitHub Actions CI。后续计划是创建公开 GitHub 仓库，替换真实仓库地址与 Mooncakes owner，执行 `moon publish --dry-run`，通过后正式发布到 mooncakes.io。

## 原创或参考说明

本项目为原创 MoonBit 实现，不移植第三方源码，不包含来源不明素材或私有代码。算法依据公开标准 BIP-0173 与 BIP-0350 的描述实现，并使用公开测试向量进行验证。
