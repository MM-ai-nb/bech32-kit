///|
/// Severity for diagnostic output.
pub(all) enum DiagnosticSeverity {
  DiagnosticOk
  DiagnosticInfo
  DiagnosticWarning
  DiagnosticError
} derive(Eq, Debug)

///|
/// Recommended next step for a failed or non-canonical input.
pub(all) enum DiagnosticRecommendation {
  RecommendNone
  RecommendNormalizeInput
  RecommendLowercaseInput
  RecommendCheckSeparator
  RecommendCheckHrp
  RecommendCheckCharset
  RecommendCheckChecksum
  RecommendCheckPadding
  RecommendCheckWitnessVersion
  RecommendCheckWitnessProgramLength
  RecommendUseBech32
  RecommendUseBech32m
  RecommendCheckNetwork
  RecommendCheckByteConversion
} derive(Eq, Debug)

///|
/// Diagnostic result for one input string.
pub(all) struct Diagnostic {
  input : String
  normalized : String
  valid : Bool
  segwit_valid : Bool
  canonical : Bool
  severity : DiagnosticSeverity
  recommendation : DiagnosticRecommendation
  case_style : CaseStyle
  variant : String
  hrp : String
  network : String
  program_kind : String
  error_code : String
  error_message : String
  hints : Array[String]
} derive(Eq, Debug)

///|
/// Aggregated diagnostic counts over a batch of inputs.
pub(all) struct ValidationSummary {
  total : Int
  valid : Int
  invalid : Int
  segwit_valid : Int
  canonical : Int
  ok : Int
  info : Int
  warning : Int
  error : Int
  case_no_letters : Int
  case_lower : Int
  case_upper : Int
  case_mixed : Int
  variant_bech32 : Int
  variant_bech32m : Int
  network_mainnet : Int
  network_testnet : Int
  network_regtest : Int
  network_unknown : Int
  program_p2wpkh : Int
  program_p2wsh : Int
  program_taproot : Int
  program_other : Int
  recommend_none : Int
  recommend_normalize_input : Int
  recommend_lowercase_input : Int
  recommend_check_separator : Int
  recommend_check_hrp : Int
  recommend_check_charset : Int
  recommend_check_checksum : Int
  recommend_check_padding : Int
  recommend_check_witness_version : Int
  recommend_check_witness_program_length : Int
  recommend_use_bech32 : Int
  recommend_use_bech32m : Int
  recommend_check_network : Int
  recommend_check_byte_conversion : Int
  error_empty_input : Int
  error_too_long : Int
  error_missing_separator : Int
  error_empty_hrp : Int
  error_empty_data : Int
  error_mixed_case : Int
  error_invalid_hrp_char : Int
  error_invalid_data_char : Int
  error_invalid_data_value : Int
  error_invalid_checksum : Int
  error_invalid_bit_group : Int
  error_invalid_padding : Int
  error_invalid_witness_version : Int
  error_invalid_witness_program_length : Int
  error_invalid_witness_encoding : Int
  error_unexpected_hrp : Int
  error_unexpected_network : Int
} derive(Eq, Debug)

///|
/// Comparison between two diagnostics.
pub(all) struct ComparisonReport {
  left_input : String
  right_input : String
  left_valid : Bool
  right_valid : Bool
  left_segwit_valid : Bool
  right_segwit_valid : Bool
  left_canonical : Bool
  right_canonical : Bool
  left_variant : String
  right_variant : String
  left_case_style : CaseStyle
  right_case_style : CaseStyle
  left_hrp : String
  right_hrp : String
  left_network : String
  right_network : String
  left_program_kind : String
  right_program_kind : String
  left_error_code : String
  right_error_code : String
  same_validity : Bool
  same_segwit_validity : Bool
  same_canonicality : Bool
  same_variant : Bool
  same_case_style : Bool
  same_hrp : Bool
  same_network : Bool
  same_program_kind : Bool
  same_error_code : Bool
  same_length : Bool
  difference_count : Int
} derive(Eq, Debug)

///|
pub fn severity_name(severity : DiagnosticSeverity) -> String {
  match severity {
    DiagnosticOk => "ok"
    DiagnosticInfo => "info"
    DiagnosticWarning => "warning"
    DiagnosticError => "error"
  }
}

