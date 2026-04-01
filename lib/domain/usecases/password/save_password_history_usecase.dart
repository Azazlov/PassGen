import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/password_history_repository.dart';

/// Use case для сохранения текущей версии пароля в историю
///
/// Используется перед обновлением пароля для сохранения предыдущей версии
class SavePasswordHistoryUseCase {
  SavePasswordHistoryUseCase(this._repository);

  final PasswordHistoryRepository _repository;

  /// Сохраняет текущую версию пароля в историю
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
  Future<Either<Failure, int>> execute({
    required int entryId,
    required String service,
    required String encryptedPassword,
    required String nonce,
    required String config,
    String? login,
    String? reason,
  }) {
    return _repository.saveHistoryEntry(
      entryId: entryId,
      service: service,
      encryptedPassword: encryptedPassword,
      nonce: nonce,
      config: config,
      login: login,
      reason: reason,
    );
  }
}
