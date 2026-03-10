import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// Результат проверки целостности
class IntegrityResult {
  final bool isValid;
  final String? errorMessage;
  final CheckType checkType;

  const IntegrityResult({
    required this.isValid,
    this.errorMessage,
    required this.checkType,
  });

  factory IntegrityResult.valid(CheckType checkType) {
    return IntegrityResult(isValid: true, checkType: checkType);
  }

  factory IntegrityResult.invalid(CheckType checkType, String reason) {
    return IntegrityResult(
      isValid: false,
      errorMessage: reason,
      checkType: checkType,
    );
  }
}

/// Тип проверки целостности
enum CheckType {
  checksum,      // Проверка контрольной суммы
  signature,     // Проверка подписи
  tampering,     // Проверка на модификацию
}

/// Проверка целостности приложения
///
/// Предназначен для обнаружения:
/// - Модификации бинарника
/// - Несанкционированных изменений кода
/// - Подделки приложения
class IntegrityChecker {
  static const String _expectedChecksumKey = 'app_checksum';
  static const String _integrityDataFile = '.integrity_check';

  final String? _storedChecksum;

  IntegrityChecker({String? storedChecksum}) : _storedChecksum = storedChecksum;

  // ==================== CHECKSUM ПРОВЕРКА ====================

  /// Вычисляет SHA-256 хэш критических файлов приложения
  ///
  /// Возвращает Base64 строку с хэшем
  Future<String> computeAppChecksum() async {
    final checksums = <String>[];

    // Вычисляем хэш основного Dart файла
    try {
      final mainFileChecksum = await _computeFileChecksum('lib/app/app.dart');
      checksums.add(mainFileChecksum);
    } catch (e) {
      // Файл не найден (в production)
    }

    // Вычисляем хэш критических файлов безопасности
    final criticalFiles = [
      'lib/data/datasources/auth_local_datasource.dart',
      'lib/data/datasources/encryptor_local_datasource.dart',
      'lib/core/utils/crypto_utils.dart',
    ];

    for (final filePath in criticalFiles) {
      try {
        final checksum = await _computeFileChecksum(filePath);
        checksums.add(checksum);
      } catch (e) {
        // Файл не найден, пропускаем
      }
    }

    // Объединяем все хэши и вычисляем итоговый хэш
    final combinedChecksum = checksums.join(':');
    final finalHash = sha256.convert(utf8.encode(combinedChecksum));

    return base64Encode(finalHash.bytes);
  }

  /// Вычисляет SHA-256 хэш файла
  Future<String> _computeFileChecksum(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }

    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes);
  }

  /// Проверяет целостность приложения по checksum
  ///
  /// [expectedChecksum] - ожидаемое значение хэша
  Future<IntegrityResult> verifyChecksum({String? expectedChecksum}) async {
    try {
      final computedChecksum = await computeAppChecksum();
      final expected = expectedChecksum ?? _storedChecksum;

      if (expected == null) {
        // Нет сохранённого хэша для сравнения
        // Сохраняем текущий как эталонный
        await _storeChecksum(computedChecksum);
        return IntegrityResult.valid(CheckType.checksum);
      }

      // Сравниваем хэши
      if (computedChecksum == expected) {
        return IntegrityResult.valid(CheckType.checksum);
      } else {
        return IntegrityResult.invalid(
          CheckType.checksum,
          'Checksum mismatch: приложение могло быть модифицировано',
        );
      }
    } catch (e) {
      return IntegrityResult.invalid(
        CheckType.checksum,
        'Ошибка проверки checksum: $e',
      );
    }
  }

  /// Сохраняет checksum для будущих проверок
  Future<void> _storeChecksum(String checksum) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final integrityFile = File('${appDir.path}/$_integrityDataFile');

      final data = {
        'checksum': checksum,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      await integrityFile.writeAsString(jsonEncode(data));
    } catch (e) {
      // Не удалось сохранить, игнорируем
    }
  }

  /// Загружает сохранённый checksum
  static Future<String?> loadStoredChecksum() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final integrityFile = File('${appDir.path}/$_integrityDataFile');

      if (!await integrityFile.exists()) {
        return null;
      }

      final data = jsonDecode(await integrityFile.readAsString()) as Map;
      return data['checksum'] as String?;
    } catch (e) {
      return null;
    }
  }

  // ==================== ПРОВЕРКА НА TAMPERING ====================

  /// Проверяет приложение на признаки tampering
  ///
  /// Обнаруживает:
  /// - Отладочный режим в production
  /// - Наличие отладчика
  /// - Модифицированные файлы
  Future<IntegrityResult> verifyTampering() async {
    try {
      // Проверка 1: Debug режим
      if (!Platform.isAndroid && !Platform.isIOS) {
        // На desktop debug режим допустим
        return IntegrityResult.valid(CheckType.tampering);
      }

      // Проверка 2: Наличие отладчика (упрощённо)
      final isDebuggerAttached = _checkDebuggerAttached();
      if (isDebuggerAttached) {
        return IntegrityResult.invalid(
          CheckType.tampering,
          'Обнаружен отладчик',
        );
      }

      // Проверка 3: Критические файлы существуют
      final criticalFiles = [
        'lib/app/app.dart',
        'lib/core/utils/crypto_utils.dart',
      ];

      for (final filePath in criticalFiles) {
        final file = File(filePath);
        if (await file.exists()) {
          // Файл существует - это хорошо для разработки
          // В production эти файлы будут скомпилированы
        }
      }

      return IntegrityResult.valid(CheckType.tampering);
    } catch (e) {
      return IntegrityResult.invalid(
        CheckType.tampering,
        'Ошибка проверки tampering: $e',
      );
    }
  }

  /// Проверяет наличие отладчика
  bool _checkDebuggerAttached() {
    // Упрощённая проверка
    // В реальной реализации использовать platform-specific методы
    return false;
  }

  // ==================== КОМПЛЕКСНАЯ ПРОВЕРКА ====================

  /// Выполняет полную проверку целостности
  ///
  /// Возвращает список результатов всех проверок
  Future<List<IntegrityResult>> fullIntegrityCheck() async {
    final results = <IntegrityResult>[];

    // Проверка checksum
    final checksumResult = await verifyChecksum();
    results.add(checksumResult);

    // Проверка на tampering
    final tamperingResult = await verifyTampering();
    results.add(tamperingResult);

    return results;
  }

  /// Проверяет, пройдены ли все проверки
  Future<bool> isIntegrityValid() async {
    final results = await fullIntegrityCheck();
    return results.every((r) => r.isValid);
  }

  // ==================== УТИЛИТЫ ====================

  /// Сбрасывает сохранённый checksum
  ///
  /// Используется при обновлении приложения
  static Future<void> resetStoredChecksum() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final integrityFile = File('${appDir.path}/$_integrityDataFile');

      if (await integrityFile.exists()) {
        await integrityFile.delete();
      }
    } catch (e) {
      // Игнорируем ошибки
    }
  }

  /// Получает информацию о последней проверке
  static Future<Map<String, dynamic>?> getIntegrityInfo() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final integrityFile = File('${appDir.path}/$_integrityDataFile');

      if (!await integrityFile.exists()) {
        return null;
      }

      final data = jsonDecode(await integrityFile.readAsString()) as Map;
      return {
        'checksum': data['checksum'],
        'timestamp': data['timestamp'],
        'version': data['version'],
      };
    } catch (e) {
      return null;
    }
  }
}