///|
pub fn recommendation_name(recommendation : DiagnosticRecommendation) -> String {
  match recommendation {
    RecommendNone => "none"
    RecommendNormalizeInput => "normalize_input"
    RecommendLowercaseInput => "lowercase_input"
    RecommendCheckSeparator => "check_separator"
    RecommendCheckHrp => "check_hrp"
    RecommendCheckCharset => "check_charset"
    RecommendCheckChecksum => "check_checksum"
    RecommendCheckPadding => "check_padding"
    RecommendCheckWitnessVersion => "check_witness_version"
    RecommendCheckWitnessProgramLength => "check_witness_program_length"
    RecommendUseBech32 => "use_bech32"
    RecommendUseBech32m => "use_bech32m"
    RecommendCheckNetwork => "check_network"
    RecommendCheckByteConversion => "check_byte_conversion"
  }
}

///|
pub fn recommendation_message(
  recommendation : DiagnosticRecommendation,
) -> String {
  match recommendation {
    RecommendNone => "input is already in a good shape"
    RecommendNormalizeInput =>
      "normalize the input to lower-case canonical form"
    RecommendLowercaseInput =>
      "convert the input to lower-case before re-encoding"
    RecommendCheckSeparator => "add or move the separator '1'"
    RecommendCheckHrp => "verify the human-readable part"
    RecommendCheckCharset => "check the Bech32 data charset"
    RecommendCheckChecksum => "recompute the checksum"
    RecommendCheckPadding => "fix the bit conversion padding"
    RecommendCheckWitnessVersion => "use a witness version between 0 and 16"
    RecommendCheckWitnessProgramLength => "fix the witness program length"
    RecommendUseBech32 => "version 0 witness programs must use Bech32"
    RecommendUseBech32m => "version 1+ witness programs must use Bech32m"
    RecommendCheckNetwork =>
      "check whether the address belongs to the expected network"
    RecommendCheckByteConversion =>
      "check byte-to-word conversion and payload width"
  }
}

///|
pub fn diagnose(input : String) -> Diagnostic {
  build_diagnostic(input, false)
}

///|
pub fn diagnose_segwit(input : String) -> Diagnostic {
  build_diagnostic(input, true)
}

///|
pub fn diagnose_many(inputs : Array[String]) -> Array[Diagnostic] {
  let out = Array::new(capacity=inputs.length())
  for input in inputs {
    out.push(diagnose(input))
  }
  out
}

///|
pub fn diagnose_segwit_many(inputs : Array[String]) -> Array[Diagnostic] {
  let out = Array::new(capacity=inputs.length())
  for input in inputs {
    out.push(diagnose_segwit(input))
  }
  out
}

///|
pub fn summarize_inputs(inputs : Array[String]) -> ValidationSummary {
  summarize_diagnostics(diagnose_many(inputs))
}

///|
pub fn summarize_segwit_inputs(inputs : Array[String]) -> ValidationSummary {
  summarize_diagnostics(diagnose_segwit_many(inputs))
}

