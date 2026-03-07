import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/encryptor_repository.dart';

/// Использование: Дешифрование сообщения
class DecryptMessageUseCase {
  final EncryptorRepository repository;

  const DecryptMessageUseCase(this.repository);

  Future<Either<EncryptionFailure, String>> execute({
    required String encryptedData,
    required String password,
  }) async {
    return await repository.decrypt(encryptedData, password);
  }
}
