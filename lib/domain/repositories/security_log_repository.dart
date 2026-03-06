import '../entities/security_log.dart';

/// Интерфейс репозитория логов безопасности
abstract class SecurityLogRepository {
  /// Логирование события
  Future<void> logEvent(String actionType, {Map<String, dynamic>? details});

  /// Получение последних логов
  Future<List<SecurityLog>> getLogs({int limit = 1000});

  /// Получение логов по типу события
  Future<List<SecurityLog>> getLogsByType(String actionType, {int limit = 100});

  /// Очистка старых логов
  Future<void> clearOldLogs({int keepLast = 1000});

  /// Подсчёт количества логов
  Future<int> count();

  /// Очистка всех логов
  Future<void> clearAll();
}
