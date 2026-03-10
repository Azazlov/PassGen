/// Версия алгоритма шифрования
///
/// Используется для обратной совместимости при обновлении алгоритмов
class EncryptionVersion {
  /// Текущая версия
  static const int currentVersion = 1;

  /// Минимальная поддерживаемая версия
  static const int minSupportedVersion = 1;

  /// Версия 1: ChaCha20-Poly1305 + PBKDF2 (10000 итераций)
  static const int v1 = 1;

  /// Версия 2: ChaCha20-Poly1305 + PBKDF2 (20000 итераций) - перспектива
  static const int v2 = 2;

  /// Версия 3: Argon2id + ChaCha20-Poly1305 - перспектива
  static const int v3 = 3;

  final int version;

  const EncryptionVersion(this.version);

  /// Проверяет, поддерживается ли версия
  static bool isSupported(int version) {
    return version >= minSupportedVersion && version <= currentVersion;
  }

  /// Получает параметры для версии
  static EncryptionParams getParamsForVersion(int version) {
    switch (version) {
      case v1:
        return EncryptionParams.v1();
      case v2:
        return EncryptionParams.v2();
      case v3:
        return EncryptionParams.v3();
      default:
        throw UnsupportedError('Unsupported encryption version: $version');
    }
  }

  /// Получает параметры текущей версии
  static EncryptionParams getCurrentParams() {
    return getParamsForVersion(currentVersion);
  }

  @override
  String toString() => 'EncryptionVersion.v$version';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptionVersion && other.version == version;

  @override
  int get hashCode => version.hashCode;
}

/// Параметры шифрования для версии
class EncryptionParams {
  /// Алгоритм шифрования
  final String algorithm;

  /// Алгоритм деривации ключа
  final String kdf;

  /// Количество итераций KDF
  final int iterations;

  /// Длина ключа (биты)
  final int keyLength;

  /// Длина nonce (байты)
  final int nonceLength;

  /// Длина соли (байты)
  final int saltLength;

  /// Длина MAC (байты)
  final int macLength;

  const EncryptionParams({
    required this.algorithm,
    required this.kdf,
    required this.iterations,
    required this.keyLength,
    required this.nonceLength,
    required this.saltLength,
    required this.macLength,
  });

  /// Параметры версии 1
  factory EncryptionParams.v1() {
    return const EncryptionParams(
      algorithm: 'ChaCha20-Poly1305',
      kdf: 'PBKDF2-HMAC-SHA256',
      iterations: 10000,
      keyLength: 256,
      nonceLength: 32,
      saltLength: 32,
      macLength: 16,
    );
  }

  /// Параметры версии 2 (перспектива)
  factory EncryptionParams.v2() {
    return const EncryptionParams(
      algorithm: 'ChaCha20-Poly1305',
      kdf: 'PBKDF2-HMAC-SHA256',
      iterations: 20000,
      keyLength: 256,
      nonceLength: 32,
      saltLength: 32,
      macLength: 16,
    );
  }

  /// Параметры версии 3 (перспектива, Argon2)
  factory EncryptionParams.v3() {
    return const EncryptionParams(
      algorithm: 'ChaCha20-Poly1305',
      kdf: 'Argon2id',
      iterations: 3,
      keyLength: 256,
      nonceLength: 32,
      saltLength: 32,
      macLength: 16,
    );
  }

  /// Сравнивает параметры с другими
  bool isCompatibleWith(EncryptionParams other) {
    // Совместимость по алгоритму шифрования
    return algorithm == other.algorithm;
  }

  @override
  String toString() {
    return 'EncryptionParams($algorithm, $kdf, $iterations итераций, $keyLength бит)';
  }
}

/// Метаданные шифрования для файла/записи
class EncryptionMetadata {
  /// Версия алгоритма
  final int version;

  /// Timestamp создания
  final DateTime timestamp;

  /// Идентификатор ключа (для ротации)
  final String? keyId;

  /// Дополнительные флаги
  final Map<String, dynamic> extra;

  const EncryptionMetadata({
    required this.version,
    required this.timestamp,
    this.keyId,
    this.extra = const {},
  });

  /// Создаёт метаданные для текущей версии
  factory EncryptionMetadata.current({String? keyId}) {
    return EncryptionMetadata(
      version: EncryptionVersion.currentVersion,
      timestamp: DateTime.now(),
      keyId: keyId,
    );
  }

  /// Проверяет совместимость версии
  bool get isCompatible => EncryptionVersion.isSupported(version);

  /// Получает параметры для этой версии
  EncryptionParams get params => EncryptionVersion.getParamsForVersion(version);

  /// Сериализует в JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'keyId': keyId,
      if (extra.isNotEmpty) 'extra': extra,
    };
  }

  /// Десериализует из JSON
  factory EncryptionMetadata.fromJson(Map<String, dynamic> json) {
    return EncryptionMetadata(
      version: json['version'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      keyId: json['keyId'] as String?,
      extra: json['extra'] != null
          ? Map<String, dynamic>.from(json['extra'])
          : {},
    );
  }

  @override
  String toString() {
    return 'EncryptionMetadata(v$version, ${params.algorithm}, keyId: $keyId)';
  }
}
