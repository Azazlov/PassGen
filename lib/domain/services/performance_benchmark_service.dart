import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../core/utils/crypto_utils.dart';
import '../../core/utils/encryption_versioning.dart';
import '../repositories/security_log_repository.dart';

/// Результат замера производительности
class BenchmarkResult {
  const BenchmarkResult({
    required this.operation,
    required this.durationMs,
    required this.iterations,
    this.deviceInfo,
  });

  final String operation;
  final double durationMs;
  final int iterations;
  final String? deviceInfo;

  Map<String, dynamic> toJson() => {
        'operation': operation,
        'duration_ms': durationMs,
        'iterations': iterations,
        'device': deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// Формат экспорта результатов
enum BenchmarkExportFormat { csv, json }

/// Сервис замеров производительности криптографических операций
class PerformanceBenchmarkService {
  PerformanceBenchmarkService({
    required SecurityLogRepository logRepository,
  }) : _logRepository = logRepository;

  final SecurityLogRepository _logRepository;

  /// Замер PBKDF2 с 600 000 итераций
  Future<BenchmarkResult> runPbkdf2Benchmark() async {
    final iterations = EncryptionParams.v2().iterations;
    final salt = CryptoUtils.generateSecureSalt();
    const pin = '123456';

    final stopwatch = Stopwatch()..start();
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    await pbkdf2.deriveKeyFromPassword(
      password: pin,
      nonce: Uint8List.fromList(salt),
    );
    stopwatch.stop();

    final result = BenchmarkResult(
      operation: 'PBKDF2-HMAC-SHA256',
      durationMs: stopwatch.elapsedMilliseconds.toDouble(),
      iterations: iterations,
    );

    await _logResult(result);
    return result;
  }

  /// Замер генерации паролей
  Future<BenchmarkResult> runGenerationBenchmark({int count = 1000}) async {
    const length = 20;
    final random = Random.secure();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%';

    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < count; i++) {
      List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
    }
    stopwatch.stop();

    final result = BenchmarkResult(
      operation: 'PasswordGeneration',
      durationMs: stopwatch.elapsedMilliseconds.toDouble(),
      iterations: count,
    );

    await _logResult(result);
    return result;
  }

  /// Замер шифрования/расшифровки
  Future<BenchmarkResult> runEncryptionBenchmark({int count = 1000}) async {
    final algorithm = Chacha20.poly1305Aead();
    final key = await algorithm.newSecretKey();
    final message = utf8.encode('benchmark_message_123');

    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < count; i++) {
      final box = await algorithm.encrypt(message, secretKey: key);
      await algorithm.decrypt(box, secretKey: key);
    }
    stopwatch.stop();

    final result = BenchmarkResult(
      operation: 'ChaCha20-Poly1305_EncryptDecrypt',
      durationMs: stopwatch.elapsedMilliseconds.toDouble(),
      iterations: count,
    );

    await _logResult(result);
    return result;
  }

  /// Прогон всех трёх бенчмарков
  Future<List<BenchmarkResult>> runAllBenchmarks() async {
    final results = <BenchmarkResult>[];
    results.add(await runPbkdf2Benchmark());
    results.add(await runGenerationBenchmark());
    results.add(await runEncryptionBenchmark());
    return results;
  }

  /// Экспорт результатов
  String exportResults(
    List<BenchmarkResult> results, {
    BenchmarkExportFormat format = BenchmarkExportFormat.csv,
  }) {
    switch (format) {
      case BenchmarkExportFormat.csv:
        final buffer = StringBuffer()
          ..writeln('operation,duration_ms,iterations,timestamp');
        for (final r in results) {
          buffer.writeln(
            '${r.operation},${r.durationMs.toStringAsFixed(2)},${r.iterations},${DateTime.now().toIso8601String()}',
          );
        }
        return buffer.toString();
      case BenchmarkExportFormat.json:
        return jsonEncode(results.map((r) => r.toJson()).toList());
    }
  }

  Future<void> _logResult(BenchmarkResult result) async {
    try {
      await _logRepository.logEvent(
        'BENCHMARK',
        details: result.toJson(),
      );
    } catch (_) {
      // Игнорируем ошибки логирования
    }
  }
}
