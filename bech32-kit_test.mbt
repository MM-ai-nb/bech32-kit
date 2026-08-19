///|
test "public API smoke test" {
  let encoded = encode("moon", [0, 1, 2, 3, 4]).unwrap()
  let decoded = decode(encoded).unwrap()
  @test.assert_eq(decoded.hrp, "moon")
  @test.assert_eq(decoded.data, [0, 1, 2, 3, 4])
  @test.assert_eq(decoded.variant, Bech32)
  @test.assert_eq(is_bech32(encoded), true)
  @test.assert_eq(hrp_of(encoded), Ok("moon"))
  @test.assert_eq(data_words_of(encoded), Ok([0, 1, 2, 3, 4]))
}

///|
fn bb_program20() -> Array[Int] {
  [
    0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54, 0x94, 0x1c, 0x45, 0xd1,
    0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6,
  ]
}

///|
fn bb_program32() -> Array[Int] {
  [
    0x51, 0x20, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54, 0x94, 0x1c,
    0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6, 0x51, 0x20, 0x75, 0x1e,
    0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4,
  ]
}

///|
test "diagnostics summarize valid invalid and canonical states" {
  let upper = diagnose("A12UEL5L")
  @test.assert_eq(upper.valid, true)
  @test.assert_eq(upper.segwit_valid, false)
  @test.assert_eq(upper.canonical, false)
  @test.assert_eq(upper.severity, DiagnosticInfo)
  @test.assert_eq(upper.recommendation, RecommendNormalizeInput)
  @test.assert_eq(upper.variant, "bech32")
  @test.assert_eq(upper.hrp, "a")
  @test.assert_eq(upper.error_code, "")

  let bad = diagnose("a12uel5p")
  @test.assert_eq(bad.valid, false)
  @test.assert_eq(bad.canonical, false)
  @test.assert_eq(bad.severity, DiagnosticError)
  @test.assert_eq(bad.recommendation, RecommendCheckChecksum)
  @test.assert_eq(bad.error_code, "invalid_checksum")

  let summary = summarize_diagnostics([upper, bad])
  @test.assert_eq(summary.total, 2)
  @test.assert_eq(summary.valid, 1)
  @test.assert_eq(summary.invalid, 1)
  @test.assert_eq(summary.info, 1)
  @test.assert_eq(summary.error, 1)
  @test.assert_eq(summary.variant_bech32, 1)
  @test.assert_eq(summary.recommend_normalize_input, 1)
  @test.assert_eq(summary.recommend_check_checksum, 1)
  @test.assert_eq(summary.error_invalid_checksum, 1)
  @test.assert_eq(summary_has_errors(summary), true)
  @test.assert_eq(summary_is_clean(summary), false)
}

///|
test "policy helpers accept mainnet SegWit and reject wrong namespaces" {
  let mainnet = encode_segwit("bc", 0, bb_program20()).unwrap()
  let testnet = encode_segwit("tb", 0, bb_program20()).unwrap()
  let taproot = encode_segwit("bc", 1, bb_program32()).unwrap()
  let mainnet_policy = bitcoin_mainnet_segwit_policy()
  let taproot_policy = taproot_mainnet_policy()

  let accepted = check_with_policy(mainnet, mainnet_policy)
  @test.assert_eq(accepted.accepted, true)
  @test.assert_eq(accepted.valid, true)
  @test.assert_eq(accepted.segwit_valid, true)
  @test.assert_eq(accepted.hrp, "bc")
  @test.assert_eq(accepted.network, "bitcoin_mainnet")
  @test.assert_eq(accepted.program_kind, "p2wpkh")
  @test.assert_eq(accepted.failure, PolicyFailureNone)

  let wrong_network = check_with_policy(testnet, mainnet_policy)
  @test.assert_eq(wrong_network.accepted, false)
  @test.assert_eq(wrong_network.failure, PolicyFailureHrpNotAllowed("tb"))
  @test.assert_eq(wrong_network.failure_code, "hrp_not_allowed")

  let wrong_kind = check_with_policy(mainnet, taproot_policy)
  @test.assert_eq(wrong_kind.accepted, false)
  @test.assert_eq(wrong_kind.failure, PolicyFailureVariantNotAllowed("bech32"))

  let taproot_ok = check_with_policy(taproot, taproot_policy)
  @test.assert_eq(taproot_ok.accepted, true)
  @test.assert_eq(taproot_ok.program_kind, "taproot")
}

///|
test "policy summaries expose stable rejection counters" {
  let mainnet = encode_segwit("bc", 0, bb_program20()).unwrap()
  let testnet = encode_segwit("tb", 0, bb_program20()).unwrap()
  let generic = encode("moon", [0, 1, 2]).unwrap()
  let policy = bitcoin_mainnet_segwit_policy()
  let checks = check_many_with_policy(
    [mainnet, testnet, generic, "a12uel5p"],
    policy,
  )
  let summary = summarize_policy_checks(checks)
  @test.assert_eq(summary.policy_name, "bitcoin_mainnet_segwit")
  @test.assert_eq(summary.total, 4)
  @test.assert_eq(summary.accepted, 1)
  @test.assert_eq(summary.rejected, 3)
  @test.assert_eq(summary.rejected_invalid, 1)
  @test.assert_eq(summary.rejected_hrp, 2)
  @test.assert_eq(policy_accepts(mainnet, policy), true)
  @test.assert_eq(policy_rejects(generic, policy), true)
  @test.assert_eq(accepted_inputs([mainnet, testnet], policy), [mainnet])
  @test.assert_eq(rejected_inputs([mainnet, testnet], policy), [testnet])
}

