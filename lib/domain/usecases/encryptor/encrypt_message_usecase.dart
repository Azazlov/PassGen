import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/encryptor_repository.dart';

/// Использование: Шифрование сообщения
class EncryptMessageUseCase {
  final EncryptorRepository repository;

  const EncryptMessageUseCase(this.repository);

  Future<Either<EncryptionFailure, String>> execute({
    required String message,
    required String password,
  }) async {
    return await repository.encrypt(message, password);
  }
}
