///|
/// Bech32 checksum variant.
pub(all) enum Variant {
  Bech32
  Bech32m
} derive(Eq, Debug)

///|
/// A decoded Bech32 or Bech32m string. `data` contains 5-bit values with the
/// six checksum words removed.
pub(all) struct Decoded {
  hrp : String
  data : Array[Int]
  variant : Variant
} derive(Eq, Debug)

///|
/// A decoded BIP-0173/BIP-0350 SegWit address.
pub(all) struct SegwitAddress {
  hrp : String
  version : Int
  program : Array[Int]
  variant : Variant
} derive(Eq, Debug)

///|
/// Letter-case classification for Bech32 input strings.
pub(all) enum CaseStyle {
  CaseNoLetters
  CaseLower
  CaseUpper
  CaseMixed
} derive(Eq, Debug)

///|
/// Common SegWit network names inferred from the human-readable part.
pub(all) enum SegwitNetwork {
  NetworkBitcoinMainnet
  NetworkBitcoinTestnet
  NetworkBitcoinRegtest
  NetworkUnknown(String)
} derive(Eq, Debug)

///|
/// Common witness program categories useful for wallet and indexer diagnostics.
pub(all) enum WitnessProgramKind {
  WitnessProgramP2WPKH
  WitnessProgramP2WSH
  WitnessProgramTaproot
  WitnessProgramOther
} derive(Eq, Debug)

///|
/// Mechanical profile of an input string. This is available even for malformed
/// inputs and is useful for command-line diagnostics.
pub(all) struct InputProfile {
  input : String
  normalized : String
  total_length : Int
  separator_index : Int
  hrp_length : Int
  data_part_length : Int
  payload_length : Int
  checksum_length : Int
  case_style : CaseStyle
  has_separator : Bool
  has_checksum : Bool
} derive(Eq, Debug)

///|
/// Detailed information for a valid Bech32 or Bech32m string.
pub(all) struct Bech32Info {
  input : String
  normalized : String
  hrp : String
  data : Array[Int]
  checksum : Array[Int]
  variant : Variant
  total_length : Int
  separator_index : Int
  data_part_length : Int
  data_length : Int
  checksum_length : Int
  case_style : CaseStyle
  segwit_valid : Bool
} derive(Eq, Debug)

///|
/// Detailed information for a valid SegWit address.
pub(all) struct SegwitInfo {
  input : String
  normalized : String
  hrp : String
  version : Int
  program : Array[Int]
  program_length : Int
  variant : Variant
  network : SegwitNetwork
  program_kind : WitnessProgramKind
} derive(Eq, Debug)

///|
/// Stable validation report for batch tools. String fields are intentionally
/// presentation-ready so callers can print reports without matching every enum.
pub(all) struct ValidationReport {
  input : String
  normalized : String
  valid : Bool
  segwit_valid : Bool
  variant : String
  hrp : String
  error_code : String
  error_message : String
  total_length : Int
  separator_index : Int
  data_part_length : Int
} derive(Eq, Debug)

///|
/// Structured errors returned by the parser and validators.
pub(all) enum Bech32Error {
  EmptyInput
  TooLong(Int)
  MissingSeparator
  EmptyHrp
  EmptyData
  MixedCase
  InvalidHrpChar(Char, Int)
  InvalidDataChar(Char, Int)
  InvalidDataValue(Int, Int)
  InvalidChecksum
  InvalidBitGroup(Int, Int)
  InvalidPadding
  InvalidWitnessVersion(Int)
  InvalidWitnessProgramLength(Int, Int)
  InvalidWitnessEncoding(Variant, Variant)
  UnexpectedHrp(String, String)
  UnexpectedNetwork(SegwitNetwork, SegwitNetwork)
} derive(Eq, Debug)

///|
const CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

///|
const BECH32_CONST = 1

///|
const BECH32M_CONST = 0x2bc830a3

///|
const MAX_BECH32_LEN = 90

