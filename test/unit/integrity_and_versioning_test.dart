import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/core/utils/integrity_checker.dart';
import 'package:pass_gen/core/utils/encryption_versioning.dart';

void main() {
  group('IntegrityChecker Tests', () {
    late IntegrityChecker checker;

    setUp(() {
      checker = IntegrityChecker();
    });

    // ==================== CHECKSUM TESTS ====================

    group('Checksum Tests', () {
      test('computeAppChecksum возвращает не пустую строку', () async {
        final checksum = await checker.computeAppChecksum();

        expect(checksum.isNotEmpty, isTrue);
        expect(checksum.length, greaterThan(0));
      });

      test('computeAppChecksum возвращает Base64 строку', () async {
        final checksum = await checker.computeAppChecksum();

        // Base64 содержит только A-Z, a-z, 0-9, +, /, =
        final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
        expect(base64Regex.hasMatch(checksum), isTrue);
      });

      test('verifyChecksum без stored checksum возвращает valid', () async {
        final result = await checker.verifyChecksum();

        expect(result.isValid, isTrue);
        expect(result.checkType, equals(CheckType.checksum));
      });

      test('verifyChecksum с правильным checksum возвращает valid', () async {
        final computed = await checker.computeAppChecksum();
        final result = await checker.verifyChecksum(expectedChecksum: computed);

        expect(result.isValid, isTrue);
      });

      test('verifyChecksum с неправильным checksum возвращает invalid', () async {
        final result = await checker.verifyChecksum(
          expectedChecksum: 'invalid_checksum',
        );

        expect(result.isValid, isFalse);
        expect(result.checkType, equals(CheckType.checksum));
        expect(result.errorMessage, contains('Checksum mismatch'));
      });
    });

    // ==================== TAMPERING TESTS ====================

    group('Tampering Tests', () {
      test('verifyTampering возвращает valid в normal условиях', () async {
        final result = await checker.verifyTampering();

        // В условиях разработки должно быть valid
        expect(result.isValid, isTrue);
        expect(result.checkType, equals(CheckType.tampering));
      });

      test('fullIntegrityCheck возвращает список результатов', () async {
        final results = await checker.fullIntegrityCheck();

        expect(results.length, greaterThan(0));
        expect(results.every((r) => r is IntegrityResult), isTrue);
      });

      test('isIntegrityValid возвращает bool', () async {
        final isValid = await checker.isIntegrityValid();

        expect(isValid, isA<bool>());
      });
    });

    // ==================== UTILITY TESTS ====================

    group('Utility Tests', () {
      test('resetStoredChecksum выполняется без ошибок', () async {
        expect(
          () => IntegrityChecker.resetStoredChecksum(),
          returnsNormally,
        );
      });

      test('getIntegrityInfo возвращает null если нет данных', () async {
        final info = await IntegrityChecker.getIntegrityInfo();

        // Может быть null если файл не создан
        expect(info, isNull);
      });
    });
  });

  group('EncryptionVersioning Tests', () {
    // ==================== VERSION TESTS ====================

    group('EncryptionVersion Tests', () {
      test('currentVersion равен 1', () {
        expect(EncryptionVersion.currentVersion, equals(1));
      });

      test('minSupportedVersion равен 1', () {
        expect(EncryptionVersion.minSupportedVersion, equals(1));
      });

      test('v1 константа определена', () {
        expect(EncryptionVersion.v1, equals(1));
      });

      test('v2 константа определена', () {
        expect(EncryptionVersion.v2, equals(2));
      });

      test('v3 константа определена', () {
        expect(EncryptionVersion.v3, equals(3));
      });

      test('isSupported возвращает true для текущей версии', () {
        expect(
          EncryptionVersion.isSupported(EncryptionVersion.currentVersion),
          isTrue,
        );
      });

      test('isSupported возвращает true для v1', () {
        expect(EncryptionVersion.isSupported(1), isTrue);
      });

      test('isSupported возвращает false для неподдерживаемой версии', () {
        expect(EncryptionVersion.isSupported(0), isFalse);
        expect(EncryptionVersion.isSupported(99), isFalse);
      });

      test('getParamsForVersion возвращает параметры для v1', () {
        final params = EncryptionVersion.getParamsForVersion(1);

        expect(params.algorithm, equals('ChaCha20-Poly1305'));
        expect(params.kdf, equals('PBKDF2-HMAC-SHA256'));
        expect(params.iterations, equals(10000));
        expect(params.keyLength, equals(256));
      });

      test('getParamsForVersion для v2 возвращает увеличенные итерации', () {
        final params = EncryptionVersion.getParamsForVersion(2);

        expect(params.iterations, equals(20000));
      });

      test('getParamsForVersion для v3 возвращает Argon2', () {
        final params = EncryptionVersion.getParamsForVersion(3);

        expect(params.kdf, equals('Argon2id'));
      });

      test('getParamsForVersion для неизвестной версии выбрасывает исключение', () {
        expect(
          () => EncryptionVersion.getParamsForVersion(99),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('getCurrentParams возвращает параметры текущей версии', () {
        final params = EncryptionVersion.getCurrentParams();
        final currentParams = EncryptionVersion.getParamsForVersion(
          EncryptionVersion.currentVersion,
        );

        expect(params.algorithm, equals(currentParams.algorithm));
        expect(params.iterations, equals(currentParams.iterations));
      });
    });

    // ==================== ENCRYPTION PARAMS TESTS ====================

    group('EncryptionParams Tests', () {
      test('v1 параметры корректны', () {
        final params = EncryptionParams.v1();

        expect(params.algorithm, equals('ChaCha20-Poly1305'));
        expect(params.kdf, equals('PBKDF2-HMAC-SHA256'));
        expect(params.iterations, equals(10000));
        expect(params.keyLength, equals(256));
        expect(params.nonceLength, equals(32));
        expect(params.saltLength, equals(32));
        expect(params.macLength, equals(16));
      });

      test('v2 параметры имеют увеличенные итерации', () {
        final params = EncryptionParams.v2();

        expect(params.iterations, equals(20000));
      });

      test('v3 параметры используют Argon2', () {
        final params = EncryptionParams.v3();

        expect(params.kdf, equals('Argon2id'));
        expect(params.iterations, equals(3));
      });

      test('isCompatibleWith возвращает true для одинаковых алгоритмов', () {
        final params1 = EncryptionParams.v1();
        final params2 = EncryptionParams.v2();

        expect(params1.isCompatibleWith(params2), isTrue);
      });

      test('toString возвращает читаемое представление', () {
        final params = EncryptionParams.v1();
        final str = params.toString();

        expect(str.contains('ChaCha20-Poly1305'), isTrue);
        expect(str.contains('10000'), isTrue);
      });
    });

    // ==================== ENCRYPTION METADATA TESTS ====================

    group('EncryptionMetadata Tests', () {
      test('current factory создаёт метаданные с текущей версией', () {
        final metadata = EncryptionMetadata.current();

        expect(metadata.version, equals(EncryptionVersion.currentVersion));
        expect(metadata.timestamp, isA<DateTime>());
      });

      test('current factory с keyId создаёт метаданные с keyId', () {
        final metadata = EncryptionMetadata.current(keyId: 'test-key-123');

        expect(metadata.keyId, equals('test-key-123'));
      });

      test('isCompatible возвращает true для поддерживаемой версии', () {
        final metadata = EncryptionMetadata.current();

        expect(metadata.isCompatible, isTrue);
      });

      test('isCompatible возвращает false для неподдерживаемой версии', () {
        final metadata = EncryptionMetadata(
          version: 99,
          timestamp: DateTime.now(),
        );

        expect(metadata.isCompatible, isFalse);
      });

      test('params возвращает параметры для версии', () {
        final metadata = EncryptionMetadata.current();
        final params = metadata.params;

        expect(params.iterations, equals(10000));
      });

      test('toJson сериализует метаданные', () {
        final metadata = EncryptionMetadata.current(keyId: 'test-key');
        final json = metadata.toJson();

        expect(json['version'], equals(metadata.version));
        expect(json['timestamp'], isA<String>());
        expect(json['keyId'], equals('test-key'));
      });

      test('fromJson десериализует метаданные', () {
        final json = {
          'version': 1,
          'timestamp': '2026-03-09T12:00:00.000Z',
          'keyId': 'test-key',
        };

        final metadata = EncryptionMetadata.fromJson(json);

        expect(metadata.version, equals(1));
        expect(metadata.keyId, equals('test-key'));
        expect(metadata.timestamp.year, equals(2026));
      });

      test('fromJson с extra полями', () {
        final json = {
          'version': 1,
          'timestamp': '2026-03-09T12:00:00.000Z',
          'extra': {'custom': 'value'},
        };

        final metadata = EncryptionMetadata.fromJson(json);

        expect(metadata.extra['custom'], equals('value'));
      });

      test('toString возвращает читаемое представление', () {
        final metadata = EncryptionMetadata.current();
        final str = metadata.toString();

        expect(str.contains('v1'), isTrue);
        expect(str.contains('ChaCha20-Poly1305'), isTrue);
      });
    });

    // ==================== INTEGRATION TESTS ====================

    group('Integration Tests', () {
      test('Полный цикл сериализации/десериализации метаданных', () {
        final original = EncryptionMetadata.current(keyId: 'integration-test');
        final json = original.toJson();
        final restored = EncryptionMetadata.fromJson(json);

        expect(restored.version, equals(original.version));
        expect(restored.keyId, equals(original.keyId));
        expect(
          restored.timestamp.millisecondsSinceEpoch,
          closeTo(original.timestamp.millisecondsSinceEpoch, 1000),
        );
      });

      test('Совместимость версий и параметров', () {
        for (int version = 1; version <= 3; version++) {
          if (!EncryptionVersion.isSupported(version)) continue;

          final params = EncryptionVersion.getParamsForVersion(version);
          final metadata = EncryptionMetadata(
            version: version,
            timestamp: DateTime.now(),
          );

          expect(metadata.params.algorithm, equals(params.algorithm));
          expect(metadata.isCompatible, isTrue);
        }
      });
    });
  });
}
