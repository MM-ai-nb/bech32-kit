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
  let mut has_lower = false
  let mut has_upper = false
  for ch in input {
    if ch.is_ascii_lowercase() {
      has_lower = true
    } else if ch.is_ascii_uppercase() {
      has_upper = true
    }
  }
  has_lower && has_upper
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
fn char_at(input : String, offset : Int) -> Char {
  input.get_char(offset).unwrap()
}
