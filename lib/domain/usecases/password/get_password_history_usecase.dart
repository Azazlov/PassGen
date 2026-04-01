import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/password_history_entry.dart';
import '../../repositories/password_history_repository.dart';

/// Use case для получения истории изменений пароля
///
/// Возвращает все версии пароля от новой к старой
class GetPasswordHistoryUseCase {
  GetPasswordHistoryUseCase(this._repository);

  final PasswordHistoryRepository _repository;

  /// Получает всю историю изменений для конкретного пароля
  ///
  /// [entryId] - ID записи пароля
  ///
  /// Возвращает список записей истории (от новых к старым) или ошибку
  Future<Either<Failure, List<PasswordHistoryEntry>>> execute(int entryId) {
    return _repository.getHistoryForEntry(entryId);
  }
}
