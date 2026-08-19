///|
/// Failure reason produced by policy-level validation.
pub(all) enum PolicyFailureKind {
  PolicyFailureNone
  PolicyFailureInvalidBech32(String)
  PolicyFailureNotCanonical
  PolicyFailureVariantNotAllowed(String)
  PolicyFailureHrpNotAllowed(String)
  PolicyFailurePayloadTooShort(Int, Int)
  PolicyFailurePayloadTooLong(Int, Int)
  PolicyFailureSegwitRequired
  PolicyFailureNetworkNotAllowed(String)
  PolicyFailureProgramKindNotAllowed(String)
} derive(Eq, Debug)

///|
/// Higher-level acceptance policy built on top of Bech32 and SegWit validation.
pub(all) struct Bech32Policy {
  name : String
  allow_any_hrp : Bool
  allowed_hrps : Array[String]
  allow_bech32 : Bool
  allow_bech32m : Bool
  require_canonical : Bool
  require_segwit : Bool
  allow_any_network : Bool
  allowed_networks : Array[String]
  allow_any_program_kind : Bool
  allowed_program_kinds : Array[String]
  min_payload_words : Int
  max_payload_words : Int
} derive(Eq, Debug)

///|
/// Result of applying a high-level policy to one input.
pub(all) struct PolicyCheck {
  input : String
  policy_name : String
  accepted : Bool
  valid : Bool
  segwit_valid : Bool
  canonical : Bool
  variant : String
  hrp : String
  network : String
  program_kind : String
  payload_words : Int
  failure : PolicyFailureKind
  failure_code : String
  failure_message : String
  recommendation : String
} derive(Eq, Debug)

///|
/// Aggregated policy-check result for a batch.
pub(all) struct PolicySummary {
  policy_name : String
  total : Int
  accepted : Int
  rejected : Int
  rejected_invalid : Int
  rejected_not_canonical : Int
  rejected_variant : Int
  rejected_hrp : Int
  rejected_payload_too_short : Int
  rejected_payload_too_long : Int
  rejected_segwit_required : Int
  rejected_network : Int
  rejected_program_kind : Int
} derive(Eq, Debug)

///|
pub fn any_bech32_policy() -> Bech32Policy {
  {
    name: "any_bech32",
    allow_any_hrp: true,
    allowed_hrps: [],
    allow_bech32: true,
    allow_bech32m: true,
    require_canonical: false,
    require_segwit: false,
    allow_any_network: true,
    allowed_networks: [],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 0,
    max_payload_words: 83,
  }
}

///|
pub fn canonical_bech32_policy() -> Bech32Policy {
  {
    name: "canonical_bech32",
    allow_any_hrp: true,
    allowed_hrps: [],
    allow_bech32: true,
    allow_bech32m: true,
    require_canonical: true,
    require_segwit: false,
    allow_any_network: true,
    allowed_networks: [],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 0,
    max_payload_words: 83,
  }
}

///|
pub fn bech32_only_policy() -> Bech32Policy {
  {
    name: "bech32_only",
    allow_any_hrp: true,
    allowed_hrps: [],
    allow_bech32: true,
    allow_bech32m: false,
    require_canonical: false,
    require_segwit: false,
    allow_any_network: true,
    allowed_networks: [],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 0,
    max_payload_words: 83,
  }
}

///|
pub fn bech32m_only_policy() -> Bech32Policy {
  {
    name: "bech32m_only",
    allow_any_hrp: true,
    allowed_hrps: [],
    allow_bech32: false,
    allow_bech32m: true,
    require_canonical: false,
    require_segwit: false,
    allow_any_network: true,
    allowed_networks: [],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 0,
    max_payload_words: 83,
  }
}

