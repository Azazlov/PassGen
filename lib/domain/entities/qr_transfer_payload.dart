/// Payload для QR-передачи пароля
class QrTransferPayload {
  const QrTransferPayload({
    required this.version,
    required this.nonce,
    required this.saltBase64,
    required this.iterations,
    required this.ciphertextBase64,
    required this.macBase64,
    required this.createdAt,
    required this.expirySeconds,
  });

  final String version;          // '1'
  final String nonce;            // base64url(12 байт)
  final String saltBase64;       // base64url(16 байт)
  final int iterations;          // PBKDF2 итерации
  final String ciphertextBase64; // base64url
  final String macBase64;        // base64url
  final int createdAt;           // unix ms
  final int expirySeconds;       // TTL

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch - createdAt > expirySeconds * 1000;

  Map<String, dynamic> toJson() {
    return {
      'v': version,
      'n': nonce,
      's': saltBase64,
      'i': iterations,
      'c': ciphertextBase64,
      'm': macBase64,
      't': createdAt,
      'e': expirySeconds,
    };
  }

  factory QrTransferPayload.fromJson(Map<String, dynamic> json) {
    return QrTransferPayload(
      version: json['v'] as String,
      nonce: json['n'] as String,
      saltBase64: json['s'] as String,
      iterations: json['i'] as int,
      ciphertextBase64: json['c'] as String,
      macBase64: json['m'] as String,
      createdAt: json['t'] as int,
      expirySeconds: json['e'] as int,
    );
  }

  String toBase64Url() {
    // Compact serialization: v|n|s|i|c|m|t|e
    final parts = [
      version,
      nonce,
      saltBase64,
      iterations.toString(),
      ciphertextBase64,
      macBase64,
      createdAt.toString(),
      expirySeconds.toString(),
    ];
    // Use base64url for each part separated by '.'
    return parts.join('.');
  }

  factory QrTransferPayload.fromBase64Url(String data) {
    final parts = data.split('.');
    if (parts.length != 8) {
      throw FormatException('Invalid QR payload format');
    }
    return QrTransferPayload(
      version: parts[0],
      nonce: parts[1],
      saltBase64: parts[2],
      iterations: int.parse(parts[3]),
      ciphertextBase64: parts[4],
      macBase64: parts[5],
      createdAt: int.parse(parts[6]),
      expirySeconds: int.parse(parts[7]),
    );
  }
}
