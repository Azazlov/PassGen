import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_result.dart';
import '../entities/auth_state.dart';

/// Интерфейс репозитория аутентификации
abstract class AuthRepository {
  /// Проверяет, установлен ли PIN
  Future<bool> isPinSetup();

  /// Устанавливает новый PIN
  Future<Either<AuthFailure, bool>> setupPin(String pin);

  /// Проверяет PIN
  Future<Either<AuthFailure, AuthResult>> verifyPin(String pin);

  /// Меняет PIN (требуется старый PIN)
  Future<Either<AuthFailure, bool>> changePin(String oldPin, String newPin);

  /// Удаляет PIN
  Future<Either<AuthFailure, bool>> removePin(String pin);

  /// Получает текущее состояние аутентификации
  Future<AuthState> getAuthState();

  /// Сбрасывает состояние аутентификации (при выходе из приложения)
  void resetAuthState();

  /// Проверяет, не истёк ли срок блокировки
  Future<bool> checkLockoutExpired();
}