///|
pub fn summarize_diagnostics(
  diagnostics : Array[Diagnostic],
) -> ValidationSummary {
  let mut total = 0
  let mut valid = 0
  let mut invalid = 0
  let mut segwit_valid = 0
  let mut canonical = 0
  let mut ok = 0
  let mut info = 0
  let mut warning = 0
  let mut error = 0
  let mut case_no_letters = 0
  let mut case_lower = 0
  let mut case_upper = 0
  let mut case_mixed = 0
  let mut variant_bech32 = 0
  let mut variant_bech32m = 0
  let mut network_mainnet = 0
  let mut network_testnet = 0
  let mut network_regtest = 0
  let mut network_unknown = 0
  let mut program_p2wpkh = 0
  let mut program_p2wsh = 0
  let mut program_taproot = 0
  let mut program_other = 0
  let mut recommend_none = 0
  let mut recommend_normalize_input = 0
  let mut recommend_lowercase_input = 0
  let mut recommend_check_separator = 0
  let mut recommend_check_hrp = 0
  let mut recommend_check_charset = 0
  let mut recommend_check_checksum = 0
  let mut recommend_check_padding = 0
  let mut recommend_check_witness_version = 0
  let mut recommend_check_witness_program_length = 0
  let mut recommend_use_bech32 = 0
  let mut recommend_use_bech32m = 0
  let mut recommend_check_network = 0
  let mut recommend_check_byte_conversion = 0
  let mut error_empty_input = 0
  let mut error_too_long = 0
  let mut error_missing_separator = 0
  let mut error_empty_hrp = 0
  let mut error_empty_data = 0
  let mut error_mixed_case = 0
  let mut error_invalid_hrp_char = 0
  let mut error_invalid_data_char = 0
  let mut error_invalid_data_value = 0
  let mut error_invalid_checksum = 0
  let mut error_invalid_bit_group = 0
  let mut error_invalid_padding = 0
  let mut error_invalid_witness_version = 0
  let mut error_invalid_witness_program_length = 0
  let mut error_invalid_witness_encoding = 0
  let mut error_unexpected_hrp = 0
  let mut error_unexpected_network = 0
  for diag in diagnostics {
    total += 1
    if diag.valid {
      valid += 1
    } else {
      invalid += 1
    }
    if diag.segwit_valid {
      segwit_valid += 1
    }
    if diag.canonical {
      canonical += 1
    }
    match diag.severity {
      DiagnosticOk => ok += 1
      DiagnosticInfo => info += 1
      DiagnosticWarning => warning += 1
      DiagnosticError => error += 1
    }
    match diag.case_style {
      CaseNoLetters => case_no_letters += 1
      CaseLower => case_lower += 1
      CaseUpper => case_upper += 1
      CaseMixed => case_mixed += 1
    }
    match diag.variant {
      "bech32" => variant_bech32 += 1
      "bech32m" => variant_bech32m += 1
      _ => ()
    }
    if diag.network == "bitcoin_mainnet" {
      network_mainnet += 1
    } else if diag.network == "bitcoin_testnet" {
      network_testnet += 1
    } else if diag.network == "bitcoin_regtest" {
      network_regtest += 1
    } else if !diag.network.is_empty() {
      network_unknown += 1
    }
    if diag.program_kind == "p2wpkh" {
      program_p2wpkh += 1
    } else if diag.program_kind == "p2wsh" {
      program_p2wsh += 1
    } else if diag.program_kind == "taproot" {
      program_taproot += 1
    } else if !diag.program_kind.is_empty() {
      program_other += 1
    }
    match diag.recommendation {
      RecommendNone => recommend_none += 1
      RecommendNormalizeInput => recommend_normalize_input += 1
      RecommendLowercaseInput => recommend_lowercase_input += 1
      RecommendCheckSeparator => recommend_check_separator += 1
      RecommendCheckHrp => recommend_check_hrp += 1
      RecommendCheckCharset => recommend_check_charset += 1
      RecommendCheckChecksum => recommend_check_checksum += 1
      RecommendCheckPadding => recommend_check_padding += 1
      RecommendCheckWitnessVersion => recommend_check_witness_version += 1
      RecommendCheckWitnessProgramLength =>
        recommend_check_witness_program_length += 1
      RecommendUseBech32 => recommend_use_bech32 += 1
      RecommendUseBech32m => recommend_use_bech32m += 1
      RecommendCheckNetwork => recommend_check_network += 1
      RecommendCheckByteConversion => recommend_check_byte_conversion += 1
    }
    match diag.error_code {
      "empty_input" => error_empty_input += 1
      "too_long" => error_too_long += 1
      "missing_separator" => error_missing_separator += 1
      "empty_hrp" => error_empty_hrp += 1
      "empty_data" => error_empty_data += 1
      "mixed_case" => error_mixed_case += 1
      "invalid_hrp_char" => error_invalid_hrp_char += 1
      "invalid_data_char" => error_invalid_data_char += 1
      "invalid_data_value" => error_invalid_data_value += 1
      "invalid_checksum" => error_invalid_checksum += 1
      "invalid_bit_group" => error_invalid_bit_group += 1
      "invalid_padding" => error_invalid_padding += 1
      "invalid_witness_version" => error_invalid_witness_version += 1
      "invalid_witness_program_length" =>
        error_invalid_witness_program_length += 1
      "invalid_witness_encoding" => error_invalid_witness_encoding += 1
      "unexpected_hrp" => error_unexpected_hrp += 1
      "unexpected_network" => error_unexpected_network += 1
      _ => ()
    }
  }
  {
    total,
    valid,
    invalid,
    segwit_valid,
    canonical,
    ok,
    info,
    warning,
    error,
    case_no_letters,
    case_lower,
    case_upper,
    case_mixed,
    variant_bech32,
    variant_bech32m,
    network_mainnet,
    network_testnet,
    network_regtest,
    network_unknown,
    program_p2wpkh,
    program_p2wsh,
    program_taproot,
    program_other,
    recommend_none,
    recommend_normalize_input,
    recommend_lowercase_input,
    recommend_check_separator,
    recommend_check_hrp,
    recommend_check_charset,
    recommend_check_checksum,
    recommend_check_padding,
    recommend_check_witness_version,
    recommend_check_witness_program_length,
    recommend_use_bech32,
    recommend_use_bech32m,
    recommend_check_network,
    recommend_check_byte_conversion,
    error_empty_input,
    error_too_long,
    error_missing_separator,
    error_empty_hrp,
    error_empty_data,
    error_mixed_case,
    error_invalid_hrp_char,
    error_invalid_data_char,
    error_invalid_data_value,
    error_invalid_checksum,
    error_invalid_bit_group,
    error_invalid_padding,
    error_invalid_witness_version,
    error_invalid_witness_program_length,
    error_invalid_witness_encoding,
    error_unexpected_hrp,
    error_unexpected_network,
  }
}

