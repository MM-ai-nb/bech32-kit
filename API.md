# API 说明

## 数据类型

`Variant` 表示 checksum 变体：

- `Bech32`
- `Bech32m`

`Decoded` 是普通 Bech32/Bech32m 解码结果：

- `hrp : String`
- `data : Array[Int]`
- `variant : Variant`

`SegwitAddress` 是 SegWit 地址解码结果：

- `hrp : String`
- `version : Int`
- `program : Array[Int]`
- `variant : Variant`

`Bech32Error` 覆盖空输入、长度超限、分隔符缺失、HRP 错误、数据字符错误、checksum 错误、bit group 错误、padding 错误与 SegWit 规则错误。

## 编码与解码

```moonbit
encode(hrp, data)
encode_m(hrp, data)
encode_with_variant(hrp, data, variant)
decode(input)
```

`data` 是 5-bit 数组，每个值必须在 `0..31`。编码输出统一为小写字符串；解码接受全大写或全小写输入，并返回小写 HRP。

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
```

`encode_segwit` 会根据版本自动选择 checksum：version `0` 使用 Bech32，version `1..16` 使用 Bech32m。`decode_segwit` 会验证 witness version、program 长度与 checksum 变体是否匹配。
