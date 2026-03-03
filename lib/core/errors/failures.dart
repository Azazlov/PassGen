/// Базовый класс для ошибок предметной области
abstract class Failure implements Exception {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Ошибка шифрования/дешифрования
class EncryptionFailure extends Failure {
  const EncryptionFailure({required super.message, super.code});
}

/// Ошибка генерации пароля
class PasswordGenerationFailure extends Failure {
  const PasswordGenerationFailure({required super.message, super.code});
}

/// Ошибка хранилища
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Ошибка конфигурации
class ConfigFailure extends Failure {
  const ConfigFailure({required super.message, super.code});
}
