///|
/// Scan mode for text extraction helpers.
pub(all) enum ScanMode {
  ScanGeneric
  ScanSegwit
} derive(Eq, Debug)

///|
/// Boundary policy used when extracting candidates from a larger text.
pub(all) enum ScanBoundaryStyle {
  ScanBoundaryLoose
  ScanBoundaryToken
  ScanBoundaryStrict
} derive(Eq, Debug)

///|
/// Policy issue emitted by scan lint helpers.
pub(all) enum ScanIssueKind {
  ScanIssueInvalidCandidate
  ScanIssueNonCanonical
  ScanIssueNotSegwit
  ScanIssueUnexpectedHrp
  ScanIssueUnexpectedNetwork
  ScanIssueNonStandardNetwork
  ScanIssueMixedCase
  ScanIssueUppercase
  ScanIssueDuplicate
} derive(Eq, Debug)

///|
/// Options for extracting Bech32-like candidates from text.
pub(all) struct ScanOptions {
  min_length : Int
  max_length : Int
  include_invalid : Bool
  mode : ScanMode
  require_canonical : Bool
  require_standard_segwit_hrp : Bool
  expected_hrp : String
  expected_network : String
  accept_uppercase : Bool
  accept_mixed_case : Bool
  boundary_style : ScanBoundaryStyle
  deduplicate : Bool
} derive(Eq, Debug)

///|
/// Location of one extracted candidate.
pub(all) struct CandidateSpan {
  text : String
  start_offset : Int
  end_offset : Int
  length : Int
  line_number : Int
  column_number : Int
} derive(Eq, Debug)

///|
/// One candidate and its diagnostic output.
pub(all) struct ScanFinding {
  span : CandidateSpan
  diagnostic : Diagnostic
  accepted : Bool
  reason : String
  duplicate_of : Int
} derive(Eq, Debug)

///|
/// Aggregated scan output.
pub(all) struct ScanReport {
  source : String
  findings : Array[ScanFinding]
  summary : ValidationSummary
  total_candidates : Int
  accepted : Int
  rejected : Int
  valid : Int
  invalid : Int
  segwit_valid : Int
  canonical : Int
  duplicate : Int
} derive(Eq, Debug)

///|
/// A policy issue derived from scan findings.
pub(all) struct ScanIssue {
  kind : ScanIssueKind
  severity : DiagnosticSeverity
  finding_index : Int
  related_index : Int
  input : String
  normalized : String
  message : String
  recommendation : DiagnosticRecommendation
} derive(Eq, Debug)

///|
priv struct ScanCollectResult {
  findings : Array[ScanFinding]
  total_candidates : Int
  rejected : Int
  duplicate : Int
}

///|
pub fn default_scan_options() -> ScanOptions {
  {
    min_length: 8,
    max_length: 90,
    include_invalid: false,
    mode: ScanGeneric,
    require_canonical: false,
    require_standard_segwit_hrp: false,
    expected_hrp: "",
    expected_network: "",
    accept_uppercase: true,
    accept_mixed_case: false,
    boundary_style: ScanBoundaryToken,
    deduplicate: false,
  }
}

///|
pub fn segwit_scan_options() -> ScanOptions {
  {
    min_length: 14,
    max_length: 90,
    include_invalid: false,
    mode: ScanSegwit,
    require_canonical: true,
    require_standard_segwit_hrp: true,
    expected_hrp: "",
    expected_network: "",
    accept_uppercase: true,
    accept_mixed_case: false,
    boundary_style: ScanBoundaryToken,
    deduplicate: false,
  }
}