///|
pub fn compare_inputs(left : String, right : String) -> ComparisonReport {
  compare_diagnostics(diagnose(left), diagnose(right))
}

///|
pub fn compare_diagnostics(
  left : Diagnostic,
  right : Diagnostic,
) -> ComparisonReport {
  let same_validity = left.valid == right.valid
  let same_segwit_validity = left.segwit_valid == right.segwit_valid
  let same_canonicality = left.canonical == right.canonical
  let same_variant = left.variant == right.variant
  let same_case_style = left.case_style == right.case_style
  let same_hrp = left.hrp == right.hrp
  let same_network = left.network == right.network
  let same_program_kind = left.program_kind == right.program_kind
  let same_error_code = left.error_code == right.error_code
  let same_length = left.normalized.length() == right.normalized.length()
  let mut difference_count = 0
  if !same_validity {
    difference_count += 1
  }
  if !same_segwit_validity {
    difference_count += 1
  }
  if !same_canonicality {
    difference_count += 1
  }
  if !same_variant {
    difference_count += 1
  }
  if !same_case_style {
    difference_count += 1
  }
  if !same_hrp {
    difference_count += 1
  }
  if !same_network {
    difference_count += 1
  }
  if !same_program_kind {
    difference_count += 1
  }
  if !same_error_code {
    difference_count += 1
  }
  if !same_length {
    difference_count += 1
  }
  {
    left_input: left.input,
    right_input: right.input,
    left_valid: left.valid,
    right_valid: right.valid,
    left_segwit_valid: left.segwit_valid,
    right_segwit_valid: right.segwit_valid,
    left_canonical: left.canonical,
    right_canonical: right.canonical,
    left_variant: left.variant,
    right_variant: right.variant,
    left_case_style: left.case_style,
    right_case_style: right.case_style,
    left_hrp: left.hrp,
    right_hrp: right.hrp,
    left_network: left.network,
    right_network: right.network,
    left_program_kind: left.program_kind,
    right_program_kind: right.program_kind,
    left_error_code: left.error_code,
    right_error_code: right.error_code,
    same_validity,
    same_segwit_validity,
    same_canonicality,
    same_variant,
    same_case_style,
    same_hrp,
    same_network,
    same_program_kind,
    same_error_code,
    same_length,
    difference_count,
  }
}

///|
pub fn comparison_hints(report : ComparisonReport) -> Array[String] {
  let hints = Array::new()
  if !report.same_validity {
    hints.push("one input is valid while the other is not")
  }
  if !report.same_variant {
    hints.push("the checksum variants differ")
  }
  if !report.same_hrp {
    hints.push("the human-readable part differs")
  }
  if !report.same_network {
    hints.push("the SegWit networks differ")
  }
  if !report.same_program_kind {
    hints.push("the witness program categories differ")
  }
  if !report.same_error_code {
    hints.push("the error codes differ")
  }
  if hints.is_empty() {
    hints.push("the two inputs behave the same way")
  }
  hints
}