///|
/// Encodes 5-bit data words with a Bech32 checksum.
pub fn encode(hrp : String, data : Array[Int]) -> Result[String, Bech32Error] {
  encode_with_variant(hrp, data, Bech32)
}

///|
/// Encodes 5-bit data words with a Bech32m checksum.
pub fn encode_m(hrp : String, data : Array[Int]) -> Result[String, Bech32Error] {
  encode_with_variant(hrp, data, Bech32m)
}

///|
/// Encodes 5-bit data words with the selected checksum variant.
pub fn encode_with_variant(
  hrp : String,
  data : Array[Int],
  variant : Variant,
) -> Result[String, Bech32Error] {
  match validate_hrp(hrp) {
    Err(err) => return Err(err)
    Ok(_) => ()
  }
  match validate_data(data) {
    Err(err) => return Err(err)
    Ok(_) => ()
  }
  let lower_hrp = hrp.to_lower()
  let checksum = create_checksum(lower_hrp, data, variant)
  let out = StringBuilder(size_hint=lower_hrp.length() + 1 + data.length() + 6)
  out.write_string(lower_hrp)
  out.write_char('1')
  for value in data {
    out.write_char(char_at(CHARSET, value))
  }
  for value in checksum {
    out.write_char(char_at(CHARSET, value))
  }
  let encoded = out.to_string()
  if encoded.length() > MAX_BECH32_LEN {
    Err(TooLong(encoded.length()))
  } else {
    Ok(encoded)
  }
}

///|
/// Decodes a Bech32 or Bech32m string and verifies its checksum.
pub fn decode(input : String) -> Result[Decoded, Bech32Error] {
  if input.is_empty() {
    return Err(EmptyInput)
  }
  if input.length() > MAX_BECH32_LEN {
    return Err(TooLong(input.length()))
  }
  if has_mixed_case(input) {
    return Err(MixedCase)
  }
  let text = input.to_lower()
  let sep = last_separator(text)
  if sep < 0 {
    return Err(MissingSeparator)
  }
  if sep == 0 {
    return Err(EmptyHrp)
  }
  if sep + 7 > text.length() {
    return Err(EmptyData)
  }
  let hrp = text[:sep].to_owned()
  match validate_hrp(hrp) {
    Err(err) => return Err(err)
    Ok(_) => ()
  }
  let data = Array::new(capacity=text.length() - sep - 1)
  for i in (sep + 1)..<text.length() {
    let ch = char_at(text, i)
    match charset_value(ch) {
      Some(value) => data.push(value)
      None => return Err(InvalidDataChar(ch, i))
    }
  }
  let pm = polymod(expand_hrp(hrp) + data)
  let variant = if pm == BECH32_CONST {
    Bech32
  } else if pm == BECH32M_CONST {
    Bech32m
  } else {
    return Err(InvalidChecksum)
  }
  Ok({ hrp, data: data[:data.length() - 6].to_owned(), variant })
}

///|
/// Converts an array of unsigned integer groups from one bit width to another.
/// Use `pad=false` when decoding canonical encodings back to bytes.
pub fn convert_bits(
  data : Array[Int],
  from_bits : Int,
  to_bits : Int,
  pad : Bool,
) -> Result[Array[Int], Bech32Error] {
  if from_bits <= 0 || to_bits <= 0 || from_bits > 30 || to_bits > 30 {
    return Err(InvalidBitGroup(from_bits, to_bits))
  }
  let maxv = (1 << to_bits) - 1
  let max_acc = (1 << (from_bits + to_bits - 1)) - 1
  let ret = Array::new()
  let mut acc = 0
  let mut bits = 0
  for value in data {
    if value < 0 || value >> from_bits != 0 {
      return Err(InvalidDataValue(value, ret.length()))
    }
    acc = ((acc << from_bits) | value) & max_acc
    bits += from_bits
    while bits >= to_bits {
      bits -= to_bits
      ret.push((acc >> bits) & maxv)
    }
  }
  if pad {
    if bits > 0 {
      ret.push((acc << (to_bits - bits)) & maxv)
    }
  } else if bits >= from_bits || ((acc << (to_bits - bits)) & maxv) != 0 {
    return Err(InvalidPadding)
  }
  Ok(ret)
}

