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

///|
test "input profiling and normalization describe canonical form" {
  let p = profile("A12UEL5L")
  @test.assert_eq(p.input, "A12UEL5L")
  @test.assert_eq(p.normalized, "a12uel5l")
  @test.assert_eq(p.total_length, 8)
  @test.assert_eq(p.separator_index, 1)
  @test.assert_eq(p.hrp_length, 1)
  @test.assert_eq(p.data_part_length, 6)
  @test.assert_eq(p.payload_length, 0)
  @test.assert_eq(p.checksum_length, 6)
  @test.assert_eq(p.case_style, CaseUpper)
  @test.assert_eq(p.has_separator, true)
  @test.assert_eq(p.has_checksum, true)
  @test.assert_eq(normalize("A12UEL5L"), Ok("a12uel5l"))
  @test.assert_eq(is_canonical("A12UEL5L"), false)
  @test.assert_eq(is_canonical("a12uel5l"), true)
  @test.assert_eq(case_style_name(CaseUpper), "upper")
}

///|
test "inspection exposes checksum words and variant metadata" {
  let info = inspect("A12UEL5L").unwrap()
  @test.assert_eq(info.input, "A12UEL5L")
  @test.assert_eq(info.normalized, "a12uel5l")
  @test.assert_eq(info.hrp, "a")
  @test.assert_eq(info.data, [])
  @test.assert_eq(info.checksum, [10, 28, 25, 31, 20, 31])
  @test.assert_eq(info.variant, Bech32)
  @test.assert_eq(info.total_length, 8)
  @test.assert_eq(info.separator_index, 1)
  @test.assert_eq(info.data_part_length, 6)
  @test.assert_eq(info.data_length, 0)
  @test.assert_eq(info.checksum_length, 6)
  @test.assert_eq(info.case_style, CaseUpper)
  @test.assert_eq(info.segwit_valid, false)
  @test.assert_eq(checksum_words_of("A12UEL5L"), Ok([10, 28, 25, 31, 20, 31]))
  @test.assert_eq(variant_name(info.variant), "bech32")
  @test.assert_eq(is_bech32("A12UEL5L"), true)
  @test.assert_eq(is_bech32m("A12UEL5L"), false)
}

///|
test "validation reports preserve batch order and stable error codes" {
  let inputs = ["a12uel5l", "A12uel5l", "a12uel5p"]
  let reports = validate_many(inputs)
  @test.assert_eq(reports.length(), 3)
  @test.assert_eq(reports[0].input, "a12uel5l")
  @test.assert_eq(reports[0].valid, true)
  @test.assert_eq(reports[0].segwit_valid, false)
  @test.assert_eq(reports[0].variant, "bech32")
  @test.assert_eq(reports[0].hrp, "a")
  @test.assert_eq(reports[0].error_code, "")
  @test.assert_eq(reports[1].input, "A12uel5l")
  @test.assert_eq(reports[1].valid, false)
  @test.assert_eq(reports[1].error_code, "mixed_case")
  @test.assert_eq(
    reports[1].error_message,
    "input mixes lowercase and uppercase letters",
  )
  @test.assert_eq(reports[2].input, "a12uel5p")
  @test.assert_eq(reports[2].valid, false)
  @test.assert_eq(reports[2].error_code, "invalid_checksum")
  @test.assert_eq(valid_count(inputs), 1)
  @test.assert_eq(invalid_count(inputs), 2)
  @test.assert_eq(all_valid(inputs), false)
}

///|
test "expected HRP guard rejects addresses for another namespace" {
  @test.assert_eq(decode_with_hrp("a12uel5l", "a").unwrap().hrp, "a")
  @test.assert_eq(
    decode_with_hrp("a12uel5l", "bc"),
    Err(UnexpectedHrp("bc", "a")),
  )
  @test.assert_eq(decode_with_hrp("a12uel5l", " "), Err(InvalidHrpChar(' ', 0)))
  @test.assert_eq(error_code(UnexpectedHrp("bc", "a")), "unexpected_hrp")
  @test.assert_eq(
    error_message(UnexpectedHrp("bc", "a")),
    "decoded HRP does not match the expected HRP",
  )
}

