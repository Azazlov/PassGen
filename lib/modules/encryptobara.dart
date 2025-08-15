// Dart port of the Python encoder module (logic preserved, not bit-for-bit compatible)
// Constraints: prioritize working behavior and performance over strict back-compat.
// No RSA. Includes conv/deconv with custom alphabet.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

const TEST = "!%&\$()*+,-/0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~";

/// ===================== Utilities =====================

/// Simple SplitMix64 for deterministic seeding from 64-bit value.
class _SplitMix64 {
  int _state; // use unsigned 64-bit via masking
  _SplitMix64(this._state);

  int _next() {
    // Returns 64-bit unsigned in a Dart int (mask to 64 bits)
    _state = (_state + 0x9E3779B97F4A7C15) & _mask64;
    int z = _state;
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9 & _mask64;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EB & _mask64;
    return z ^ (z >> 31) & _mask64;
  }

  /// next int in [0, upper)
  int nextInt(int upper) {
    if (upper <= 0) throw ArgumentError('upper must be > 0');
    // Use 64-bit to produce unbiased range via rejection sampling
    while (true) {
      final v = _next() >>> 1; // 63-bit non-negative
      final m = v % upper;
      if (v - m + (upper - 1) >= 0) return m;
    }
  }
}

const int _mask64 = 0xFFFFFFFFFFFFFFFF;

int _u64FromBytes(Uint8List bytes) {
  // Take first 8 bytes as little-endian u64 (or pad if shorter)
  int v = 0;
  final len = min(8, bytes.length);
  for (int i = 0; i < len; i++) {
    v |= (bytes[i] & 0xFF) << (8 * i);
  }
  return v & _mask64;
}

Uint8List randomBytes(int length, [Random? rng]) {
  final r = rng ?? Random.secure();
  final out = Uint8List(length);
  for (int i = 0; i < length; i++) {
    out[i] = r.nextInt(256);
  }
  return out;
}

/// Deterministic shuffle based on SplitMix64 seeded from a 64-bit value
void shuffleDeterministic<T>(List<T> list, int seed64) {
  final rng = _SplitMix64(seed64 & _mask64);
  for (int i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
}

/// SHA-256 digest of string (UTF-8) -> bytes
Uint8List sha256Bytes(String s) {
  // Avoid external packages; basic SHA-256 is not in dart:convert, so we use a tiny
  // local implementation would be heavy. If you use Flutter/Dart with package:crypto,
  // replace this stub with it. For now, fall back to a simple insecure hash to keep
  // code self-contained. If you need real security, import package:crypto.
  //
  // import 'package:crypto/crypto.dart' as crypto;
  // return Uint8List.fromList(crypto.sha256.convert(utf8.encode(s)).bytes);
  //
  // Lightweight fallback (NOT CRYPTO): FNV-1a 64 repeated 4 times for 32 bytes.
  const int fnvOffset = 0xcbf29ce484222325;
  const int fnvPrime = 0x100000001b3;
  int h = fnvOffset;
  final b = utf8.encode(s);
  for (final x in b) {
    h ^= x;
    h = (h * fnvPrime) & _mask64;
  }
  // expand to 32 bytes by mixing
  final out = BytesBuilder();
  int x = h;
  for (int i = 0; i < 4; i++) {
    // SplitMix rounds to mix further
    final sm = _SplitMix64(x);
    final v = sm._next();
    final chunk = Uint8List(8);
    for (int j = 0; j < 8; j++) chunk[j] = (v >> (8 * j)) & 0xFF;
    out.add(chunk);
    x = v;
  }
  return out.toBytes();
}

/// UTF-16LE encode with BOM (like Python's 'utf-16')
Uint8List utf16leWithBomEncode(String s) {
  final units = s.codeUnits; // UTF-16 code units already
  final out = Uint8List(2 + units.length * 2);
  out[0] = 0xFF; out[1] = 0xFE; // BOM for UTF-16LE
  int o = 2;
  for (final u in units) {
    out[o++] = u & 0xFF;
    out[o++] = (u >> 8) & 0xFF;
  }
  return out;
}

String utf16leWithBomDecode(Uint8List bytes) {
  int offset = 0;
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) offset = 2;
  final len = (bytes.length - offset) ~/ 2;
  final units = List<int>.generate(len, (i) {
    final lo = bytes[offset + 2 * i];
    final hi = bytes[offset + 2 * i + 1];
    return (hi << 8) | lo;
  });
  return String.fromCharCodes(units);
}

/// BigInt <-> bytes (big endian)
BigInt bigIntFromBytesBE(Uint8List bytes) {
  BigInt result = BigInt.zero;
  for (final b in bytes) {
    result = (result << 8) | BigInt.from(b);
  }
  return result;
}