///|
/// Encodes byte values (`0..255`) as Bech32 data.
pub fn encode_bytes(
  hrp : String,
  bytes : Array[Int],
  variant : Variant,
) -> Result[String, Bech32Error] {
  match validate_octets(bytes) {
    Err(err) => Err(err)
    Ok(_) =>
      match convert_bits(bytes, 8, 5, true) {
        Ok(words) => encode_with_variant(hrp, words, variant)
        Err(err) => Err(err)
      }
  }
}

///|
/// Decodes Bech32 data back to byte values (`0..255`).
pub fn decode_bytes(
  input : String,
) -> Result[(String, Array[Int], Variant), Bech32Error] {
  match decode(input) {
    Err(err) => Err(err)
    Ok(decoded) =>
      match convert_bits(decoded.data, 5, 8, false) {
        Ok(bytes) => Ok((decoded.hrp, bytes, decoded.variant))
        Err(err) => Err(err)
      }
  }
}

///|
/// Encodes a SegWit address. Version 0 uses Bech32; versions 1 through 16 use
/// Bech32m, as required by BIP-0350.
pub fn encode_segwit(
  hrp : String,
  version : Int,
  program : Array[Int],
) -> Result[String, Bech32Error] {
  match validate_witness_program(version, program) {
    Err(err) => return Err(err)
    Ok(_) => ()
  }
  let variant = witness_variant(version)
  match convert_bits(program, 8, 5, true) {
    Err(err) => Err(err)
    Ok(words) => {
      let data = Array::new(capacity=words.length() + 1)
      data.push(version)
      data.append(words)
      encode_with_variant(hrp, data, variant)
    }
  }
}

///|
/// Decodes and validates a SegWit address.
pub fn decode_segwit(input : String) -> Result[SegwitAddress, Bech32Error] {
  match decode(input) {
    Err(err) => Err(err)
    Ok(decoded) => {
      if decoded.data.is_empty() {
        return Err(EmptyData)
      }
      let version = decoded.data[0]
      if version < 0 || version > 16 {
        return Err(InvalidWitnessVersion(version))
      }
      let payload = decoded.data[1:]
      match convert_bits(payload.to_owned(), 5, 8, false) {
        Err(err) => Err(err)
        Ok(program) => {
          match validate_witness_program(version, program) {
            Err(err) => return Err(err)
            Ok(_) => ()
          }
          let expected = witness_variant(version)
          if decoded.variant != expected {
            return Err(InvalidWitnessEncoding(expected, decoded.variant))
          }
          Ok({ hrp: decoded.hrp, version, program, variant: decoded.variant })
        }
      }
    }
  }
}

///|
/// Returns true when `input` is a valid Bech32 or Bech32m string.
pub fn is_valid(input : String) -> Bool {
  decode(input) is Ok(_)
}

///|
/// Returns true when `input` is a valid SegWit address.
pub fn is_valid_segwit(input : String) -> Bool {
  decode_segwit(input) is Ok(_)
}

///|
/// Returns a stable lowercase display name for a checksum variant.
pub fn variant_name(variant : Variant) -> String {
  match variant {
    Bech32 => "bech32"
    Bech32m => "bech32m"
  }
}

///|
/// Returns a stable lowercase display name for input letter-case style.
pub fn case_style_name(style : CaseStyle) -> String {
  match style {
    CaseNoLetters => "no_letters"
    CaseLower => "lower"
    CaseUpper => "upper"
    CaseMixed => "mixed"
  }
}

///|
/// Returns a stable display name for a SegWit network classification.
pub fn network_name(network : SegwitNetwork) -> String {
  match network {
    NetworkBitcoinMainnet => "bitcoin_mainnet"
    NetworkBitcoinTestnet => "bitcoin_testnet"
    NetworkBitcoinRegtest => "bitcoin_regtest"
    NetworkUnknown(_) => "unknown"
  }
}

