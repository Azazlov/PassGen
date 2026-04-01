import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/password_history_entry.dart';

/// Репозиторий для работы с историей изменений паролей
///
/// Предоставляет доступ к истории версий паролей для:
/// - Отката к предыдущей версии
/// - Аудита изменений
/// - Восстановления утерянных паролей
abstract class PasswordHistoryRepository {
  /// Сохраняет текущую версию пароля в историю перед обновлением
  ///
  /// [entryId] - ID текущей записи пароля
  /// [service] - Название сервиса
  /// [encryptedPassword] - Зашифрованный пароль (Base64)
  /// [nonce] - Nonce для шифрования (Base64)
  /// [config] - Конфигурация генерации
  /// [login] - Логин (опционально)
  /// [reason] - Причина изменения (опционально)
  ///
  /// Возвращает ID сохранённой записи истории или ошибку
  Future<Either<Failure, int>> saveHistoryEntry({
    required int entryId,
    required String service,
    required String encryptedPassword,
    required String nonce,
    required String config,
    String? login,
    String? reason,
  });

  /// Получает всю историю изменений для конкретного пароля
  ///
  /// [entryId] - ID записи пароля
  ///
  /// Возвращает список записей истории (от новых к старым) или ошибку
  Future<Either<Failure, List<PasswordHistoryEntry>>> getHistoryForEntry(
    int entryId,
  );

  /// Получает последнюю версию пароля из истории
  ///
  /// [entryId] - ID записи пароля
  ///
  /// Возвращает последнюю запись истории или null, если истории нет
  Future<Either<Failure, PasswordHistoryEntry?>> getLastHistoryEntry(
    int entryId,
  );

  /// Получает количество записей истории для пароля
  ///
  /// [entryId] - ID записи пароля
  ///
  /// Возвращает количество записей или ошибку
  Future<Either<Failure, int>> getHistoryCount(int entryId);

  /// Удаляет всю историю для конкретного пароля
  ///
  /// [entryId] - ID записи пароля
  ///
  /// Возвращает true если успешно или ошибку
  Future<Either<Failure, bool>> deleteHistoryForEntry(int entryId);

  /// Удаляет старую историю, оставляя только последние N записей
  ///
  /// [entryId] - ID записи пароля
  /// [keepCount] - Количество записей для сохранения
  ///
  /// Возвращает количество удалённых записей или ошибку
  Future<Either<Failure, int>> pruneOldHistory({
    required int entryId,
    required int keepCount,
  });

  /// Получает общую статистику по истории паролей
  ///
  /// Возвращает карту со статистикой:
  /// - total_entries: общее количество записей истории
  /// - entries_with_history: количество паролей с историей
  /// - oldest_entry: дата самой старой записи
  ///
  /// или ошибку
  Future<Either<Failure, Map<String, dynamic>>> getHistoryStats();
}