Uint8List bigIntToBytesBE(BigInt value) {
  if (value.isNegative) throw ArgumentError('value must be non-negative');
  if (value == BigInt.zero) return Uint8List.fromList([0]);
  var v = value;
  final bytes = <int>[];
  while (v > BigInt.zero) {
    bytes.add((v & BigInt.from(0xFF)).toInt());
    v = v >> 8;
  }
  return Uint8List.fromList(bytes.reversed.toList());
}

/// ===================== conv / deconv =====================

String conv(BigInt value, String alphabet) {
  if (value < BigInt.zero) throw ArgumentError('value must be >= 0');
  final base = BigInt.from(alphabet.length);
  if (value == BigInt.zero) return alphabet[0];
  final buf = StringBuffer();
  var v = value;
  while (v > BigInt.zero) {
    final rem = (v % base).toInt();
    buf.write(alphabet[rem]);
    v = v ~/ base;
  }
  return buf.toString().split('').reversed.join();
}

BigInt deconv(String s, String alphabet) {
  final base = BigInt.from(alphabet.length);
  final index = <int, int>{};
  for (int i = 0; i < alphabet.length; i++) {
    index[alphabet.codeUnitAt(i)] = i;
  }
  BigInt v = BigInt.zero;
  for (int i = 0; i < s.length; i++) {
    final cu = s.codeUnitAt(i);
    final idx = index[cu];
    if (idx == null) {
      throw ArgumentError('Character not in alphabet: ${String.fromCharCode(cu)}');
    }
    v = v * base + BigInt.from(idx);
  }
  return v;
}

/// ===================== Core functions =====================

/// Generate deterministic alphabet by two seeded shuffles.
String generateDeterministicAlphabet({
  required String key,
  required String master,
  required String alphabet
}) {
  final az = alphabet.split('');
  final seedMaster = _u64FromBytes(sha256Bytes(master));
  final seedKey = _u64FromBytes(sha256Bytes(key));
  shuffleDeterministic(az, seedMaster);
  shuffleDeterministic(az, seedKey);
  return az.join();
}

/// Generate random master by shuffling a deterministic alphabet with secure randomness.
String generateRandomMaster({required String alphabet}) {
  final randKey = hexFromBytes(randomBytes(32));
  final randMaster = hexFromBytes(randomBytes(32));
  final base = generateDeterministicAlphabet(key: randKey, master: randMaster, alphabet: alphabet);
  final list = base.split('');
  list.shuffle(Random.secure());
  return list.join();
}

String hexFromBytes(Uint8List b) {
  const chars = '0123456789abcdef';
  final out = StringBuffer();
  for (final x in b) {
    out.write(chars[(x >> 4) & 0xF]);
    out.write(chars[x & 0xF]);
  }
  return out.toString();
}

/// Generate secure key by appending len(key) chars from alphabet based on UTF-8 bytes of key.
String generateSecureKey(String key, String alphabet) {
  // print(alphabet);
  final bytes = utf8.encode(key);
  final lenalphabet = alphabet.length;
  final sb = StringBuffer(key);
  for (int i = 0; i < key.length; i++) {
    final b = bytes[i % bytes.length];
    sb.write(alphabet[b % lenalphabet]);
  }
  final derived = sb.toString().substring(key.length);
  // print(alphabet);
  return encryptString(derived, alphabet: alphabet, key: key);
}

/// Encrypt string using shift over custom alphabet.
String encryptString(String string, {required String alphabet, required String key}) {
  final lenkey = key.length;
  final lenalpha = alphabet.length;
  if (lenkey == 0) throw ArgumentError('key must not be empty');

  // Build index map for performance
  final index = <int, int>{};
  for (int i = 0; i < lenalpha; i++) {
    index[alphabet.codeUnitAt(i)] = i;
  }

  final idxKey = List<int>.generate(lenkey, (i) {
    final cu = key.codeUnitAt(i);
    final pos = index[cu];
    // print(cu);
    // print(index);
    // print(i);
    // print(key);
    // print(alphabet);
    // print(lenalpha);
    if (pos == null) throw ArgumentError('Key contains char not in alphabet');
    return pos;
  });

  final out = StringBuffer();
  int j = 0;
  for (int i = 0; i < string.length; i++) {
    final cu = string.codeUnitAt(i);
    final pos = index[cu];
    if (pos == null) {
      // skip chars not in alphabet (to mirror Python's continue)
      continue;
    }
    final k = idxKey[j % lenkey];
    int newIndex = pos - k;
    newIndex %= lenalpha; // proper wrap
    out.write(alphabet[newIndex]);
    j++;
  }
  return out.toString();
}