///|
pub fn bitcoin_segwit_policy() -> Bech32Policy {
  {
    name: "bitcoin_segwit",
    allow_any_hrp: false,
    allowed_hrps: ["bc", "tb", "bcrt"],
    allow_bech32: true,
    allow_bech32m: true,
    require_canonical: true,
    require_segwit: true,
    allow_any_network: false,
    allowed_networks: ["bitcoin_mainnet", "bitcoin_testnet", "bitcoin_regtest"],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 1,
    max_payload_words: 65,
  }
}

///|
pub fn bitcoin_mainnet_segwit_policy() -> Bech32Policy {
  {
    name: "bitcoin_mainnet_segwit",
    allow_any_hrp: false,
    allowed_hrps: ["bc"],
    allow_bech32: true,
    allow_bech32m: true,
    require_canonical: true,
    require_segwit: true,
    allow_any_network: false,
    allowed_networks: ["bitcoin_mainnet"],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 1,
    max_payload_words: 65,
  }
}

///|
pub fn bitcoin_testnet_segwit_policy() -> Bech32Policy {
  {
    name: "bitcoin_testnet_segwit",
    allow_any_hrp: false,
    allowed_hrps: ["tb"],
    allow_bech32: true,
    allow_bech32m: true,
    require_canonical: true,
    require_segwit: true,
    allow_any_network: false,
    allowed_networks: ["bitcoin_testnet"],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 1,
    max_payload_words: 65,
  }
}

///|
pub fn bitcoin_regtest_segwit_policy() -> Bech32Policy {
  {
    name: "bitcoin_regtest_segwit",
    allow_any_hrp: false,
    allowed_hrps: ["bcrt"],
    allow_bech32: true,
    allow_bech32m: true,
    require_canonical: true,
    require_segwit: true,
    allow_any_network: false,
    allowed_networks: ["bitcoin_regtest"],
    allow_any_program_kind: true,
    allowed_program_kinds: [],
    min_payload_words: 1,
    max_payload_words: 65,
  }
}

///|
pub fn taproot_mainnet_policy() -> Bech32Policy {
  {
    name: "taproot_mainnet",
    allow_any_hrp: false,
    allowed_hrps: ["bc"],
    allow_bech32: false,
    allow_bech32m: true,
    require_canonical: true,
    require_segwit: true,
    allow_any_network: false,
    allowed_networks: ["bitcoin_mainnet"],
    allow_any_program_kind: false,
    allowed_program_kinds: ["taproot"],
    min_payload_words: 1,
    max_payload_words: 65,
  }
}

///|
pub fn policy_with_name(policy : Bech32Policy, name : String) -> Bech32Policy {
  {
    name,
    allow_any_hrp: policy.allow_any_hrp,
    allowed_hrps: policy.allowed_hrps,
    allow_bech32: policy.allow_bech32,
    allow_bech32m: policy.allow_bech32m,
    require_canonical: policy.require_canonical,
    require_segwit: policy.require_segwit,
    allow_any_network: policy.allow_any_network,
    allowed_networks: policy.allowed_networks,
    allow_any_program_kind: policy.allow_any_program_kind,
    allowed_program_kinds: policy.allowed_program_kinds,
    min_payload_words: policy.min_payload_words,
    max_payload_words: policy.max_payload_words,
  }
}

///|
pub fn policy_with_hrps(
  policy : Bech32Policy,
  hrps : Array[String],
) -> Bech32Policy {
  {
    name: policy.name,
    allow_any_hrp: false,
    allowed_hrps: normalize_string_list(hrps),
    allow_bech32: policy.allow_bech32,
    allow_bech32m: policy.allow_bech32m,
    require_canonical: policy.require_canonical,
    require_segwit: policy.require_segwit,
    allow_any_network: policy.allow_any_network,
    allowed_networks: policy.allowed_networks,
    allow_any_program_kind: policy.allow_any_program_kind,
    allowed_program_kinds: policy.allowed_program_kinds,
    min_payload_words: policy.min_payload_words,
    max_payload_words: policy.max_payload_words,
  }
}

