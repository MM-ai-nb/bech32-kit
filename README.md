# bech32-kit

bech32-kit 是一个纯 MoonBit 实现的 Bech32/Bech32m 编码、解码、校验和 SegWit 地址验证库。它面向需要在 MoonBit 或 WebAssembly 场景中处理紧凑校验字符串、钱包地址、链上工具、配置短码和协议字段的开发者。

## 解决的问题

Bech32 与 Bech32m 常用于低误读率的人类可读编码。项目提供可复用的 MoonBit 原生实现，避免在 MoonBit 项目中临时复制 checksum 逻辑，或依赖外部运行时绑定。库会返回结构化错误，便于上层工具把 checksum 错误、大小写错误、非法字符、bit 转换错误和 SegWit 规则错误区分处理。

## 安装方式

```bash
moon add moonbit-user/bech32-kit
```

参赛发布时请将 `moonbit-user` 替换为参赛者自己的 Mooncakes owner，并同步更新 `moon.mod` 中的 `name`、`repository` 与 README 包名。

## 最小使用示例

```moonbit
let encoded = @bech32.encode("moon", [0, 1, 2, 3, 4]).unwrap()
let decoded = @bech32.decode(encoded).unwrap()
println(decoded.hrp)
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

- `encode` / `decode`：Bech32 编码、解码与 checksum 验证。
- `encode_m` / `encode_with_variant`：Bech32m 或显式变体编码。
- `convert_bits`：通用 bit group 转换，支持 canonical padding 校验。
- `encode_bytes` / `decode_bytes`：字节数组与 Bech32 数据互转。
- `encode_segwit` / `decode_segwit`：BIP-0173 与 BIP-0350 SegWit 地址编码和验证。
- `is_valid` / `is_valid_segwit`：快速布尔校验接口。
- `Bech32Error`：结构化错误枚举，覆盖主要失败路径。

## 支持范围

- Bech32 checksum 常量 `1`。
- Bech32m checksum 常量 `0x2bc830a3`。
- 人类可读前缀 HRP ASCII 范围校验。
- 整串大小写一致性校验与小写规范化输出。
- 5-bit 数据值范围校验。
- SegWit witness version `0..16`。
- SegWit v0 程序长度 `20` 或 `32` 字节。
- SegWit v1 到 v16 使用 Bech32m 的规则校验。

## 暂不支持范围

- 自动纠错或错误位置建议。
- 文件系统扫描、网络请求或钱包私钥处理。
- Unicode HRP；Bech32 标准 HRP 使用可打印 ASCII。
- 超出 90 字符限制的非标准扩展编码。

## 本地运行与验收

```bash
moon check
moon build
moon test
moon run cmd/main
moon publish --dry-run
```

测试覆盖正常向量、错误输入、边界条件、bit 转换、字节导出、SegWit v0/v1 编解码与主要错误路径。

## Mooncakes 包名

```text
moonbit-user/bech32-kit
```

## 开源许可证与参考说明

项目采用 MIT 许可证。实现参考公开标准 BIP-0173（Bech32）与 BIP-0350（Bech32m）的算法描述和测试向量，未移植第三方源码，不包含外部素材或私有代码。
