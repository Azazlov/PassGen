import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/password_history_entry.dart';
import '../../domain/repositories/password_history_repository.dart';
import '../database/database_helper.dart';

/// Реализация репозитория истории паролей
class PasswordHistoryRepositoryImpl implements PasswordHistoryRepository {
  PasswordHistoryRepositoryImpl(this.dbHelper);

  final DatabaseHelper dbHelper;

  @override
  Future<Either<PasswordHistoryFailure, int>> saveHistoryEntry({
    required int entryId,
    required String service,
    required String encryptedPassword,
    required String nonce,
    required String config,
    String? login,
    String? reason,
  }) async {
    try {
      final db = await dbHelper.database;

      final id = await db.insert('password_history', {
        'entry_id': entryId,
        'service': service,
        'encrypted_password': encryptedPassword,
        'nonce': nonce,
        'config': config,
        'login': login,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'reason': reason,
      });

      return Right(id);
    } catch (e) {
      return Left(
        PasswordHistoryFailure(message: 'Ошибка сохранения истории: $e'),
      );
    }
  }

  @override
  Future<Either<PasswordHistoryFailure, List<PasswordHistoryEntry>>>
  getHistoryForEntry(int entryId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'password_history',
        where: 'entry_id = ?',
        whereArgs: [entryId],
        orderBy: 'created_at DESC',
      );

      final history = maps.map((map) {
        return PasswordHistoryEntry(
          id: map['id'] as int?,
          entryId: map['entry_id'] as int,
          service: map['service'] as String,
          encryptedPassword: map['encrypted_password'] as String,
          nonce: map['nonce'] as String,
          config: map['config'] as String,
          login: map['login'] as String?,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            map['created_at'] as int,
          ),
          reason: map['reason'] as String?,
        );
      }).toList();

      return Right(history);
    } catch (e) {
      return Left(
        PasswordHistoryFailure(message: 'Ошибка получения истории: $e'),
      );
    }
  }

  @override
  Future<Either<PasswordHistoryFailure, PasswordHistoryEntry?>>
  getLastHistoryEntry(int entryId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'password_history',
        where: 'entry_id = ?',
        whereArgs: [entryId],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return const Right(null);
      }

      final map = maps.first;
      return Right(
        PasswordHistoryEntry(
          id: map['id'] as int?,
          entryId: map['entry_id'] as int,
          service: map['service'] as String,
          encryptedPassword: map['encrypted_password'] as String,
          nonce: map['nonce'] as String,
          config: map['config'] as String,
          login: map['login'] as String?,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            map['created_at'] as int,
          ),
          reason: map['reason'] as String?,
        ),
      );
    } catch (e) {
      return Left(
        PasswordHistoryFailure(
          message: 'Ошибка получения последней записи: $e',
        ),
      );
    }
  }

  @override
  Future<Either<PasswordHistoryFailure, int>> getHistoryCount(
    int entryId,
  ) async {
    try {
      final db = await dbHelper.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM password_history WHERE entry_id = ?',
        [entryId],
      );

      final count = result.first['count'] as int? ?? 0;
      return Right(count);
    } catch (e) {
      return Left(
        PasswordHistoryFailure(
          message: 'Ошибка получения количества записей: $e',
        ),
      );
    }
  }

  @override
  Future<Either<PasswordHistoryFailure, bool>> deleteHistoryForEntry(
    int entryId,
  ) async {
    try {
      final db = await dbHelper.database;

      final count = await db.delete(
        'password_history',
        where: 'entry_id = ?',
        whereArgs: [entryId],
      );

      return Right(count > 0);
    } catch (e) {
      return Left(
        PasswordHistoryFailure(message: 'Ошибка удаления истории: $e'),
      );
    }
  }

  @override
  Future<Either<PasswordHistoryFailure, int>> pruneOldHistory({
    required int entryId,
    required int keepCount,
  }) async {
    try {
      final db = await dbHelper.database;

      // Получаем ID записей, которые нужно удалить (все кроме последних keepCount)
      final result = await db.rawQuery(
        '''
        SELECT id FROM password_history 
        WHERE entry_id = ? 
        ORDER BY created_at DESC 
        LIMIT -1 OFFSET ?
        ''',
        [entryId, keepCount],
      );

      if (result.isEmpty) {
        return const Right(0);
      }

      final idsToDelete = result.map((r) => r['id'] as int).toList();

      // Удаляем старые записи
      final count = await db.delete(
        'password_history',
        where: 'id IN (${List.filled(idsToDelete.length, '?').join(',')})',
        whereArgs: idsToDelete,
      );

      return Right(count);
    } catch (e) {
      return Left(
        PasswordHistoryFailure(message: 'Ошибка очистки старой истории: $e'),
      );
    }
  }

  @override
  Future<Either<PasswordHistoryFailure, Map<String, dynamic>>>
  getHistoryStats() async {
    try {
      final db = await dbHelper.database;

      // Общее количество записей истории
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM password_history',
      );
      final totalEntries = totalResult.first['count'] as int? ?? 0;

      // Количество паролей с историей
      final entriesWithHistoryResult = await db.rawQuery(
        'SELECT COUNT(DISTINCT entry_id) as count FROM password_history',
      );
      final entriesWithHistory =
          entriesWithHistoryResult.first['count'] as int? ?? 0;

      // Дата самой старой записи
      final oldestResult = await db.rawQuery(
        'SELECT MIN(created_at) as oldest FROM password_history',
      );
      final oldestTimestamp = oldestResult.first['oldest'] as int?;
      final oldestEntry = oldestTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(oldestTimestamp)
          : null;

      return Right({
        'total_entries': totalEntries,
        'entries_with_history': entriesWithHistory,
        'oldest_entry': oldestEntry?.toIso8601String(),
      });
    } catch (e) {
      return Left(
        PasswordHistoryFailure(message: 'Ошибка получения статистики: $e'),
      );
    }
  }
}