///|
pub fn policy_with_payload_bounds(
  policy : Bech32Policy,
  min_payload_words : Int,
  max_payload_words : Int,
) -> Bech32Policy {
  {
    name: policy.name,
    allow_any_hrp: policy.allow_any_hrp,
    allowed_hrps: policy.allowed_hrps,
    allow_bech32: policy.allow_bech32,
    allow_bech32m: policy.allow_bech32m,
    require_canonical: policy.require_canonical,
    require_segwit: policy.require_segwit,
    allow_any_network: policy.allow_any_network,
    allowed_networks: policy.allowed_networks,
    allow_any_program_kind: policy.allow_any_program_kind,
    allowed_program_kinds: policy.allowed_program_kinds,
    min_payload_words,
    max_payload_words,
  }
}

///|
pub fn policy_requiring_canonical(
  policy : Bech32Policy,
  required : Bool,
) -> Bech32Policy {
  {
    name: policy.name,
    allow_any_hrp: policy.allow_any_hrp,
    allowed_hrps: policy.allowed_hrps,
    allow_bech32: policy.allow_bech32,
    allow_bech32m: policy.allow_bech32m,
    require_canonical: required,
    require_segwit: policy.require_segwit,
    allow_any_network: policy.allow_any_network,
    allowed_networks: policy.allowed_networks,
    allow_any_program_kind: policy.allow_any_program_kind,
    allowed_program_kinds: policy.allowed_program_kinds,
    min_payload_words: policy.min_payload_words,
    max_payload_words: policy.max_payload_words,
  }
}

///|
pub fn check_with_policy(input : String, policy : Bech32Policy) -> PolicyCheck {
  let diag = diagnose(input)
  if !diag.valid {
    return policy_reject(
      diag,
      policy,
      PolicyFailureInvalidBech32(diag.error_code),
    )
  }
  if policy.require_canonical && !diag.canonical {
    return policy_reject(diag, policy, PolicyFailureNotCanonical)
  }
  if !variant_allowed(policy, diag.variant) {
    return policy_reject(
      diag,
      policy,
      PolicyFailureVariantNotAllowed(diag.variant),
    )
  }
  if !hrp_allowed(policy, diag.hrp) {
    return policy_reject(diag, policy, PolicyFailureHrpNotAllowed(diag.hrp))
  }
  let payload_words = match inspect(input) {
    Ok(info) => info.data_length
    Err(_) => 0
  }
  if payload_words < policy.min_payload_words {
    return policy_reject(
      diag,
      policy,
      PolicyFailurePayloadTooShort(policy.min_payload_words, payload_words),
    )
  }
  if payload_words > policy.max_payload_words {
    return policy_reject(
      diag,
      policy,
      PolicyFailurePayloadTooLong(policy.max_payload_words, payload_words),
    )
  }
  if policy.require_segwit && !diag.segwit_valid {
    return policy_reject(diag, policy, PolicyFailureSegwitRequired)
  }
  if diag.segwit_valid && !network_allowed(policy, diag.network) {
    return policy_reject(
      diag,
      policy,
      PolicyFailureNetworkNotAllowed(diag.network),
    )
  }
  if diag.segwit_valid && !program_kind_allowed(policy, diag.program_kind) {
    return policy_reject(
      diag,
      policy,
      PolicyFailureProgramKindNotAllowed(diag.program_kind),
    )
  }
  policy_accept(diag, policy, payload_words)
}

///|
pub fn check_many_with_policy(
  inputs : Array[String],
  policy : Bech32Policy,
) -> Array[PolicyCheck] {
  let out = Array::new(capacity=inputs.length())
  for input in inputs {
    out.push(check_with_policy(input, policy))
  }
  out
}