///|
pub fn scan_options_with_min_length(
  options : ScanOptions,
  min_length : Int,
) -> ScanOptions {
  {
    min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_with_max_length(
  options : ScanOptions,
  max_length : Int,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_include_invalid(
  options : ScanOptions,
  include_invalid : Bool,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_mode(options : ScanOptions, mode : ScanMode) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_require_canonical(
  options : ScanOptions,
  require_canonical : Bool,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_require_standard_segwit_hrp(
  options : ScanOptions,
  require_standard_segwit_hrp : Bool,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_expected_hrp(
  options : ScanOptions,
  expected_hrp : String,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: expected_hrp.to_lower(),
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_expected_network(
  options : ScanOptions,
  expected_network : String,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_accept_uppercase(
  options : ScanOptions,
  accept_uppercase : Bool,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_accept_mixed_case(
  options : ScanOptions,
  accept_mixed_case : Bool,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_boundary_style(
  options : ScanOptions,
  boundary_style : ScanBoundaryStyle,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style,
    deduplicate: options.deduplicate,
  }
}

///|
pub fn scan_options_deduplicate(
  options : ScanOptions,
  deduplicate : Bool,
) -> ScanOptions {
  {
    min_length: options.min_length,
    max_length: options.max_length,
    include_invalid: options.include_invalid,
    mode: options.mode,
    require_canonical: options.require_canonical,
    require_standard_segwit_hrp: options.require_standard_segwit_hrp,
    expected_hrp: options.expected_hrp,
    expected_network: options.expected_network,
    accept_uppercase: options.accept_uppercase,
    accept_mixed_case: options.accept_mixed_case,
    boundary_style: options.boundary_style,
    deduplicate,
  }
}

///|
pub fn scan_mode_name(mode : ScanMode) -> String {
  match mode {
    ScanGeneric => "generic"
    ScanSegwit => "segwit"
  }
}

///|
pub fn scan_boundary_style_name(style : ScanBoundaryStyle) -> String {
  match style {
    ScanBoundaryLoose => "loose"
    ScanBoundaryToken => "token"
    ScanBoundaryStrict => "strict"
  }
}

///|
pub fn scan_issue_kind_name(kind : ScanIssueKind) -> String {
  match kind {
    ScanIssueInvalidCandidate => "invalid_candidate"
    ScanIssueNonCanonical => "non_canonical"
    ScanIssueNotSegwit => "not_segwit"
    ScanIssueUnexpectedHrp => "unexpected_hrp"
    ScanIssueUnexpectedNetwork => "unexpected_network"
    ScanIssueNonStandardNetwork => "non_standard_network"
    ScanIssueMixedCase => "mixed_case"
    ScanIssueUppercase => "uppercase"
    ScanIssueDuplicate => "duplicate"
  }
}

///|
pub fn scan_text(text : String) -> ScanReport {
  scan_text_with_options(text, default_scan_options())
}

///|
pub fn scan_segwit_text(text : String) -> ScanReport {
  scan_text_with_options(text, segwit_scan_options())
}

///|
pub fn scan_text_with_options(
  text : String,
  options : ScanOptions,
) -> ScanReport {
  let collected = collect_scan_findings(text, 0, 0, options)
  make_scan_report(text, collected)
}

///|
pub fn scan_lines(lines : Array[String]) -> ScanReport {
  scan_lines_with_options(lines, default_scan_options())
}

///|
pub fn scan_segwit_lines(lines : Array[String]) -> ScanReport {
  scan_lines_with_options(lines, segwit_scan_options())
}

///|
pub fn scan_lines_with_options(
  lines : Array[String],
  options : ScanOptions,
) -> ScanReport {
  scan_text_with_options(join_scan_lines(lines), options)
}

///|
pub fn scan_report_is_empty(report : ScanReport) -> Bool {
  report.findings.is_empty()
}

///|
pub fn scan_report_has_valid(report : ScanReport) -> Bool {
  report.valid > 0
}

///|
pub fn scan_report_has_invalid(report : ScanReport) -> Bool {
  report.invalid > 0
}

///|
pub fn scan_report_has_segwit(report : ScanReport) -> Bool {
  report.segwit_valid > 0
}

///|
pub fn scan_report_is_clean(report : ScanReport) -> Bool {
  report.invalid == 0 && report.summary.error == 0
}

///|
pub fn scan_report_all_canonical(report : ScanReport) -> Bool {
  report.accepted == report.canonical
}

///|
pub fn scan_finding_texts(findings : Array[ScanFinding]) -> Array[String] {
  let out = Array::new(capacity=findings.length())
  for finding in findings {
    out.push(finding.span.text)
  }
  out
}

///|
pub fn scan_finding_normalized_texts(
  findings : Array[ScanFinding],
) -> Array[String] {
  let out = Array::new(capacity=findings.length())
  for finding in findings {
    out.push(finding.diagnostic.normalized)
  }
  out
}

///|
pub fn scan_finding_hrps(findings : Array[ScanFinding]) -> Array[String] {
  let out = Array::new()
  for finding in findings {
    if !finding.diagnostic.hrp.is_empty() {
      out.push(finding.diagnostic.hrp)
    }
  }
  out
}

///|
pub fn scan_finding_networks(findings : Array[ScanFinding]) -> Array[String] {
  let out = Array::new()
  for finding in findings {
    if !finding.diagnostic.network.is_empty() {
      out.push(finding.diagnostic.network)
    }
  }
  out
}

///|
pub fn valid_scan_findings(findings : Array[ScanFinding]) -> Array[ScanFinding] {
  let out = Array::new()
  for finding in findings {
    if finding.diagnostic.valid {
      out.push(finding)
    }
  }
  out
}

///|
pub fn invalid_scan_findings(
  findings : Array[ScanFinding],
) -> Array[ScanFinding] {
  let out = Array::new()
  for finding in findings {
    if !finding.diagnostic.valid {
      out.push(finding)
    }
  }
  out
}

///|
pub fn segwit_scan_findings(
  findings : Array[ScanFinding],
) -> Array[ScanFinding] {
  let out = Array::new()
  for finding in findings {
    if finding.diagnostic.segwit_valid {
      out.push(finding)
    }
  }
  out
}

///|
pub fn canonical_scan_findings(
  findings : Array[ScanFinding],
) -> Array[ScanFinding] {
  let out = Array::new()
  for finding in findings {
    if finding.diagnostic.canonical {
      out.push(finding)
    }
  }
  out
}

///|
pub fn non_canonical_scan_findings(
  findings : Array[ScanFinding],
) -> Array[ScanFinding] {
  let out = Array::new()
  for finding in findings {
    if finding.diagnostic.valid && !finding.diagnostic.canonical {
      out.push(finding)
    }
  }
  out
}

///|
pub fn filter_scan_findings_by_hrp(
  findings : Array[ScanFinding],
  hrp : String,
) -> Array[ScanFinding] {
  let expected = hrp.to_lower()
  let out = Array::new()
  for finding in findings {
    if finding.diagnostic.hrp == expected {
      out.push(finding)
    }
  }
  out
}

///|
pub fn filter_scan_findings_by_network(
  findings : Array[ScanFinding],
  network : String,
) -> Array[ScanFinding] {
  let out = Array::new()
  for finding in findings {
    if finding.diagnostic.network == network {
      out.push(finding)
    }
  }
  out
}

///|
pub fn first_valid_scan_finding(report : ScanReport) -> ScanFinding? {
  for finding in report.findings {
    if finding.diagnostic.valid {
      return Some(finding)
    }
  }
  None
}

///|
pub fn first_segwit_scan_finding(report : ScanReport) -> ScanFinding? {
  for finding in report.findings {
    if finding.diagnostic.segwit_valid {
      return Some(finding)
    }
  }
  None
}

///|
pub fn scan_report_diagnostics(report : ScanReport) -> Array[Diagnostic] {
  diagnostics_from_scan_findings(report.findings)
}

///|
pub fn lint_scan_report(
  report : ScanReport,
  options : ScanOptions,
) -> Array[ScanIssue] {
  let issues = Array::new()
  for index, finding in report.findings.iter2() {
    append_finding_issues(issues, index, finding, options)
  }
  issues
}

///|
pub fn scan_issue_count(issues : Array[ScanIssue]) -> Int {
  issues.length()
}

///|
pub fn scan_issue_error_count(issues : Array[ScanIssue]) -> Int {
  let mut count = 0
  for issue in issues {
    if issue.severity == DiagnosticError {
      count += 1
    }
  }
  count
}

///|
pub fn scan_issue_warning_count(issues : Array[ScanIssue]) -> Int {
  let mut count = 0
  for issue in issues {
    if issue.severity == DiagnosticWarning {
      count += 1
    }
  }
  count
}

///|
pub fn scan_issue_info_count(issues : Array[ScanIssue]) -> Int {
  let mut count = 0
  for issue in issues {
    if issue.severity == DiagnosticInfo {
      count += 1
    }
  }
  count
}

///|
pub fn scan_issues_are_clean(issues : Array[ScanIssue]) -> Bool {
  scan_issue_error_count(issues) == 0 && scan_issue_warning_count(issues) == 0
}

///|
pub fn render_scan_finding(finding : ScanFinding) -> String {
  let out = StringBuilder(size_hint=512)
  write_line(out, "scan finding")
  write_kv(out, "text", finding.span.text)
  write_kv(
    out,
    "start_offset",
    int_to_decimal_string(finding.span.start_offset),
  )
  write_kv(out, "end_offset", int_to_decimal_string(finding.span.end_offset))
  write_kv(out, "line", int_to_decimal_string(finding.span.line_number))
  write_kv(out, "column", int_to_decimal_string(finding.span.column_number))
  write_kv(out, "accepted", bool_text(finding.accepted))
  write_kv(out, "reason", finding.reason)
  write_kv(out, "duplicate_of", int_to_decimal_string(finding.duplicate_of))
  write_kv(out, "valid", bool_text(finding.diagnostic.valid))
  write_kv(out, "segwit_valid", bool_text(finding.diagnostic.segwit_valid))
  write_kv(out, "canonical", bool_text(finding.diagnostic.canonical))
  write_kv(out, "variant", finding.diagnostic.variant)
  write_kv(out, "hrp", finding.diagnostic.hrp)
  write_kv(out, "network", finding.diagnostic.network)
  write_kv(out, "error_code", finding.diagnostic.error_code)
  out.to_string()
}

///|
pub fn render_scan_report(report : ScanReport) -> String {
  let out = StringBuilder(size_hint=2048)
  write_line(out, "scan report")
  write_kv(out, "source", report.source)
  write_kv(
    out,
    "total_candidates",
    int_to_decimal_string(report.total_candidates),
  )
  write_kv(out, "accepted", int_to_decimal_string(report.accepted))
  write_kv(out, "rejected", int_to_decimal_string(report.rejected))
  write_kv(out, "valid", int_to_decimal_string(report.valid))
  write_kv(out, "invalid", int_to_decimal_string(report.invalid))
  write_kv(out, "segwit_valid", int_to_decimal_string(report.segwit_valid))
  write_kv(out, "canonical", int_to_decimal_string(report.canonical))
  write_kv(out, "duplicate", int_to_decimal_string(report.duplicate))
  for index, finding in report.findings.iter2() {
    write_line(out, "")
    write_kv(out, "finding_index", int_to_decimal_string(index))
    write_kv(out, "finding_text", finding.span.text)
    write_kv(out, "finding_reason", finding.reason)
  }
  out.to_string()
}

///|
pub fn render_scan_issue(issue : ScanIssue) -> String {
  let out = StringBuilder(size_hint=512)
  write_line(out, "scan issue")
  write_kv(out, "kind", scan_issue_kind_name(issue.kind))
  write_kv(out, "severity", severity_name(issue.severity))
  write_kv(out, "finding_index", int_to_decimal_string(issue.finding_index))
  write_kv(out, "related_index", int_to_decimal_string(issue.related_index))
  write_kv(out, "input", issue.input)
  write_kv(out, "normalized", issue.normalized)
  write_kv(out, "message", issue.message)
  write_kv(out, "recommendation", recommendation_name(issue.recommendation))
  out.to_string()
}

///|
pub fn render_scan_issues(issues : Array[ScanIssue]) -> String {
  let out = StringBuilder(size_hint=1024)
  write_line(out, "scan issues")
  write_kv(out, "count", int_to_decimal_string(issues.length()))
  for index, issue in issues.iter2() {
    write_line(out, "")
    write_kv(out, "issue_index", int_to_decimal_string(index))
    write_kv(out, "kind", scan_issue_kind_name(issue.kind))
    write_kv(out, "severity", severity_name(issue.severity))
    write_kv(out, "message", issue.message)
  }
  out.to_string()
}

///|
fn collect_scan_findings(
  text : String,
  base_offset : Int,
  fixed_line_number : Int,
  options : ScanOptions,
) -> ScanCollectResult {
  let findings = Array::new()
  let mut total_candidates = 0
  let mut rejected = 0
  let mut duplicate = 0
  let mut index = 0
  while index < text.length() {
    if scan_is_token_char(scan_char_at(text, index)) {
      let start = index
      while index < text.length() &&
            scan_is_token_char(scan_char_at(text, index)) {
        index += 1
      }
      let end_offset = index
      let candidate = text[start:end_offset].to_owned()
      if scan_is_probable_candidate(candidate, options) &&
        scan_boundaries_accept(text, start, end_offset, options.boundary_style) {
        total_candidates += 1
        let diagnostic = if options.mode == ScanSegwit {
          diagnose_segwit(candidate)
        } else {
          diagnose(candidate)
        }
        let duplicate_of = duplicate_index(findings, diagnostic.normalized)
        if duplicate_of >= 0 {
          duplicate += 1
        }
        let accepted = scan_accepts_diagnostic(
          diagnostic, duplicate_of, options,
        )
        let reason = scan_acceptance_reason(
          diagnostic, duplicate_of, options, accepted,
        )
        let span = make_candidate_span(
          text, candidate, start, end_offset, base_offset, fixed_line_number,
        )
        let finding = { span, diagnostic, accepted, reason, duplicate_of }
        if accepted {
          findings.push(finding)
        } else {
          rejected += 1
        }
      }
    } else {
      index += 1
    }
  }
  { findings, total_candidates, rejected, duplicate }
}

///|
fn scan_is_probable_candidate(
  candidate : String,
  options : ScanOptions,
) -> Bool {
  let length = candidate.length()
  if length < options.min_length {
    return false
  }
  if options.max_length > 0 && length > options.max_length {
    return false
  }
  let p = profile(candidate)
  if !p.has_separator {
    return false
  }
  if p.hrp_length == 0 {
    return false
  }
  if p.data_part_length < 6 {
    return false
  }
  true
}

///|
fn scan_boundaries_accept(
  text : String,
  start : Int,
  end_offset : Int,
  style : ScanBoundaryStyle,
) -> Bool {
  match style {
    ScanBoundaryLoose => true
    ScanBoundaryToken =>
      scan_side_is_not_token(text, start - 1) &&
      scan_side_is_not_token(text, end_offset)
    ScanBoundaryStrict =>
      scan_side_is_strict_boundary(text, start - 1) &&
      scan_side_is_strict_boundary(text, end_offset)
  }
}

///|
fn scan_side_is_not_token(text : String, offset : Int) -> Bool {
  if offset < 0 || offset >= text.length() {
    return true
  }
  !scan_is_token_char(scan_char_at(text, offset))
}

///|
fn scan_side_is_strict_boundary(text : String, offset : Int) -> Bool {
  if offset < 0 || offset >= text.length() {
    return true
  }
  scan_is_strict_boundary_char(scan_char_at(text, offset))
}

///|
fn scan_accepts_diagnostic(
  diagnostic : Diagnostic,
  duplicate_of : Int,
  options : ScanOptions,
) -> Bool {
  if !options.accept_mixed_case && diagnostic.case_style == CaseMixed {
    return false
  }
  if !options.accept_uppercase && diagnostic.case_style == CaseUpper {
    return false
  }
  if !diagnostic.valid && !options.include_invalid {
    return false
  }
  if options.mode == ScanSegwit &&
    !diagnostic.segwit_valid &&
    !options.include_invalid {
    return false
  }
  if options.require_canonical && diagnostic.valid && !diagnostic.canonical {
    return false
  }
  if !options.expected_hrp.is_empty() && diagnostic.hrp != options.expected_hrp {
    return false
  }
  if options.require_standard_segwit_hrp &&
    !scan_is_standard_network_name(diagnostic.network) {
    return false
  }
  if !options.expected_network.is_empty() &&
    diagnostic.network != options.expected_network {
    return false
  }
  if options.deduplicate && duplicate_of >= 0 {
    return false
  }
  true
}

///|
fn scan_acceptance_reason(
  diagnostic : Diagnostic,
  duplicate_of : Int,
  options : ScanOptions,
  accepted : Bool,
) -> String {
  if accepted {
    if diagnostic.segwit_valid {
      return "accepted_segwit"
    }
    if diagnostic.valid {
      return "accepted_bech32"
    }
    return "accepted_invalid_for_diagnostics"
  }
  if !options.accept_mixed_case && diagnostic.case_style == CaseMixed {
    return "rejected_mixed_case"
  }
  if !options.accept_uppercase && diagnostic.case_style == CaseUpper {
    return "rejected_uppercase"
  }
  if !diagnostic.valid && !options.include_invalid {
    return "rejected_invalid"
  }
  if options.mode == ScanSegwit &&
    !diagnostic.segwit_valid &&
    !options.include_invalid {
    return "rejected_not_segwit"
  }
  if options.require_canonical && diagnostic.valid && !diagnostic.canonical {
    return "rejected_non_canonical"
  }
  if !options.expected_hrp.is_empty() && diagnostic.hrp != options.expected_hrp {
    return "rejected_unexpected_hrp"
  }
  if options.require_standard_segwit_hrp &&
    !scan_is_standard_network_name(diagnostic.network) {
    return "rejected_non_standard_network"
  }
  if !options.expected_network.is_empty() &&
    diagnostic.network != options.expected_network {
    return "rejected_unexpected_network"
  }
  if options.deduplicate && duplicate_of >= 0 {
    return "rejected_duplicate"
  }
  "rejected_by_policy"
}

///|
fn make_candidate_span(
  source : String,
  text : String,
  start : Int,
  end_offset : Int,
  base_offset : Int,
  fixed_line_number : Int,
) -> CandidateSpan {
  let absolute_start = base_offset + start
  let absolute_end = base_offset + end_offset
  let line_number = if fixed_line_number > 0 {
    fixed_line_number
  } else {
    line_number_at_offset(source, start)
  }
  let column_number = if fixed_line_number > 0 {
    start + 1
  } else {
    column_number_at_offset(source, start)
  }
  {
    text,
    start_offset: absolute_start,
    end_offset: absolute_end,
    length: text.length(),
    line_number,
    column_number,
  }
}

///|
fn make_scan_report(
  source : String,
  collected : ScanCollectResult,
) -> ScanReport {
  make_scan_report_from_parts(
    source,
    collected.findings,
    collected.total_candidates,
    collected.rejected,
    collected.duplicate,
  )
}

///|
fn make_scan_report_from_parts(
  source : String,
  findings : Array[ScanFinding],
  total_candidates : Int,
  rejected : Int,
  duplicate : Int,
) -> ScanReport {
  let diagnostics = diagnostics_from_scan_findings(findings)
  let summary = summarize_diagnostics(diagnostics)
  {
    source,
    findings,
    summary,
    total_candidates,
    accepted: findings.length(),
    rejected,
    valid: summary.valid,
    invalid: summary.invalid,
    segwit_valid: summary.segwit_valid,
    canonical: summary.canonical,
    duplicate,
  }
}

///|
fn diagnostics_from_scan_findings(
  findings : Array[ScanFinding],
) -> Array[Diagnostic] {
  let diagnostics = Array::new(capacity=findings.length())
  for finding in findings {
    diagnostics.push(finding.diagnostic)
  }
  diagnostics
}

///|
fn join_scan_lines(lines : Array[String]) -> String {
  let out = StringBuilder(size_hint=scan_lines_size_hint(lines))
  for index, line in lines.iter2() {
    if index > 0 {
      out.write_char('\n')
    }
    out.write_string(line)
  }
  out.to_string()
}

///|
fn scan_lines_size_hint(lines : Array[String]) -> Int {
  let mut size = 0
  for index, line in lines.iter2() {
    size += line.length()
    if index > 0 {
      size += 1
    }
  }
  size
}

///|
fn append_finding_issues(
  issues : Array[ScanIssue],
  index : Int,
  finding : ScanFinding,
  options : ScanOptions,
) -> Unit {
  let diagnostic = finding.diagnostic
  if !diagnostic.valid {
    issues.push(
      make_scan_issue(
        ScanIssueInvalidCandidate,
        DiagnosticError,
        index,
        -1,
        diagnostic,
        "candidate is not a valid Bech32 or Bech32m string",
        diagnostic.recommendation,
      ),
    )
  }
  if diagnostic.valid && !diagnostic.canonical && options.require_canonical {
    issues.push(
      make_scan_issue(
        ScanIssueNonCanonical,
        DiagnosticInfo,
        index,
        -1,
        diagnostic,
        "candidate is valid but not canonical lowercase",
        RecommendNormalizeInput,
      ),
    )
  }
  if options.mode == ScanSegwit && diagnostic.valid && !diagnostic.segwit_valid {
    issues.push(
      make_scan_issue(
        ScanIssueNotSegwit,
        DiagnosticWarning,
        index,
        -1,
        diagnostic,
        "candidate validates as Bech32 but not as SegWit",
        diagnostic.recommendation,
      ),
    )
  }
  if !options.accept_mixed_case && diagnostic.case_style == CaseMixed {
    issues.push(
      make_scan_issue(
        ScanIssueMixedCase,
        DiagnosticError,
        index,
        -1,
        diagnostic,
        "candidate mixes uppercase and lowercase letters",
        RecommendLowercaseInput,
      ),
    )
  }
  if !options.accept_uppercase && diagnostic.case_style == CaseUpper {
    issues.push(
      make_scan_issue(
        ScanIssueUppercase,
        DiagnosticInfo,
        index,
        -1,
        diagnostic,
        "candidate is uppercase and policy expects lowercase",
        RecommendNormalizeInput,
      ),
    )
  }
  if !options.expected_hrp.is_empty() && diagnostic.hrp != options.expected_hrp {
    issues.push(
      make_scan_issue(
        ScanIssueUnexpectedHrp,
        DiagnosticWarning,
        index,
        -1,
        diagnostic,
        "candidate HRP does not match the expected HRP",
        RecommendCheckHrp,
      ),
    )
  }
  if options.require_standard_segwit_hrp &&
    !scan_is_standard_network_name(diagnostic.network) {
    issues.push(
      make_scan_issue(
        ScanIssueNonStandardNetwork,
        DiagnosticWarning,
        index,
        -1,
        diagnostic,
        "candidate network is not a built-in Bitcoin SegWit network",
        RecommendCheckNetwork,
      ),
    )
  }
  if !options.expected_network.is_empty() &&
    diagnostic.network != options.expected_network {
    issues.push(
      make_scan_issue(
        ScanIssueUnexpectedNetwork,
        DiagnosticWarning,
        index,
        -1,
        diagnostic,
        "candidate network does not match the expected network",
        RecommendCheckNetwork,
      ),
    )
  }
  if finding.duplicate_of >= 0 {
    issues.push(
      make_scan_issue(
        ScanIssueDuplicate,
        DiagnosticInfo,
        index,
        finding.duplicate_of,
        diagnostic,
        "candidate duplicates an earlier normalized value",
        RecommendNormalizeInput,
      ),
    )
  }
}

///|
fn make_scan_issue(
  kind : ScanIssueKind,
  severity : DiagnosticSeverity,
  finding_index : Int,
  related_index : Int,
  diagnostic : Diagnostic,
  message : String,
  recommendation : DiagnosticRecommendation,
) -> ScanIssue {
  {
    kind,
    severity,
    finding_index,
    related_index,
    input: diagnostic.input,
    normalized: diagnostic.normalized,
    message,
    recommendation,
  }
}

///|
fn duplicate_index(findings : Array[ScanFinding], normalized : String) -> Int {
  if normalized.is_empty() {
    return -1
  }
  for index, finding in findings.iter2() {
    if finding.diagnostic.normalized == normalized {
      return index
    }
  }
  -1
}

///|
fn scan_is_standard_network_name(network : String) -> Bool {
  network == "bitcoin_mainnet" ||
  network == "bitcoin_testnet" ||
  network == "bitcoin_regtest"
}

///|
fn scan_is_token_char(ch : Char) -> Bool {
  scan_is_ascii_letter(ch) || scan_is_ascii_digit(ch)
}

///|
fn scan_is_ascii_letter(ch : Char) -> Bool {
  let code = ch.to_int()
  (code >= 65 && code <= 90) || (code >= 97 && code <= 122)
}

///|
fn scan_is_ascii_digit(ch : Char) -> Bool {
  let code = ch.to_int()
  code >= 48 && code <= 57
}

///|
fn scan_is_strict_boundary_char(ch : Char) -> Bool {
  let code = ch.to_int()
  code <= 32 ||
  code == 34 ||
  code == 39 ||
  code == 40 ||
  code == 41 ||
  code == 44 ||
  code == 59 ||
  code == 60 ||
  code == 62 ||
  code == 91 ||
  code == 93 ||
  code == 123 ||
  code == 125
}

///|
fn line_number_at_offset(text : String, offset : Int) -> Int {
  let mut line = 1
  let mut index = 0
  while index < offset && index < text.length() {
    if scan_char_at(text, index) == '\n' {
      line += 1
    }
    index += 1
  }
  line
}

///|
fn column_number_at_offset(text : String, offset : Int) -> Int {
  let mut column = 1
  let mut index = 0
  while index < offset && index < text.length() {
    if scan_char_at(text, index) == '\n' {
      column = 1
    } else {
      column += 1
    }
    index += 1
  }
  column
}

///|
fn scan_char_at(input : String, offset : Int) -> Char {
  input.get_char(offset).unwrap()
}