///|
test "text scanner extracts generic and SegWit candidates" {
  let segwit = encode_segwit("bc", 0, bb_program20()).unwrap()
  let generic = encode("moon", [0, 1, 2, 3]).unwrap()
  let text = "pay " + segwit + " then archive " + generic + "."
  let report = scan_text(text)
  @test.assert_eq(report.total_candidates, 2)
  @test.assert_eq(report.accepted, 2)
  @test.assert_eq(report.rejected, 0)
  @test.assert_eq(report.valid, 2)
  @test.assert_eq(report.segwit_valid, 1)
  @test.assert_eq(scan_report_has_valid(report), true)
  @test.assert_eq(scan_report_has_segwit(report), true)
  @test.assert_eq(scan_finding_texts(report.findings), [segwit, generic])
  @test.assert_eq(scan_finding_hrps(report.findings), ["bc", "moon"])
  @test.assert_eq(first_valid_scan_finding(report).unwrap().span.text, segwit)
  @test.assert_eq(first_segwit_scan_finding(report).unwrap().span.text, segwit)
}

///|
test "SegWit scanner options filter by expected network" {
  let mainnet = encode_segwit("bc", 0, bb_program20()).unwrap()
  let testnet = encode_segwit("tb", 0, bb_program20()).unwrap()
  let options = scan_options_expected_network(
    segwit_scan_options(),
    "bitcoin_mainnet",
  )
  let report = scan_text_with_options(
    "ok " + mainnet + " no " + testnet,
    options,
  )
  @test.assert_eq(report.total_candidates, 2)
  @test.assert_eq(report.accepted, 1)
  @test.assert_eq(report.rejected, 1)
  @test.assert_eq(report.segwit_valid, 1)
  @test.assert_eq(report.findings[0].span.text, mainnet)
  @test.assert_eq(report.findings[0].diagnostic.network, "bitcoin_mainnet")
}

///|
test "scanner can include invalid candidates for diagnostics" {
  let options = scan_options_include_invalid(default_scan_options(), true)
  let report = scan_text_with_options("broken a12uel5p ok a12uel5l", options)
  @test.assert_eq(report.total_candidates, 2)
  @test.assert_eq(report.accepted, 2)
  @test.assert_eq(report.valid, 1)
  @test.assert_eq(report.invalid, 1)
  @test.assert_eq(invalid_scan_findings(report.findings).length(), 1)
  @test.assert_eq(valid_scan_findings(report.findings).length(), 1)
  @test.assert_eq(report.findings[0].diagnostic.error_code, "invalid_checksum")
}

///|
test "line scanner records line positions and duplicate findings" {
  let encoded = encode("moon", [0, 1, 2, 3]).unwrap()
  let report = scan_lines_with_options(
    ["first " + encoded, "again " + encoded],
    default_scan_options(),
  )
  @test.assert_eq(report.total_candidates, 2)
  @test.assert_eq(report.accepted, 2)
  @test.assert_eq(report.duplicate, 1)
  @test.assert_eq(report.findings[0].span.line_number, 1)
  @test.assert_eq(report.findings[0].span.column_number, 7)
  @test.assert_eq(report.findings[1].span.line_number, 2)
  @test.assert_eq(report.findings[1].duplicate_of, 0)
  let issues = lint_scan_report(report, default_scan_options())
  @test.assert_eq(scan_issue_count(issues), 1)
  @test.assert_eq(scan_issue_info_count(issues), 1)
  @test.assert_eq(issues[0].kind, ScanIssueDuplicate)
}

///|
test "scanner lint reports policy violations on accepted diagnostic candidates" {
  let encoded = encode("moon", [0, 1, 2, 3]).unwrap()
  let options = scan_options_require_canonical(
    scan_options_expected_hrp(
      scan_options_include_invalid(default_scan_options(), true),
      "bc",
    ),
    true,
  )
  let report = scan_text_with_options("candidate " + encoded, options)
  @test.assert_eq(report.accepted, 0)

  let relaxed = scan_options_expected_hrp(
    scan_options_include_invalid(default_scan_options(), true),
    "bc",
  )
  let visible = scan_text_with_options("candidate " + encoded, relaxed)
  @test.assert_eq(visible.accepted, 0)

  let included = scan_text_with_options(
    "candidate " + encoded,
    scan_options_include_invalid(default_scan_options(), true),
  )
  let issues = lint_scan_report(included, relaxed)
  @test.assert_eq(scan_issue_warning_count(issues), 1)
  @test.assert_eq(issues[0].kind, ScanIssueUnexpectedHrp)
}