///|
/// Returns a stable display name for a witness program category.
pub fn witness_program_kind_name(kind : WitnessProgramKind) -> String {
  match kind {
    WitnessProgramP2WPKH => "p2wpkh"
    WitnessProgramP2WSH => "p2wsh"
    WitnessProgramTaproot => "taproot"
    WitnessProgramOther => "other"
  }
}

///|
/// Classifies whether an input is lowercase, uppercase, mixed-case, or has no
/// ASCII letters. Bech32 accepts only all-lowercase or all-uppercase strings.
pub fn classify_case(input : String) -> CaseStyle {
  let mut has_lower = false
  let mut has_upper = false
  for ch in input {
    if ch.is_ascii_lowercase() {
      has_lower = true
    } else if ch.is_ascii_uppercase() {
      has_upper = true
    }
  }
  if has_lower && has_upper {
    CaseMixed
  } else if has_lower {
    CaseLower
  } else if has_upper {
    CaseUpper
  } else {
    CaseNoLetters
  }
}

///|
/// Builds a structural profile without validating checksum or character set.
pub fn profile(input : String) -> InputProfile {
  let normalized = input.to_lower()
  let sep = last_separator(normalized)
  let has_sep = sep >= 0
  let data_part_length = if has_sep { input.length() - sep - 1 } else { 0 }
  let payload_length = if data_part_length >= 6 {
    data_part_length - 6
  } else {
    0
  }
  let checksum_length = if data_part_length >= 6 { 6 } else { data_part_length }
  {
    input,
    normalized,
    total_length: input.length(),
    separator_index: sep,
    hrp_length: if has_sep {
      sep
    } else {
      0
    },
    data_part_length,
    payload_length,
    checksum_length,
    case_style: classify_case(input),
    has_separator: has_sep,
    has_checksum: data_part_length >= 6,
  }
}

///|
/// Returns a lowercase canonical representation after checksum validation.
pub fn normalize(input : String) -> Result[String, Bech32Error] {
  match decode(input) {
    Err(err) => Err(err)
    Ok(_) => Ok(input.to_lower())
  }
}

///|
/// Returns true when an input is valid and already in canonical lowercase form.
pub fn is_canonical(input : String) -> Bool {
  match normalize(input) {
    Err(_) => false
    Ok(canonical) => canonical == input
  }
}

///|
/// Returns true only for valid Bech32 strings.
pub fn is_bech32(input : String) -> Bool {
  match decode(input) {
    Err(_) => false
    Ok(decoded) => decoded.variant == Bech32
  }
}

///|
/// Returns true only for valid Bech32m strings.
pub fn is_bech32m(input : String) -> Bool {
  match decode(input) {
    Err(_) => false
    Ok(decoded) => decoded.variant == Bech32m
  }
}

///|
/// Extracts the HRP after full checksum validation.
pub fn hrp_of(input : String) -> Result[String, Bech32Error] {
  match decode(input) {
    Err(err) => Err(err)
    Ok(decoded) => Ok(decoded.hrp)
  }
}

///|
/// Extracts payload data words after full checksum validation.
pub fn data_words_of(input : String) -> Result[Array[Int], Bech32Error] {
  match decode(input) {
    Err(err) => Err(err)
    Ok(decoded) => Ok(decoded.data)
  }
}

///|
/// Extracts the six checksum words after full checksum validation.
pub fn checksum_words_of(input : String) -> Result[Array[Int], Bech32Error] {
  match decode(input) {
    Err(err) => Err(err)
    Ok(_) => Ok(checksum_words_from_normalized(input.to_lower()))
  }
}

///|
/// Decodes an input and additionally checks the expected HRP.
pub fn decode_with_hrp(
  input : String,
  expected_hrp : String,
) -> Result[Decoded, Bech32Error] {
  match validate_hrp(expected_hrp) {
    Err(err) => return Err(err)
    Ok(_) => ()
  }
  let expected = expected_hrp.to_lower()
  match decode(input) {
    Err(err) => Err(err)
    Ok(decoded) =>
      if decoded.hrp == expected {
        Ok(decoded)
      } else {
        Err(UnexpectedHrp(expected, decoded.hrp))
      }
  }
}