///|
pub fn render_diagnostic(diagnostic : Diagnostic) -> String {
  let out = StringBuilder(size_hint=512)
  write_line(out, "diagnostic")
  write_kv(out, "input", diagnostic.input)
  write_kv(out, "normalized", diagnostic.normalized)
  write_kv(out, "valid", bool_text(diagnostic.valid))
  write_kv(out, "segwit_valid", bool_text(diagnostic.segwit_valid))
  write_kv(out, "canonical", bool_text(diagnostic.canonical))
  write_kv(out, "severity", severity_name(diagnostic.severity))
  write_kv(
    out,
    "recommendation",
    recommendation_name(diagnostic.recommendation),
  )
  write_kv(out, "case_style", case_style_name(diagnostic.case_style))
  write_kv(out, "variant", diagnostic.variant)
  write_kv(out, "hrp", diagnostic.hrp)
  write_kv(out, "network", diagnostic.network)
  write_kv(out, "program_kind", diagnostic.program_kind)
  write_kv(out, "error_code", diagnostic.error_code)
  write_kv(out, "error_message", diagnostic.error_message)
  write_hint_block(out, diagnostic.hints)
  out.to_string()
}

///|
pub fn render_comparison(report : ComparisonReport) -> String {
  let out = StringBuilder(size_hint=512)
  write_line(out, "comparison")
  write_kv(out, "left_input", report.left_input)
  write_kv(out, "right_input", report.right_input)
  write_kv(out, "same_validity", bool_text(report.same_validity))
  write_kv(out, "same_segwit_validity", bool_text(report.same_segwit_validity))
  write_kv(out, "same_canonicality", bool_text(report.same_canonicality))
  write_kv(out, "same_variant", bool_text(report.same_variant))
  write_kv(out, "same_case_style", bool_text(report.same_case_style))
  write_kv(out, "same_hrp", bool_text(report.same_hrp))
  write_kv(out, "same_network", bool_text(report.same_network))
  write_kv(out, "same_program_kind", bool_text(report.same_program_kind))
  write_kv(out, "same_error_code", bool_text(report.same_error_code))
  write_kv(out, "same_length", bool_text(report.same_length))
  write_kv(
    out,
    "difference_count",
    int_to_decimal_string(report.difference_count),
  )
  write_line(out, "")
  write_line(out, "comparison_hints")
  write_hint_block(out, comparison_hints(report))
  out.to_string()
}