///|
pub fn summarize_policy_checks(checks : Array[PolicyCheck]) -> PolicySummary {
  let mut policy_name = ""
  let mut total = 0
  let mut accepted = 0
  let mut rejected = 0
  let mut rejected_invalid = 0
  let mut rejected_not_canonical = 0
  let mut rejected_variant = 0
  let mut rejected_hrp = 0
  let mut rejected_payload_too_short = 0
  let mut rejected_payload_too_long = 0
  let mut rejected_segwit_required = 0
  let mut rejected_network = 0
  let mut rejected_program_kind = 0
  for check in checks {
    if policy_name.is_empty() {
      policy_name = check.policy_name
    }
    total += 1
    if check.accepted {
      accepted += 1
    } else {
      rejected += 1
      match check.failure {
        PolicyFailureNone => ()
        PolicyFailureInvalidBech32(_) => rejected_invalid += 1
        PolicyFailureNotCanonical => rejected_not_canonical += 1
        PolicyFailureVariantNotAllowed(_) => rejected_variant += 1
        PolicyFailureHrpNotAllowed(_) => rejected_hrp += 1
        PolicyFailurePayloadTooShort(_, _) => rejected_payload_too_short += 1
        PolicyFailurePayloadTooLong(_, _) => rejected_payload_too_long += 1
        PolicyFailureSegwitRequired => rejected_segwit_required += 1
        PolicyFailureNetworkNotAllowed(_) => rejected_network += 1
        PolicyFailureProgramKindNotAllowed(_) => rejected_program_kind += 1
      }
    }
  }
  {
    policy_name,
    total,
    accepted,
    rejected,
    rejected_invalid,
    rejected_not_canonical,
    rejected_variant,
    rejected_hrp,
    rejected_payload_too_short,
    rejected_payload_too_long,
    rejected_segwit_required,
    rejected_network,
    rejected_program_kind,
  }
}

///|
pub fn summarize_policy_inputs(
  inputs : Array[String],
  policy : Bech32Policy,
) -> PolicySummary {
  summarize_policy_checks(check_many_with_policy(inputs, policy))
}

///|
pub fn policy_accepts(input : String, policy : Bech32Policy) -> Bool {
  check_with_policy(input, policy).accepted
}

///|
pub fn policy_rejects(input : String, policy : Bech32Policy) -> Bool {
  !policy_accepts(input, policy)
}

///|
pub fn accepted_inputs(
  inputs : Array[String],
  policy : Bech32Policy,
) -> Array[String] {
  let out = Array::new()
  for input in inputs {
    if policy_accepts(input, policy) {
      out.push(input)
    }
  }
  out
}

///|
pub fn rejected_inputs(
  inputs : Array[String],
  policy : Bech32Policy,
) -> Array[String] {
  let out = Array::new()
  for input in inputs {
    if policy_rejects(input, policy) {
      out.push(input)
    }
  }
  out
}

///|
pub fn first_policy_failure(
  inputs : Array[String],
  policy : Bech32Policy,
) -> PolicyCheck? {
  for input in inputs {
    let check = check_with_policy(input, policy)
    if !check.accepted {
      return Some(check)
    }
  }
  None
}

///|
pub fn policy_failure_code(failure : PolicyFailureKind) -> String {
  match failure {
    PolicyFailureNone => ""
    PolicyFailureInvalidBech32(code) => "invalid_bech32." + code
    PolicyFailureNotCanonical => "not_canonical"
    PolicyFailureVariantNotAllowed(_) => "variant_not_allowed"
    PolicyFailureHrpNotAllowed(_) => "hrp_not_allowed"
    PolicyFailurePayloadTooShort(_, _) => "payload_too_short"
    PolicyFailurePayloadTooLong(_, _) => "payload_too_long"
    PolicyFailureSegwitRequired => "segwit_required"
    PolicyFailureNetworkNotAllowed(_) => "network_not_allowed"
    PolicyFailureProgramKindNotAllowed(_) => "program_kind_not_allowed"
  }
}

