import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Интерфейс репозитория для шифрования/дешифрования
abstract class EncryptorRepository {
  /// Шифрует сообщение
  Future<Either<EncryptionFailure, String>> encrypt(
    String message,
    String password,
  );

  /// Дешифрует сообщение
  Future<Either<EncryptionFailure, String>> decrypt(
    String encryptedData,
    String password,
  );
}
