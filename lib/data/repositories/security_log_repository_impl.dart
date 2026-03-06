import 'dart:convert';
import '../database/database_helper.dart';
import '../models/security_log_model.dart';
import '../../domain/entities/security_log.dart';
import '../../domain/repositories/security_log_repository.dart';

/// Реализация репозитория логов безопасности для SQLite
class SecurityLogRepositoryImpl implements SecurityLogRepository {
  final DatabaseHelper _dbHelper;

  SecurityLogRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<void> logEvent(String actionType, {Map<String, dynamic>? details}) async {
    final log = SecurityLogModel(
      actionType: actionType,
      timestamp: DateTime.now(),
      details: details != null ? jsonEncode(details) : null,
    );
    await _dbHelper.insert('security_logs', log.toMap());

    // Автоочистка старых логов при превышении лимита
    final count = await this.count();
    if (count > 2000) {
      await clearOldLogs(keepLast: 1000);
    }
  }

  @override
  Future<List<SecurityLog>> getLogs({int limit = 1000}) async {
    final maps = await _dbHelper.query(
      'security_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps
        .map((map) => SecurityLogModel.fromMap(map))
        .map((model) => _toEntity(model))
        .toList();
  }

  @override
  Future<List<SecurityLog>> getLogsByType(String actionType, {int limit = 100}) async {
    final maps = await _dbHelper.query(
      'security_logs',
      where: 'action_type = ?',
      whereArgs: [actionType],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps
        .map((map) => SecurityLogModel.fromMap(map))
        .map((model) => _toEntity(model))
        .toList();
  }

  @override
  Future<void> clearOldLogs({int keepLast = 1000}) async {
    final db = await _dbHelper.database;
    // Удаляем все логи кроме последних keepLast
    await db.rawDelete('''
      DELETE FROM security_logs
      WHERE id NOT IN (
        SELECT id FROM security_logs
        ORDER BY timestamp DESC
        LIMIT ?
      )
    ''', [keepLast]);
  }

  @override
  Future<int> count() async {
    final result = await _dbHelper.rawQuery('SELECT COUNT(*) as count FROM security_logs');
    return result.first['count'] as int? ?? 0;
  }

  @override
  Future<void> clearAll() async {
    await _dbHelper.deleteAll('security_logs');
  }

  /// Преобразование модели в entity
  SecurityLog _toEntity(SecurityLogModel model) {
    return SecurityLog(
      id: model.id,
      actionType: model.actionType,
      timestamp: model.timestamp,
      details: model.details,
    );
  }

  /// Преобразование entity в модель
  SecurityLogModel _toModel(SecurityLog entity) {
    return SecurityLogModel(
      id: entity.id,
      actionType: entity.actionType,
      timestamp: entity.timestamp,
      details: entity.details != null ? jsonEncode(entity.details!) : null,
    );
  }
}