///|
/// Inspects a valid Bech32 or Bech32m string and returns printable metadata.
pub fn inspect(input : String) -> Result[Bech32Info, Bech32Error] {
  match decode(input) {
    Err(err) => Err(err)
    Ok(decoded) => {
      let normalized = input.to_lower()
      let sep = last_separator(normalized)
      let data_part_length = normalized.length() - sep - 1
      Ok({
        input,
        normalized,
        hrp: decoded.hrp,
        data: decoded.data,
        checksum: checksum_words_from_normalized(normalized),
        variant: decoded.variant,
        total_length: input.length(),
        separator_index: sep,
        data_part_length,
        data_length: data_part_length - 6,
        checksum_length: 6,
        case_style: classify_case(input),
        segwit_valid: decode_segwit(input) is Ok(_),
      })
    }
  }
}

///|
/// Produces one validation report that is convenient for CLI and UI callers.
pub fn validation_report(input : String) -> ValidationReport {
  let p = profile(input)
  match decode(input) {
    Err(err) =>
      {
        input,
        normalized: p.normalized,
        valid: false,
        segwit_valid: false,
        variant: "",
        hrp: "",
        error_code: error_code(err),
        error_message: error_message(err),
        total_length: p.total_length,
        separator_index: p.separator_index,
        data_part_length: p.data_part_length,
      }
    Ok(decoded) =>
      {
        input,
        normalized: p.normalized,
        valid: true,
        segwit_valid: decode_segwit(input) is Ok(_),
        variant: variant_name(decoded.variant),
        hrp: decoded.hrp,
        error_code: "",
        error_message: "",
        total_length: p.total_length,
        separator_index: p.separator_index,
        data_part_length: p.data_part_length,
      }
  }
}

///|
/// Validates many inputs while preserving input order.
pub fn validate_many(inputs : Array[String]) -> Array[ValidationReport] {
  let reports = Array::new(capacity=inputs.length())
  for input in inputs {
    reports.push(validation_report(input))
  }
  reports
}

///|
/// Counts valid Bech32 or Bech32m strings in a batch.
pub fn valid_count(inputs : Array[String]) -> Int {
  let mut count = 0
  for input in inputs {
    if is_valid(input) {
      count += 1
    }
  }
  count
}

///|
/// Counts invalid Bech32 or Bech32m strings in a batch.
pub fn invalid_count(inputs : Array[String]) -> Int {
  inputs.length() - valid_count(inputs)
}

///|
/// Returns true when every input in a batch is valid.
pub fn all_valid(inputs : Array[String]) -> Bool {
  valid_count(inputs) == inputs.length()
}

///|
/// Counts valid SegWit addresses in a batch.
pub fn segwit_valid_count(inputs : Array[String]) -> Int {
  let mut count = 0
  for input in inputs {
    if is_valid_segwit(input) {
      count += 1
    }
  }
  count
}

///|
/// Infers the common SegWit network from an HRP.
pub fn segwit_network(hrp : String) -> SegwitNetwork {
  let lower = hrp.to_lower()
  if lower == "bc" {
    NetworkBitcoinMainnet
  } else if lower == "tb" {
    NetworkBitcoinTestnet
  } else if lower == "bcrt" {
    NetworkBitcoinRegtest
  } else {
    NetworkUnknown(lower)
  }
}

///|
/// Returns true for standard Bitcoin SegWit HRPs: bc, tb, and bcrt.
pub fn is_standard_segwit_hrp(hrp : String) -> Bool {
  match segwit_network(hrp) {
    NetworkBitcoinMainnet => true
    NetworkBitcoinTestnet => true
    NetworkBitcoinRegtest => true
    NetworkUnknown(_) => false
  }
}