///|
test "SegWit diagnostics classify network and witness program kind" {
  let mainnet = encode_segwit("bc", 0, sample_program20()).unwrap()
  let mainnet_info = inspect_segwit(mainnet).unwrap()
  @test.assert_eq(mainnet_info.normalized, mainnet)
  @test.assert_eq(mainnet_info.hrp, "bc")
  @test.assert_eq(mainnet_info.version, 0)
  @test.assert_eq(mainnet_info.program_length, 20)
  @test.assert_eq(mainnet_info.variant, Bech32)
  @test.assert_eq(mainnet_info.network, NetworkBitcoinMainnet)
  @test.assert_eq(mainnet_info.program_kind, WitnessProgramP2WPKH)

  let testnet = encode_segwit("tb", 1, sample_program32()).unwrap()
  let testnet_info = inspect_segwit(testnet).unwrap()
  @test.assert_eq(testnet_info.hrp, "tb")
  @test.assert_eq(testnet_info.version, 1)
  @test.assert_eq(testnet_info.program_length, 32)
  @test.assert_eq(testnet_info.variant, Bech32m)
  @test.assert_eq(testnet_info.network, NetworkBitcoinTestnet)
  @test.assert_eq(testnet_info.program_kind, WitnessProgramTaproot)

  @test.assert_eq(segwit_network("BC"), NetworkBitcoinMainnet)
  @test.assert_eq(segwit_network("bcrt"), NetworkBitcoinRegtest)
  @test.assert_eq(segwit_network("moon"), NetworkUnknown("moon"))
  @test.assert_eq(network_name(NetworkBitcoinRegtest), "bitcoin_regtest")
  @test.assert_eq(network_name(NetworkUnknown("moon")), "unknown")
  @test.assert_eq(is_standard_segwit_hrp("bcrt"), true)
  @test.assert_eq(is_standard_segwit_hrp("moon"), false)
  @test.assert_eq(witness_program_kind_name(WitnessProgramTaproot), "taproot")
  @test.assert_eq(witness_program_kind(0, 32), WitnessProgramP2WSH)
  @test.assert_eq(witness_program_kind(2, 32), WitnessProgramOther)
}

///|
test "network guard and SegWit batch counters use decoded HRP" {
  let mainnet = encode_segwit("bc", 0, sample_program20()).unwrap()
  let testnet = encode_segwit("tb", 1, sample_program32()).unwrap()
  @test.assert_eq(segwit_network_of(mainnet), Ok(NetworkBitcoinMainnet))
  @test.assert_eq(
    decode_segwit_on_network(mainnet, NetworkBitcoinMainnet).unwrap().hrp,
    "bc",
  )
  @test.assert_eq(
    decode_segwit_on_network(mainnet, NetworkBitcoinTestnet),
    Err(UnexpectedNetwork(NetworkBitcoinTestnet, NetworkBitcoinMainnet)),
  )
  @test.assert_eq(
    error_code(UnexpectedNetwork(NetworkBitcoinTestnet, NetworkBitcoinMainnet)),
    "unexpected_network",
  )
  @test.assert_eq(
    error_message(
      UnexpectedNetwork(NetworkBitcoinTestnet, NetworkBitcoinMainnet),
    ),
    "decoded SegWit network does not match the expected network",
  )
  @test.assert_eq(segwit_valid_count([mainnet, testnet, "a12uel5l"]), 2)
}

