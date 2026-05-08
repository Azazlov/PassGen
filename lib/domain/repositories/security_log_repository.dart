import '../entities/security_log.dart';

/// Интерфейс репозитория логов безопасности
abstract class SecurityLogRepository {
  /// Логирование события
  Future<void> logEvent(
    String actionType, {
    Map<String, dynamic>? details,
    int? profileId,
  });

  /// Получение последних логов (опционально по профилю)
  Future<List<SecurityLog>> getLogs({int limit = 1000, int? profileId});

  /// Получение логов по типу события (опционально по профилю)
  Future<List<SecurityLog>> getLogsByType(
    String actionType, {
    int limit = 100,
    int? profileId,
  });

  /// Очистка старых логов
  Future<void> clearOldLogs({int keepLast = 1000});

  /// Подсчёт количества логов
  Future<int> count();

  /// Очистка всех логов
  Future<void> clearAll();
}