///|
pub fn policy_failure_message(failure : PolicyFailureKind) -> String {
  match failure {
    PolicyFailureNone => "input satisfies the selected policy"
    PolicyFailureInvalidBech32(code) => "input is not valid Bech32: " + code
    PolicyFailureNotCanonical => "input is valid but not canonical lowercase"
    PolicyFailureVariantNotAllowed(variant) =>
      "checksum variant is not allowed: " + variant
    PolicyFailureHrpNotAllowed(hrp) =>
      "human-readable part is not allowed: " + hrp
    PolicyFailurePayloadTooShort(expected, actual) =>
      "payload is shorter than the policy minimum: expected at least " +
      policy_int_to_string(expected) +
      ", got " +
      policy_int_to_string(actual)
    PolicyFailurePayloadTooLong(expected, actual) =>
      "payload is longer than the policy maximum: expected at most " +
      policy_int_to_string(expected) +
      ", got " +
      policy_int_to_string(actual)
    PolicyFailureSegwitRequired => "policy requires a valid SegWit address"
    PolicyFailureNetworkNotAllowed(network) =>
      "SegWit network is not allowed: " + network
    PolicyFailureProgramKindNotAllowed(kind) =>
      "witness program kind is not allowed: " + kind
  }
}

///|
pub fn policy_failure_recommendation(failure : PolicyFailureKind) -> String {
  match failure {
    PolicyFailureNone => "no action required"
    PolicyFailureInvalidBech32(_) =>
      "fix the underlying Bech32 validation error"
    PolicyFailureNotCanonical =>
      "normalize the input before applying the policy"
    PolicyFailureVariantNotAllowed(_) =>
      "use an allowed Bech32 checksum variant"
    PolicyFailureHrpNotAllowed(_) => "use one of the policy-approved HRPs"
    PolicyFailurePayloadTooShort(_, _) => "increase the payload data length"
    PolicyFailurePayloadTooLong(_, _) => "reduce the payload data length"
    PolicyFailureSegwitRequired =>
      "provide a BIP-0173 or BIP-0350 SegWit address"
    PolicyFailureNetworkNotAllowed(_) => "switch to the expected SegWit network"
    PolicyFailureProgramKindNotAllowed(_) =>
      "use a witness program type accepted by the policy"
  }
}

///|
pub fn render_policy_check(check : PolicyCheck) -> String {
  let out = StringBuilder(size_hint=512)
  policy_write_line(out, "policy check")
  policy_write_kv(out, "policy", check.policy_name)
  policy_write_kv(out, "input", check.input)
  policy_write_kv(out, "accepted", policy_bool_text(check.accepted))
  policy_write_kv(out, "valid", policy_bool_text(check.valid))
  policy_write_kv(out, "segwit_valid", policy_bool_text(check.segwit_valid))
  policy_write_kv(out, "canonical", policy_bool_text(check.canonical))
  policy_write_kv(out, "variant", check.variant)
  policy_write_kv(out, "hrp", check.hrp)
  policy_write_kv(out, "network", check.network)
  policy_write_kv(out, "program_kind", check.program_kind)
  policy_write_kv(
    out,
    "payload_words",
    policy_int_to_string(check.payload_words),
  )
  policy_write_kv(out, "failure_code", check.failure_code)
  policy_write_kv(out, "failure_message", check.failure_message)
  policy_write_kv(out, "recommendation", check.recommendation)
  out.to_string()
}

