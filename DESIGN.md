# bech32-kit 技术方案与功能边界

## 设计目标

bech32-kit 的核心目标是提供一个纯 MoonBit、低依赖、易测试的 Bech32 / Bech32m 基础库。项目优先保证标准兼容性、错误可诊断性、批量处理能力和 API 的可复用性。

## 核心模块

- 编码与解码：负责 HRP、数据段、分隔符、字符集和 checksum 的处理；
- checksum：实现 Bech32 polymod 计算，并区分 Bech32 与 Bech32m 常量；
- bit 转换：提供 8-bit 字节与 5-bit 数据组之间的转换能力；
- SegWit 地址：基于 BIP-0173 和 BIP-0350 规则处理 witness version、program 长度和编码变体；
- 诊断与报告：提供输入画像、规范化、checksum words 提取、批量校验报告、severity、recommendation 和稳定错误码；
- 策略校验：面向导入、风控和钱包环境切换场景，按 variant、canonical、HRP、payload 长度、SegWit 网络和 witness program 类型进行接受/拒绝判断；
- 文本扫描：从日志、剪贴板、表单备注或多行文本中提取候选串，保留 offset、行号、列号、重复候选和策略 lint 信息；
- SegWit 辅助信息：识别 mainnet、testnet、regtest 与未知 HRP，并分类 P2WPKH、P2WSH、Taproot 等常见 witness program；
- 错误类型：用结构化错误区分非法字符、大小写混用、checksum 失败、padding 失败、HRP 不匹配、网络不匹配和 SegWit 规则失败。

## 分层说明

核心编码层只关心 Bech32 / Bech32m 的标准行为，返回 `Result` 和结构化错误。诊断层把核心错误转为稳定错误码、展示文案、建议动作和批量统计。策略层不重新实现 checksum，而是复用诊断结果，解决“这个有效地址是否适合当前业务环境”的问题。扫描层不访问文件系统或网络，只对调用者传入的字符串做候选提取，再复用诊断层和策略 lint。

这样的分层可以保持核心算法小而可靠，同时让项目具有更强的真实使用价值：CLI 可以直接打印诊断，钱包导入可以配置策略，WebAssembly 表单可以扫描整段文本并指出候选地址风险。

## 功能边界

项目只处理编码、解码、校验、诊断、策略判断和传入文本扫描，不包含以下能力：

- 私钥、助记词或钱包账户管理；
- 网络请求、链上查询或交易广播；
- 交易签名、脚本执行或共识规则验证；
- 自动纠错或错误位置推荐；
- 本地文件系统爬取或目录扫描；
- 超出 Bech32 标准范围的 Unicode HRP 扩展。

## 测试策略

测试分为基础单元测试和白盒测试：

- 正确编码、解码和 round-trip；
- Bech32 与 Bech32m checksum 差异；
- 大小写混用、非法字符和 checksum 错误；
- canonical padding 与非法 bit 值；
- SegWit v0、v1 和无效 witness program 长度；
- 输入 profile、规范化、checksum words 与 canonical 判断；
- 批量 validation report、有效数量统计和稳定错误码；
- 诊断 severity、recommendation、summary 与渲染入口；
- 高层 policy 的接受、拒绝、失败码和批量统计；
- 文本扫描的候选提取、行列位置、网络过滤、无效候选包含和重复候选识别；
- SegWit 网络识别、witness program 分类与网络防误用校验；
- 可运行示例的实际输出验证。

## CI 策略

CI 在 push 和 pull request 时执行：

```bash
moon check
moon build
moon test
moon run cmd/main
```

这保证项目至少在语法检查、构建、测试和示例运行四个层面保持可验收状态。本地收尾时还执行 `moon check --deny-warn` 和 `moon test --deny-warn`，用于提前发现未使用定义、缺少私有标记、格式或类型层面的潜在问题。

## 维护策略

- 保持核心库无额外运行时依赖；
- 通过语义化版本和 CHANGELOG 记录行为变化；
- 新增 API 时优先补充测试和 README / API 文档；
- 发布前执行 `moon publish --dry-run`；
- 正式发布后在报告和更新日志中记录 mooncakes.io 版本。