///|
test "diagnostics summarize validity canonicality and recommendations" {
  let canonical = diagnose("a12uel5l")
  let uppercase = diagnose("A12UEL5L")
  let mixed = diagnose("A12uel5l")

  @test.assert_eq(canonical.valid, true)
  @test.assert_eq(canonical.canonical, true)
  @test.assert_eq(canonical.severity, DiagnosticOk)
  @test.assert_eq(canonical.recommendation, RecommendNone)
  @test.assert_eq(
    canonical.hints[0],
    "this input is a valid canonical Bech32 string",
  )

  @test.assert_eq(uppercase.valid, true)
  @test.assert_eq(uppercase.canonical, false)
  @test.assert_eq(uppercase.severity, DiagnosticInfo)
  @test.assert_eq(uppercase.recommendation, RecommendNormalizeInput)
  @test.assert_eq(
    recommendation_name(uppercase.recommendation),
    "normalize_input",
  )
  @test.assert_eq(
    recommendation_message(uppercase.recommendation),
    "normalize the input to lower-case canonical form",
  )

  @test.assert_eq(mixed.valid, false)
  @test.assert_eq(mixed.error_code, "mixed_case")
  @test.assert_eq(mixed.severity, DiagnosticError)
  @test.assert_eq(mixed.recommendation, RecommendLowercaseInput)

  let summary = summarize_diagnostics([canonical, uppercase, mixed])
  @test.assert_eq(summary.total, 3)
  @test.assert_eq(summary.valid, 2)
  @test.assert_eq(summary.invalid, 1)
  @test.assert_eq(summary.canonical, 1)
  @test.assert_eq(summary.ok, 1)
  @test.assert_eq(summary.info, 1)
  @test.assert_eq(summary.error, 1)
  @test.assert_eq(summary.case_lower, 1)
  @test.assert_eq(summary.case_upper, 1)
  @test.assert_eq(summary.case_mixed, 1)
  @test.assert_eq(summary.variant_bech32, 2)
  @test.assert_eq(summary.recommend_none, 1)
  @test.assert_eq(summary.recommend_normalize_input, 1)
  @test.assert_eq(summary.recommend_lowercase_input, 1)
  @test.assert_eq(summary.error_mixed_case, 1)
  @test.assert_eq(summary_has_errors(summary), true)
  @test.assert_eq(summary_is_clean(summary), false)
  @test.assert_eq(summary_has_segwit(summary), false)
}

///|
test "diagnostics compare equivalent and different inputs" {
  let same = compare_inputs("a12uel5l", "A12UEL5L")
  @test.assert_eq(same.same_validity, true)
  @test.assert_eq(same.same_variant, true)
  @test.assert_eq(same.same_hrp, true)
  @test.assert_eq(same.same_canonicality, false)
  @test.assert_eq(same.same_case_style, false)
  @test.assert_eq(same.difference_count, 2)
  @test.assert_eq(comparison_hints(same), ["the two inputs behave the same way"])

  let different = compare_inputs("a12uel5l", "a12uel5p")
  @test.assert_eq(different.same_validity, false)
  @test.assert_eq(different.same_variant, false)
  @test.assert_eq(different.same_error_code, false)
  @test.assert_eq(different.difference_count, 5)
}

///|
test "policy checks accept mainnet SegWit and reject wrong forms" {
  let mainnet = encode_segwit("bc", 0, sample_program20()).unwrap()
  let testnet = encode_segwit("tb", 1, sample_program32()).unwrap()
  let mainnet_policy = bitcoin_mainnet_segwit_policy()
  let accepted = check_with_policy(mainnet, mainnet_policy)
  @test.assert_eq(accepted.accepted, true)
  @test.assert_eq(accepted.policy_name, "bitcoin_mainnet_segwit")
  @test.assert_eq(accepted.valid, true)
  @test.assert_eq(accepted.segwit_valid, true)
  @test.assert_eq(accepted.canonical, true)
  @test.assert_eq(accepted.variant, "bech32")
  @test.assert_eq(accepted.hrp, "bc")
  @test.assert_eq(accepted.network, "bitcoin_mainnet")
  @test.assert_eq(accepted.program_kind, "p2wpkh")
  @test.assert_eq(accepted.payload_words, 33)
  @test.assert_eq(accepted.failure, PolicyFailureNone)

  let wrong_hrp = check_with_policy(testnet, mainnet_policy)
  @test.assert_eq(wrong_hrp.accepted, false)
  @test.assert_eq(wrong_hrp.failure, PolicyFailureHrpNotAllowed("tb"))
  @test.assert_eq(wrong_hrp.failure_code, "hrp_not_allowed")
  @test.assert_eq(
    wrong_hrp.failure_message,
    "human-readable part is not allowed: tb",
  )

  let uppercase = check_with_policy(
    "A12UEL5L",
    policy_with_hrps(canonical_bech32_policy(), ["a"]),
  )
  @test.assert_eq(uppercase.accepted, false)
  @test.assert_eq(uppercase.failure, PolicyFailureNotCanonical)
  @test.assert_eq(
    uppercase.recommendation,
    "normalize the input before applying the policy",
  )
}

