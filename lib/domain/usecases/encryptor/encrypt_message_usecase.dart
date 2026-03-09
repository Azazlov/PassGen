import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/encryptor_repository.dart';

/// Использование: Шифрование сообщения
class EncryptMessageUseCase {
  const EncryptMessageUseCase(this.repository);
  final EncryptorRepository repository;

  Future<Either<EncryptionFailure, String>> execute({
    required String message,
    required String password,
  }) async {
    return repository.encrypt(message, password);
  }
}