///|
pub fn render_policy_summary(summary : PolicySummary) -> String {
  let out = StringBuilder(size_hint=512)
  policy_write_line(out, "policy summary")
  policy_write_kv(out, "policy", summary.policy_name)
  policy_write_kv(out, "total", policy_int_to_string(summary.total))
  policy_write_kv(out, "accepted", policy_int_to_string(summary.accepted))
  policy_write_kv(out, "rejected", policy_int_to_string(summary.rejected))
  policy_write_kv(
    out,
    "invalid",
    policy_int_to_string(summary.rejected_invalid),
  )
  policy_write_kv(
    out,
    "not_canonical",
    policy_int_to_string(summary.rejected_not_canonical),
  )
  policy_write_kv(
    out,
    "variant",
    policy_int_to_string(summary.rejected_variant),
  )
  policy_write_kv(out, "hrp", policy_int_to_string(summary.rejected_hrp))
  policy_write_kv(
    out,
    "payload_too_short",
    policy_int_to_string(summary.rejected_payload_too_short),
  )
  policy_write_kv(
    out,
    "payload_too_long",
    policy_int_to_string(summary.rejected_payload_too_long),
  )
  policy_write_kv(
    out,
    "segwit_required",
    policy_int_to_string(summary.rejected_segwit_required),
  )
  policy_write_kv(
    out,
    "network",
    policy_int_to_string(summary.rejected_network),
  )
  policy_write_kv(
    out,
    "program_kind",
    policy_int_to_string(summary.rejected_program_kind),
  )
  out.to_string()
}

///|
fn policy_accept(
  diag : Diagnostic,
  policy : Bech32Policy,
  payload_words : Int,
) -> PolicyCheck {
  {
    input: diag.input,
    policy_name: policy.name,
    accepted: true,
    valid: diag.valid,
    segwit_valid: diag.segwit_valid,
    canonical: diag.canonical,
    variant: diag.variant,
    hrp: diag.hrp,
    network: diag.network,
    program_kind: diag.program_kind,
    payload_words,
    failure: PolicyFailureNone,
    failure_code: "",
    failure_message: policy_failure_message(PolicyFailureNone),
    recommendation: policy_failure_recommendation(PolicyFailureNone),
  }
}

///|
fn policy_reject(
  diag : Diagnostic,
  policy : Bech32Policy,
  failure : PolicyFailureKind,
) -> PolicyCheck {
  let payload_words = if diag.valid {
    match inspect(diag.input) {
      Ok(info) => info.data_length
      Err(_) => 0
    }
  } else {
    0
  }
  {
    input: diag.input,
    policy_name: policy.name,
    accepted: false,
    valid: diag.valid,
    segwit_valid: diag.segwit_valid,
    canonical: diag.canonical,
    variant: diag.variant,
    hrp: diag.hrp,
    network: diag.network,
    program_kind: diag.program_kind,
    payload_words,
    failure,
    failure_code: policy_failure_code(failure),
    failure_message: policy_failure_message(failure),
    recommendation: policy_failure_recommendation(failure),
  }
}

///|
fn variant_allowed(policy : Bech32Policy, variant : String) -> Bool {
  if variant == "bech32" {
    policy.allow_bech32
  } else if variant == "bech32m" {
    policy.allow_bech32m
  } else {
    false
  }
}

///|
fn hrp_allowed(policy : Bech32Policy, hrp : String) -> Bool {
  policy.allow_any_hrp ||
  string_array_contains(policy.allowed_hrps, hrp.to_lower())
}

///|
fn network_allowed(policy : Bech32Policy, network : String) -> Bool {
  policy.allow_any_network ||
  string_array_contains(policy.allowed_networks, network)
}

///|
fn program_kind_allowed(policy : Bech32Policy, kind : String) -> Bool {
  policy.allow_any_program_kind ||
  string_array_contains(policy.allowed_program_kinds, kind)
}

///|
fn normalize_string_list(values : Array[String]) -> Array[String] {
  let out = Array::new(capacity=values.length())
  for value in values {
    out.push(value.to_lower())
  }
  out
}

///|
fn string_array_contains(values : Array[String], expected : String) -> Bool {
  for value in values {
    if value == expected {
      return true
    }
  }
  false
}

///|
fn policy_write_kv(out : StringBuilder, key : String, value : String) -> Unit {
  out.write_string(key)
  out.write_string(": ")
  out.write_string(value)
  out.write_char('\n')
}

///|
fn policy_write_line(out : StringBuilder, value : String) -> Unit {
  out.write_string(value)
  out.write_char('\n')
}

///|
fn policy_bool_text(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn policy_int_to_string(value : Int) -> String {
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