///|
test "policy helpers summarize accepted and rejected inputs" {
  let mainnet = encode_segwit("bc", 0, sample_program20()).unwrap()
  let taproot = encode_segwit("bc", 1, sample_program32()).unwrap()
  let invalid = "a12uel5p"
  let policy = taproot_mainnet_policy()
  let checks = check_many_with_policy([mainnet, taproot, invalid], policy)
  @test.assert_eq(checks.length(), 3)
  @test.assert_eq(checks[0].accepted, false)
  @test.assert_eq(checks[0].failure, PolicyFailureVariantNotAllowed("bech32"))
  @test.assert_eq(checks[1].accepted, true)
  @test.assert_eq(checks[1].program_kind, "taproot")
  @test.assert_eq(checks[2].accepted, false)
  @test.assert_eq(
    checks[2].failure,
    PolicyFailureInvalidBech32("invalid_checksum"),
  )

  let summary = summarize_policy_checks(checks)
  @test.assert_eq(summary.policy_name, "taproot_mainnet")
  @test.assert_eq(summary.total, 3)
  @test.assert_eq(summary.accepted, 1)
  @test.assert_eq(summary.rejected, 2)
  @test.assert_eq(summary.rejected_invalid, 1)
  @test.assert_eq(summary.rejected_variant, 1)
  @test.assert_eq(policy_accepts(taproot, policy), true)
  @test.assert_eq(policy_rejects(mainnet, policy), true)
  @test.assert_eq(accepted_inputs([mainnet, taproot, invalid], policy), [
    taproot,
  ])
  @test.assert_eq(rejected_inputs([mainnet, taproot, invalid], policy), [
    mainnet, invalid,
  ])
  @test.assert_eq(
    first_policy_failure([taproot, mainnet], policy).unwrap().input,
    mainnet,
  )
}

///|
test "scan text extracts valid addresses and records rejected candidates" {
  let mainnet = encode_segwit("bc", 0, sample_program20()).unwrap()
  let report = scan_text("first " + mainnet + " second a12uel5p.")
  @test.assert_eq(report.total_candidates, 2)
  @test.assert_eq(report.accepted, 1)
  @test.assert_eq(report.rejected, 1)
  @test.assert_eq(report.valid, 1)
  @test.assert_eq(report.invalid, 0)
  @test.assert_eq(report.segwit_valid, 1)
  @test.assert_eq(report.canonical, 1)
  @test.assert_eq(scan_report_is_empty(report), false)
  @test.assert_eq(scan_report_has_valid(report), true)
  @test.assert_eq(scan_report_has_invalid(report), false)
  @test.assert_eq(scan_report_has_segwit(report), true)
  @test.assert_eq(scan_report_is_clean(report), true)
  @test.assert_eq(scan_report_all_canonical(report), true)
  @test.assert_eq(scan_finding_texts(report.findings), [mainnet])
  @test.assert_eq(scan_finding_hrps(report.findings), ["bc"])
  @test.assert_eq(scan_finding_networks(report.findings), ["bitcoin_mainnet"])
  @test.assert_eq(first_valid_scan_finding(report).unwrap().span.text, mainnet)
  @test.assert_eq(first_segwit_scan_finding(report).unwrap().span.text, mainnet)
}

///|
test "scan options include invalid values deduplicate and lint findings" {
  let base = default_scan_options()
  let include_invalid = scan_options_include_invalid(base, true)
  let report = scan_text_with_options("x a12uel5l y a12uel5p", include_invalid)
  @test.assert_eq(report.total_candidates, 2)
  @test.assert_eq(report.accepted, 2)
  @test.assert_eq(report.valid, 1)
  @test.assert_eq(report.invalid, 1)
  @test.assert_eq(invalid_scan_findings(report.findings).length(), 1)
  let issues = lint_scan_report(report, include_invalid)
  @test.assert_eq(scan_issue_count(issues), 1)
  @test.assert_eq(scan_issue_error_count(issues), 1)
  @test.assert_eq(scan_issue_warning_count(issues), 0)
  @test.assert_eq(scan_issues_are_clean(issues), false)
  @test.assert_eq(scan_issue_kind_name(issues[0].kind), "invalid_candidate")

  let dedup = scan_options_deduplicate(default_scan_options(), true)
  let duplicate_report = scan_text_with_options("a12uel5l A12UEL5L", dedup)
  @test.assert_eq(duplicate_report.total_candidates, 2)
  @test.assert_eq(duplicate_report.accepted, 1)
  @test.assert_eq(duplicate_report.rejected, 1)
  @test.assert_eq(duplicate_report.duplicate, 1)
  @test.assert_eq(
    non_canonical_scan_findings(duplicate_report.findings).length(),
    0,
  )
}
