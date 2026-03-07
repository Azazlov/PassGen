/// Базовый класс для всех ошибок
abstract class Failure {
  final String message;

  const Failure({required this.message});

  @override
  String toString() => '$runtimeType(message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Ошибка шифрования/дешифрования
class EncryptionFailure extends Failure {
  const EncryptionFailure({required super.message});
}

/// Ошибка генерации пароля
class PasswordGenerationFailure extends Failure {
  const PasswordGenerationFailure({required super.message});
}

/// Ошибка хранилища
class StorageFailure extends Failure {
  const StorageFailure({required super.message});
}

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Ошибка конфигурации
class ConfigFailure extends Failure {
  const ConfigFailure({required super.message});
}

/// Ошибка аутентификации
class AuthFailure extends Failure {
  final AuthFailureType type;

  const AuthFailure({
    required super.message,
    this.type = AuthFailureType.general,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthFailure &&
        other.message == message &&
        other.type == type;
  }

  @override
  int get hashCode => message.hashCode ^ type.hashCode;
}

/// Типы ошибок аутентификации
enum AuthFailureType {
  general,
  wrongPin,
  locked,
  notSetup,
  validation,
}