///|
/// Infers the SegWit network after full SegWit address validation.
pub fn segwit_network_of(input : String) -> Result[SegwitNetwork, Bech32Error] {
  match decode_segwit(input) {
    Err(err) => Err(err)
    Ok(address) => Ok(segwit_network(address.hrp))
  }
}

///|
/// Classifies a witness program by version and program length.
pub fn witness_program_kind(
  version : Int,
  program_length : Int,
) -> WitnessProgramKind {
  if version == 0 && program_length == 20 {
    WitnessProgramP2WPKH
  } else if version == 0 && program_length == 32 {
    WitnessProgramP2WSH
  } else if version == 1 && program_length == 32 {
    WitnessProgramTaproot
  } else {
    WitnessProgramOther
  }
}

///|
/// Inspects a valid SegWit address and returns network and witness metadata.
pub fn inspect_segwit(input : String) -> Result[SegwitInfo, Bech32Error] {
  match decode_segwit(input) {
    Err(err) => Err(err)
    Ok(address) => {
      let program_length = address.program.length()
      Ok({
        input,
        normalized: input.to_lower(),
        hrp: address.hrp,
        version: address.version,
        program: address.program,
        program_length,
        variant: address.variant,
        network: segwit_network(address.hrp),
        program_kind: witness_program_kind(address.version, program_length),
      })
    }
  }
}

///|
/// Decodes a SegWit address and additionally checks the expected network.
pub fn decode_segwit_on_network(
  input : String,
  expected : SegwitNetwork,
) -> Result[SegwitAddress, Bech32Error] {
  match decode_segwit(input) {
    Err(err) => Err(err)
    Ok(address) => {
      let actual = segwit_network(address.hrp)
      if actual == expected {
        Ok(address)
      } else {
        Err(UnexpectedNetwork(expected, actual))
      }
    }
  }
}

///|
/// Stable machine-readable code for every structured error.
pub fn error_code(err : Bech32Error) -> String {
  match err {
    EmptyInput => "empty_input"
    TooLong(_) => "too_long"
    MissingSeparator => "missing_separator"
    EmptyHrp => "empty_hrp"
    EmptyData => "empty_data"
    MixedCase => "mixed_case"
    InvalidHrpChar(_, _) => "invalid_hrp_char"
    InvalidDataChar(_, _) => "invalid_data_char"
    InvalidDataValue(_, _) => "invalid_data_value"
    InvalidChecksum => "invalid_checksum"
    InvalidBitGroup(_, _) => "invalid_bit_group"
    InvalidPadding => "invalid_padding"
    InvalidWitnessVersion(_) => "invalid_witness_version"
    InvalidWitnessProgramLength(_, _) => "invalid_witness_program_length"
    InvalidWitnessEncoding(_, _) => "invalid_witness_encoding"
    UnexpectedHrp(_, _) => "unexpected_hrp"
    UnexpectedNetwork(_, _) => "unexpected_network"
  }
}

///|
/// Human-readable message for every structured error.
pub fn error_message(err : Bech32Error) -> String {
  match err {
    EmptyInput => "input is empty"
    TooLong(_) => "input exceeds the Bech32 length limit"
    MissingSeparator => "separator '1' is missing"
    EmptyHrp => "human-readable part is empty"
    EmptyData => "data part is too short"
    MixedCase => "input mixes lowercase and uppercase letters"
    InvalidHrpChar(_, _) => "human-readable part contains an invalid character"
    InvalidDataChar(_, _) =>
      "data part contains a character outside the Bech32 charset"
    InvalidDataValue(_, _) => "data value is outside the allowed range"
    InvalidChecksum => "checksum does not match Bech32 or Bech32m"
    InvalidBitGroup(_, _) => "bit group width is outside the supported range"
    InvalidPadding => "bit conversion padding is not canonical"
    InvalidWitnessVersion(_) => "witness version must be between 0 and 16"
    InvalidWitnessProgramLength(_, _) =>
      "witness program length is invalid for this version"
    InvalidWitnessEncoding(_, _) =>
      "witness version uses the wrong checksum variant"
    UnexpectedHrp(_, _) => "decoded HRP does not match the expected HRP"
    UnexpectedNetwork(_, _) =>
      "decoded SegWit network does not match the expected network"
  }
}