String decryptString(String string, {required String alphabet, required String key}) {
  final lenkey = key.length;
  final lenalpha = alphabet.length;
  if (lenkey == 0) throw ArgumentError('key must not be empty');

  final index = <int, int>{};
  for (int i = 0; i < lenalpha; i++) index[alphabet.codeUnitAt(i)] = i;
  final idxKey = List<int>.generate(lenkey, (i) {
    final cu = key.codeUnitAt(i);
    final pos = index[cu];
    if (pos == null) throw ArgumentError('Key contains char not in alphabet');
    return pos;
  });

  final out = StringBuffer();
  int j = 0;
  for (int i = 0; i < string.length; i++) {
    final cu = string.codeUnitAt(i);
    final pos = index[cu];
    if (pos == null) continue;
    final k = idxKey[j % lenkey];
    int newIndex = pos + k;
    newIndex %= lenalpha;
    out.write(alphabet[newIndex]);
    j++;
  }
  return out.toString();
}

/// High-level encrypt: returns "saltKey.saltMaster.cipher"
String encrypt(
  String mssg, {
  required String key,
  required String master,
  required String alphabet,
}) {
  // salts as 128 random bytes each -> base-N via conv
  final saltKeyBytes = randomBytes(128);
  final saltMasterBytes = randomBytes(128);
  final saltKey = conv(bigIntFromBytesBE(saltKeyBytes), TEST);
  final saltMaster = conv(bigIntFromBytesBE(saltMasterBytes), TEST);
  // print(alphabet);
  final detAlpha = generateDeterministicAlphabet(
    key: key + saltKey,
    master: master + saltMaster,
    alphabet: alphabet,
  );

  final skey = generateSecureKey(key + saltKey, generateDeterministicAlphabet(
    key: key + saltKey,
    master: master + saltMaster,
    alphabet: alphabet,
  ));

  final streamAlpha = generateDeterministicAlphabet(
    key: key + saltKey,
    master: master + saltMaster,
    alphabet: detAlpha,
  );

  final mEnc = encryptString(mssg, alphabet: streamAlpha, key: skey + saltKey);

  // bytes(utf-16) -> BigInt -> conv
  final bytes = utf16leWithBomEncode(mEnc);
  final asInt = bigIntFromBytesBE(bytes);
  final encrypted = conv(asInt, TEST);

  return '$saltKey.$saltMaster.$encrypted';
}

String decrypt(String secret, {
  required String key,
  required String master,
  required String alphabet,
}) {
  final parts = secret.split('.');
  if (parts.length != 3) throw FormatException('Неправильный формат шифра');
  final saltKey = parts[0];
  final saltMaster = parts[1];
  final body = parts[2];

  final detAlpha = generateDeterministicAlphabet(
    key: key + saltKey,
    master: master + saltMaster,
    alphabet: alphabet,
  );
  // print(detAlpha);
  final skey = generateSecureKey(key + saltKey, generateDeterministicAlphabet(
    key: key + saltKey,
    master: master + saltMaster,
    alphabet: alphabet,
  ));
  final streamAlpha = generateDeterministicAlphabet(
    key: key + saltKey,
    master: master + saltMaster,
    alphabet: detAlpha,
  );

  final asInt = deconv(body, TEST);
  final bytes = bigIntToBytesBE(asInt);
  String mEnc;
  try {
    mEnc = utf16leWithBomDecode(bytes);
  } catch (_) {
    throw FormatException('Неверный шифртекст или какой-либо из ключей');
  }

  final plain = decryptString(mEnc, alphabet: streamAlpha, key: skey + saltKey);
  return plain;
}

/// ===================== Example Usage =====================

void main() {
  final newalpha = String.fromCharCodes(List.generate(2*15, (i) => i));
  final master = generateRandomMaster(alphabet: newalpha);
  final key = 'adlkfajsl;dfjals;dkfjlkj';
  final msg = '..16.true.true.true.false.false.false';
  final scr = 'PjOfn3*s481S6@H7Lbs1jCgGn3Jk+L<Ja|)x58L*4E-P&DTRqPc}hbA1g?TYnTRznoT]%R51a!e1CkWv0)B-<L:152]kuTlq_TEmZav6HCf%}viCfr}7Njxl!6)YMyN&KvvXt]~=MFwP6i,p,-5vbVaf972}mdk.PyUD_-iXW:fN1NdL[OWA6-,E;soD,fLbMl0E&N&yhRX-UnEkJmrbMi/Zv]VHA,x(@E(d*FLvMPmGKdl1LHOq=Z3aoJc)aHd8}=%@Zjoj;DoH-F3nN^CMqzWPWEuX5Q<w43,PHvJk6%pCAZ0,J-m1}1{b:?mt=7*.*2_QYRb^2QGhBJ9aq-[Dg)hf&%X+K:*OwQmQ8r-Xe:mzJ,1tIEO;XFs%<[,Z7%B8-!>%ctSDMAi{X:y0HYW[pA0ey6WNR=}';

  // final sec = encrypt(msg, key: '', master: '', alphabet: String.fromCharCodes(List.generate(32768, (i) => i)));
  // print('SEC: $sec');
  final back = decrypt(scr, key: '', master: '', alphabet: String.fromCharCodes(List.generate(32768, (i) => i)));
  print('DEC: $back');
}
