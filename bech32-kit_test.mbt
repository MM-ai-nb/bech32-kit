///|
test "public API smoke test" {
  let encoded = encode("moon", [0, 1, 2, 3, 4]).unwrap()
  let decoded = decode(encoded).unwrap()
  @test.assert_eq(decoded.hrp, "moon")
  @test.assert_eq(decoded.data, [0, 1, 2, 3, 4])
  @test.assert_eq(decoded.variant, Bech32)
}