///|
fn validate_hrp(hrp : String) -> Result[Unit, Bech32Error] {
  if hrp.is_empty() {
    return Err(EmptyHrp)
  }
  for i in 0..<hrp.length() {
    let ch = char_at(hrp, i)
    let code = ch.to_int()
    if code < 33 || code > 126 {
      return Err(InvalidHrpChar(ch, i))
    }
  }
  if has_mixed_case(hrp) {
    Err(MixedCase)
  } else {
    Ok(())
  }
}

///|
fn validate_data(data : Array[Int]) -> Result[Unit, Bech32Error] {
  for i, value in data.iter2() {
    if value < 0 || value > 31 {
      return Err(InvalidDataValue(value, i))
    }
  }
  Ok(())
}

///|
fn validate_octets(data : Array[Int]) -> Result[Unit, Bech32Error] {
  for i, value in data.iter2() {
    if value < 0 || value > 255 {
      return Err(InvalidDataValue(value, i))
    }
  }
  Ok(())
}

///|
fn validate_witness_program(
  version : Int,
  program : Array[Int],
) -> Result[Unit, Bech32Error] {
  if version < 0 || version > 16 {
    return Err(InvalidWitnessVersion(version))
  }
  match validate_octets(program) {
    Err(err) => return Err(err)
    Ok(_) => ()
  }
  let len = program.length()
  if len < 2 || len > 40 {
    return Err(InvalidWitnessProgramLength(version, len))
  }
  if version == 0 && !(len == 20 || len == 32) {
    return Err(InvalidWitnessProgramLength(version, len))
  }
  Ok(())
}

///|
fn witness_variant(version : Int) -> Variant {
  if version == 0 {
    Bech32
  } else {
    Bech32m
  }
}

///|
fn has_mixed_case(input : String) -> Bool {
  classify_case(input) == CaseMixed
}

///|
fn last_separator(input : String) -> Int {
  let mut sep = -1
  for i in 0..<input.length() {
    if char_at(input, i) == '1' {
      sep = i
    }
  }
  sep
}

///|
fn charset_value(ch : Char) -> Int? {
  for i in 0..<CHARSET.length() {
    if char_at(CHARSET, i) == ch {
      return Some(i)
    }
  }
  None
}

///|
fn expand_hrp(hrp : String) -> Array[Int] {
  let out = Array::new(capacity=hrp.length() * 2 + 1)
  for ch in hrp {
    out.push(ch.to_int() >> 5)
  }
  out.push(0)
  for ch in hrp {
    out.push(ch.to_int() & 31)
  }
  out
}

///|
fn polymod(values : Array[Int]) -> Int {
  let generators = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
  let mut chk = 1
  for value in values {
    let top = chk >> 25
    chk = ((chk & 0x1ffffff) << 5) ^ value
    for i in 0..<5 {
      if ((top >> i) & 1) == 1 {
        chk = chk ^ generators[i]
      }
    }
  }
  chk
}

///|
fn create_checksum(
  hrp : String,
  data : Array[Int],
  variant : Variant,
) -> Array[Int] {
  let values = expand_hrp(hrp) + data
  for _ in 0..<6 {
    values.push(0)
  }
  let constant = match variant {
    Bech32 => BECH32_CONST
    Bech32m => BECH32M_CONST
  }
  let pm = polymod(values) ^ constant
  Array::makei(6, i => (pm >> (5 * (5 - i))) & 31)
}

///|
fn checksum_words_from_normalized(input : String) -> Array[Int] {
  let checksum = Array::new(capacity=6)
  for i in (input.length() - 6)..<input.length() {
    checksum.push(charset_value(char_at(input, i)).unwrap())
  }
  checksum
}

///|
fn char_at(input : String, offset : Int) -> Char {
  input.get_char(offset).unwrap()
}
