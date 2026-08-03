///|
fn sample_program20() -> Array[Int] {
  [
    0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54, 0x94, 0x1c, 0x45, 0xd1,
    0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6,
  ]
}

///|
fn sample_program32() -> Array[Int] {
  [
    0x51, 0x20, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54, 0x94, 0x1c,
    0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6, 0x51, 0x20, 0x75, 0x1e,
    0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4,
  ]
}

///|
test "BIP-0173 generic checksum vectors decode as Bech32" {
  let vectors = [
    "A12UEL5L", "a12uel5l", "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw", "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
    "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w", "?1ezyfcl",
  ]
  for vector in vectors {
    let decoded = decode(vector).unwrap()
    @test.assert_eq(decoded.variant, Bech32)
    @test.assert_eq(is_valid(vector), true)
  }
  let a = decode("A12UEL5L").unwrap()
  @test.assert_eq(a.hrp, "a")
  @test.assert_eq(a.data, [])
}

///|
test "Bech32 and Bech32m encoders reproduce empty-payload vectors" {
  @test.assert_eq(encode("a", []).unwrap(), "a12uel5l")
  @test.assert_eq(encode("A", []).unwrap(), "a12uel5l")
  @test.assert_eq(encode_m("a", []).unwrap(), "a1lqfn3a")
  @test.assert_eq(decode("A1LQFN3A").unwrap().variant, Bech32m)
}

///|
test "decoding rejects malformed strings with precise errors" {
  @test.assert_eq(decode(""), Err(EmptyInput))
  @test.assert_eq(decode("pzry9x0s0muk"), Err(MissingSeparator))
  @test.assert_eq(decode("1pzry9x0s0muk"), Err(EmptyHrp))
  @test.assert_eq(decode("A12uel5l"), Err(MixedCase))
  @test.assert_eq(decode("x1b4n0q5v"), Err(InvalidDataChar('b', 2)))
  @test.assert_eq(decode("a12uel5p"), Err(InvalidChecksum))
  @test.assert_eq(encode(" ", []), Err(InvalidHrpChar(' ', 0)))
  @test.assert_eq(encode("a", [32]), Err(InvalidDataValue(32, 0)))
}

///|
test "convert_bits matches the public key hash example and rejects bad padding" {
  let words = [
    14, 20, 15, 7, 13, 26, 0, 25, 18, 6, 11, 13, 8, 21, 4, 20, 3, 17, 2, 29, 3, 12,
    29, 3, 4, 15, 24, 20, 6, 14, 30, 22,
  ]
  @test.assert_eq(convert_bits(sample_program20(), 8, 5, true), Ok(words))
  @test.assert_eq(convert_bits(words, 5, 8, false), Ok(sample_program20()))
  @test.assert_eq(convert_bits([1], 5, 8, false), Err(InvalidPadding))
  @test.assert_eq(convert_bits([32], 5, 8, true), Err(InvalidDataValue(32, 0)))
  @test.assert_eq(convert_bits([1], 0, 8, true), Err(InvalidBitGroup(0, 8)))
}

///|
test "byte helpers round trip arbitrary octets" {
  let payload = [0, 1, 2, 3, 252, 253, 254, 255]
  let encoded = encode_bytes("blob", payload, Bech32m).unwrap()
  let (hrp, decoded, variant) = decode_bytes(encoded).unwrap()
  @test.assert_eq(hrp, "blob")
  @test.assert_eq(decoded, payload)
  @test.assert_eq(variant, Bech32m)
}

///|
test "SegWit v0 uses Bech32 and validates program length" {
  let addr = encode_segwit("bc", 0, sample_program20()).unwrap()
  @test.assert_eq(addr, "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4")
  let decoded = decode_segwit(addr).unwrap()
  @test.assert_eq(decoded.hrp, "bc")
  @test.assert_eq(decoded.version, 0)
  @test.assert_eq(decoded.program, sample_program20())
  @test.assert_eq(decoded.variant, Bech32)
  @test.assert_eq(
    encode_segwit("bc", 0, [1, 2]),
    Err(InvalidWitnessProgramLength(0, 2)),
  )
}

///|
test "SegWit v1 and later use Bech32m" {
  let addr = encode_segwit("bc", 1, sample_program32()).unwrap()
  @test.assert_eq(
    addr, "bc1p2ys828nkaqver9k52j2pc3w3kw3j8u2r80t9zgr4remwsxv3jm2q5mhnte",
  )
  let decoded = decode_segwit(addr).unwrap()
  @test.assert_eq(decoded.version, 1)
  @test.assert_eq(decoded.program, sample_program32())
  @test.assert_eq(decoded.variant, Bech32m)

  let data = [1] + convert_bits(sample_program32(), 8, 5, true).unwrap()
  let wrong = encode_with_variant("bc", data, Bech32).unwrap()
  @test.assert_eq(
    decode_segwit(wrong),
    Err(InvalidWitnessEncoding(Bech32m, Bech32)),
  )
}