///|
pub fn render_validation_summary(summary : ValidationSummary) -> String {
  let out = StringBuilder(size_hint=2048)
  write_line(out, "validation summary")
  write_kv(out, "total", int_to_decimal_string(summary.total))
  write_kv(out, "valid", int_to_decimal_string(summary.valid))
  write_kv(out, "invalid", int_to_decimal_string(summary.invalid))
  write_kv(out, "segwit_valid", int_to_decimal_string(summary.segwit_valid))
  write_kv(out, "canonical", int_to_decimal_string(summary.canonical))
  write_kv(out, "ok", int_to_decimal_string(summary.ok))
  write_kv(out, "info", int_to_decimal_string(summary.info))
  write_kv(out, "warning", int_to_decimal_string(summary.warning))
  write_kv(out, "error", int_to_decimal_string(summary.error))
  write_kv(
    out,
    "case_no_letters",
    int_to_decimal_string(summary.case_no_letters),
  )
  write_kv(out, "case_lower", int_to_decimal_string(summary.case_lower))
  write_kv(out, "case_upper", int_to_decimal_string(summary.case_upper))
  write_kv(out, "case_mixed", int_to_decimal_string(summary.case_mixed))
  write_kv(out, "variant_bech32", int_to_decimal_string(summary.variant_bech32))
  write_kv(
    out,
    "variant_bech32m",
    int_to_decimal_string(summary.variant_bech32m),
  )
  write_kv(
    out,
    "network_mainnet",
    int_to_decimal_string(summary.network_mainnet),
  )
  write_kv(
    out,
    "network_testnet",
    int_to_decimal_string(summary.network_testnet),
  )
  write_kv(
    out,
    "network_regtest",
    int_to_decimal_string(summary.network_regtest),
  )
  write_kv(
    out,
    "network_unknown",
    int_to_decimal_string(summary.network_unknown),
  )
  write_kv(out, "program_p2wpkh", int_to_decimal_string(summary.program_p2wpkh))
  write_kv(out, "program_p2wsh", int_to_decimal_string(summary.program_p2wsh))
  write_kv(
    out,
    "program_taproot",
    int_to_decimal_string(summary.program_taproot),
  )
  write_kv(out, "program_other", int_to_decimal_string(summary.program_other))
  write_line(out, "")
  write_line(out, "recommendations")
  write_kv(out, "none", int_to_decimal_string(summary.recommend_none))
  write_kv(
    out,
    "normalize_input",
    int_to_decimal_string(summary.recommend_normalize_input),
  )
  write_kv(
    out,
    "lowercase_input",
    int_to_decimal_string(summary.recommend_lowercase_input),
  )
  write_kv(
    out,
    "check_separator",
    int_to_decimal_string(summary.recommend_check_separator),
  )
  write_kv(out, "check_hrp", int_to_decimal_string(summary.recommend_check_hrp))
  write_kv(
    out,
    "check_charset",
    int_to_decimal_string(summary.recommend_check_charset),
  )
  write_kv(
    out,
    "check_checksum",
    int_to_decimal_string(summary.recommend_check_checksum),
  )
  write_kv(
    out,
    "check_padding",
    int_to_decimal_string(summary.recommend_check_padding),
  )
  write_kv(
    out,
    "check_witness_version",
    int_to_decimal_string(summary.recommend_check_witness_version),
  )
  write_kv(
    out,
    "check_witness_program_length",
    int_to_decimal_string(summary.recommend_check_witness_program_length),
  )
  write_kv(
    out,
    "use_bech32",
    int_to_decimal_string(summary.recommend_use_bech32),
  )
  write_kv(
    out,
    "use_bech32m",
    int_to_decimal_string(summary.recommend_use_bech32m),
  )
  write_kv(
    out,
    "check_network",
    int_to_decimal_string(summary.recommend_check_network),
  )
  write_kv(
    out,
    "check_byte_conversion",
    int_to_decimal_string(summary.recommend_check_byte_conversion),
  )
  write_line(out, "")
  write_line(out, "errors")
  write_kv(out, "empty_input", int_to_decimal_string(summary.error_empty_input))
  write_kv(out, "too_long", int_to_decimal_string(summary.error_too_long))
  write_kv(
    out,
    "missing_separator",
    int_to_decimal_string(summary.error_missing_separator),
  )
  write_kv(out, "empty_hrp", int_to_decimal_string(summary.error_empty_hrp))
  write_kv(out, "empty_data", int_to_decimal_string(summary.error_empty_data))
  write_kv(out, "mixed_case", int_to_decimal_string(summary.error_mixed_case))
  write_kv(
    out,
    "invalid_hrp_char",
    int_to_decimal_string(summary.error_invalid_hrp_char),
  )
  write_kv(
    out,
    "invalid_data_char",
    int_to_decimal_string(summary.error_invalid_data_char),
  )
  write_kv(
    out,
    "invalid_data_value",
    int_to_decimal_string(summary.error_invalid_data_value),
  )
  write_kv(
    out,
    "invalid_checksum",
    int_to_decimal_string(summary.error_invalid_checksum),
  )
  write_kv(
    out,
    "invalid_bit_group",
    int_to_decimal_string(summary.error_invalid_bit_group),
  )
  write_kv(
    out,
    "invalid_padding",
    int_to_decimal_string(summary.error_invalid_padding),
  )
  write_kv(
    out,
    "invalid_witness_version",
    int_to_decimal_string(summary.error_invalid_witness_version),
  )
  write_kv(
    out,
    "invalid_witness_program_length",
    int_to_decimal_string(summary.error_invalid_witness_program_length),
  )
  write_kv(
    out,
    "invalid_witness_encoding",
    int_to_decimal_string(summary.error_invalid_witness_encoding),
  )
  write_kv(
    out,
    "unexpected_hrp",
    int_to_decimal_string(summary.error_unexpected_hrp),
  )
  write_kv(
    out,
    "unexpected_network",
    int_to_decimal_string(summary.error_unexpected_network),
  )
  out.to_string()
}

