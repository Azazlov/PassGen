import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/password_entry.dart';

/// Интерфейс репозитория для хранилища конфигов
abstract class StorageRepository {
  /// Сохраняет список конфигов
  Future<Either<StorageFailure, bool>> saveConfigs(
    String key,
    List<String> configs,
  );

  /// Получает список конфигов
  Future<Either<StorageFailure, List<String>>> getConfigs(String key);

  /// Удаляет конфиг по индексу
  Future<Either<StorageFailure, bool>> removeConfigAt(
    String key,
    int index,
  );

  /// Очищает всё хранилище по ключу
  Future<Either<StorageFailure, bool>> clearStorage(String key);

  /// Сохраняет список паролей
  Future<Either<StorageFailure, bool>> savePasswords(List<PasswordEntry> passwords);

  /// Получает список паролей
  Future<Either<StorageFailure, List<PasswordEntry>>> getPasswords();

  /// Удаляет пароль по индексу
  Future<Either<StorageFailure, bool>> removePasswordAt(int index);

  /// Экспортирует пароли в JSON строку
  Future<Either<StorageFailure, String>> exportPasswords();

  /// Импортирует пароли из JSON строки
  Future<Either<StorageFailure, bool>> importPasswords(String jsonString);

  /// Экспортирует пароли в формат .passgen
  Future<Either<StorageFailure, String>> exportPassgen(String masterPassword);

  /// Импортирует пароли из формата .passgen
  Future<Either<StorageFailure, bool>> importPassgen({
    required String data,
    required String masterPassword,
  });
}
