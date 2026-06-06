import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Интерфейс репозитория для импорта/экспорта паролей
///
/// Объединяет операции импорта и экспорта для уменьшения количества интерфейсов.
abstract class PasswordDataRepository {
  /// Экспортирует пароли в JSON строку
  Future<Either<StorageFailure, String>> exportToJson({int profileId = 1});

  /// Экспортирует пароли в формат .passgen
  Future<Either<StorageFailure, String>> exportToPassgen(String masterPassword, {int profileId = 1});

  /// Импортирует пароли из JSON строки
  Future<Either<StorageFailure, bool>> importFromJson(String jsonString, {int profileId = 1});

  /// Импортирует пароли из формата .passgen
  Future<Either<StorageFailure, bool>> importFromPassgen({
    required String data,
    required String masterPassword,
    int profileId = 1,
  });
}