///|
pub fn summary_has_errors(summary : ValidationSummary) -> Bool {
  summary.error > 0
}

///|
pub fn summary_is_clean(summary : ValidationSummary) -> Bool {
  summary.invalid == 0 && summary.error == 0
}

///|
pub fn summary_has_segwit(summary : ValidationSummary) -> Bool {
  summary.segwit_valid > 0
}

///|
fn build_diagnostic(input : String, segwit_mode : Bool) -> Diagnostic {
  let report = validation_report(input)
  let canonical = is_canonical(input)
  let mut severity = if report.valid {
    if canonical {
      DiagnosticOk
    } else {
      DiagnosticInfo
    }
  } else {
    DiagnosticError
  }
  let mut recommendation = recommendation_for_general_report(report, canonical)
  let mut network = ""
  let mut program_kind = ""
  let hints = hints_for_general_report(report, canonical)
  if report.valid {
    match inspect_segwit(input) {
      Ok(info) => {
        network = network_name(info.network)
        program_kind = witness_program_kind_name(info.program_kind)
        if network == "unknown" && segwit_mode {
          severity = DiagnosticWarning
          recommendation = RecommendCheckNetwork
          hints.push(
            "the address is valid Bech32 but the HRP is not a standard Bitcoin network",
          )
        }
      }
      Err(err) =>
        if segwit_mode {
          severity = DiagnosticWarning
          recommendation = recommendation_for_error(err)
          hints.append(hints_for_error(err))
        }
    }
  }
  if !report.valid {
    hints.append(hints_for_error_code(report.error_code))
  }
  if !canonical && report.valid {
    hints.push(
      "normalize the input to lowercase before storing or publishing it",
    )
  }
  if segwit_mode && report.valid && !report.segwit_valid {
    hints.push("the string is valid Bech32 but not a valid SegWit address")
  }
  {
    input,
    normalized: report.normalized,
    valid: report.valid,
    segwit_valid: report.segwit_valid,
    canonical,
    severity,
    recommendation,
    case_style: classify_case(input),
    variant: report.variant,
    hrp: report.hrp,
    network,
    program_kind,
    error_code: report.error_code,
    error_message: report.error_message,
    hints,
  }
}

///|
fn recommendation_for_general_report(
  report : ValidationReport,
  canonical : Bool,
) -> DiagnosticRecommendation {
  if !report.valid {
    recommendation_for_error_code(report.error_code)
  } else if !canonical {
    RecommendNormalizeInput
  } else {
    RecommendNone
  }
}

///|
fn recommendation_for_error_code(code : String) -> DiagnosticRecommendation {
  match code {
    "empty_input" => RecommendCheckSeparator
    "too_long" => RecommendCheckByteConversion
    "missing_separator" => RecommendCheckSeparator
    "empty_hrp" => RecommendCheckHrp
    "empty_data" => RecommendCheckChecksum
    "mixed_case" => RecommendLowercaseInput
    "invalid_hrp_char" => RecommendCheckHrp
    "invalid_data_char" => RecommendCheckCharset
    "invalid_data_value" => RecommendCheckByteConversion
    "invalid_checksum" => RecommendCheckChecksum
    "invalid_bit_group" => RecommendCheckByteConversion
    "invalid_padding" => RecommendCheckPadding
    "invalid_witness_version" => RecommendCheckWitnessVersion
    "invalid_witness_program_length" => RecommendCheckWitnessProgramLength
    "invalid_witness_encoding" => RecommendCheckNetwork
    "unexpected_hrp" => RecommendCheckHrp
    "unexpected_network" => RecommendCheckNetwork
    _ => RecommendNone
  }
}

///|
fn recommendation_for_error(err : Bech32Error) -> DiagnosticRecommendation {
  recommendation_for_error_code(error_code(err))
}

///|
fn hints_for_general_report(
  report : ValidationReport,
  canonical : Bool,
) -> Array[String] {
  let hints = Array::new()
  if report.valid && canonical {
    hints.push("this input is a valid canonical Bech32 string")
  } else if report.valid && !canonical {
    hints.push("this input is valid but not canonical lowercase form")
  } else {
    hints.push("the input is not a valid Bech32 string")
  }
  hints
}

///|
fn hints_for_error_code(code : String) -> Array[String] {
  match code {
    "empty_input" => ["provide a full Bech32 string"]
    "too_long" => ["the string exceeds the 90-character Bech32 limit"]
    "missing_separator" => ["add the separator character '1'"]
    "empty_hrp" => ["the human-readable part cannot be empty"]
    "empty_data" => ["the data part must contain at least six checksum words"]
    "mixed_case" => ["use all lower-case or all upper-case input"]
    "invalid_hrp_char" =>
      ["the human-readable part must stay within printable ASCII"]
    "invalid_data_char" => ["the data part must use the Bech32 character set"]
    "invalid_data_value" => ["the decoded data value is outside 0..31"]
    "invalid_checksum" => ["recompute the checksum with the correct variant"]
    "invalid_bit_group" => ["check the from_bits and to_bits arguments"]
    "invalid_padding" => ["use canonical padding rules when decoding"]
    "invalid_witness_version" => ["SegWit witness version must stay in 0..16"]
    "invalid_witness_program_length" =>
      ["the witness program length does not match the selected version"]
    "invalid_witness_encoding" =>
      ["the checksum variant does not match the witness version"]
    "unexpected_hrp" =>
      ["the decoded HRP does not match the expected namespace"]
    "unexpected_network" =>
      ["the decoded network does not match the expected network"]
    _ => ["unknown validation error"]
  }
}

///|
fn hints_for_error(err : Bech32Error) -> Array[String] {
  match err {
    EmptyInput => ["provide a full Bech32 string"]
    TooLong(_) => ["the string exceeds the 90-character Bech32 limit"]
    MissingSeparator => ["add the separator character '1'"]
    EmptyHrp => ["the human-readable part cannot be empty"]
    EmptyData => ["the data part must contain at least six checksum words"]
    MixedCase => ["use all lower-case or all upper-case input"]
    InvalidHrpChar(_, _) =>
      ["the human-readable part must stay within printable ASCII"]
    InvalidDataChar(_, _) => ["the data part must use the Bech32 character set"]
    InvalidDataValue(_, _) => ["the decoded data value is outside 0..31"]
    InvalidChecksum => ["recompute the checksum with the correct variant"]
    InvalidBitGroup(_, _) => ["check the from_bits and to_bits arguments"]
    InvalidPadding => ["use canonical padding rules when decoding"]
    InvalidWitnessVersion(_) => ["SegWit witness version must stay in 0..16"]
    InvalidWitnessProgramLength(_, _) =>
      ["the witness program length does not match the selected version"]
    InvalidWitnessEncoding(expected, actual) =>
      [
        "the checksum variant does not match the witness version",
        "expected " +
        variant_name(expected) +
        " but decoded " +
        variant_name(actual),
      ]
    UnexpectedHrp(expected, actual) =>
      [
        "the decoded HRP does not match the expected namespace",
        "expected " + expected + " but got " + actual,
      ]
    UnexpectedNetwork(expected, actual) =>
      [
        "the decoded network does not match the expected network",
        "expected " +
        network_name(expected) +
        " but got " +
        network_name(actual),
      ]
  }
}

///|
fn write_kv(out : StringBuilder, key : String, value : String) -> Unit {
  out.write_string(key)
  out.write_string(": ")
  out.write_string(value)
  out.write_char('\n')
}

///|
fn write_line(out : StringBuilder, value : String) -> Unit {
  out.write_string(value)
  out.write_char('\n')
}

///|
fn write_hint_block(out : StringBuilder, hints : Array[String]) -> Unit {
  if hints.is_empty() {
    write_line(out, "hints: none")
    return
  }
  write_line(out, "hints")
  for hint in hints {
    out.write_string("- ")
    out.write_string(hint)
    out.write_char('\n')
  }
}

///|
fn bool_text(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn int_to_decimal_string(value : Int) -> String {
  if value == 0 {
    return "0"
  }
  let mut n = value
  let mut negative = false
  if n < 0 {
    negative = true
    n = -n
  }
  let digits = Array::new()
  while n > 0 {
    let d = n % 10
    digits.push(char_at("0123456789", d))
    n = n / 10
  }
  let out = StringBuilder(size_hint=12)
  if negative {
    out.write_char('-')
  }
  let mut i = digits.length()
  while i > 0 {
    i -= 1
    out.write_char(digits[i])
  }
  out.to_string()
}
