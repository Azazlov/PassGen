import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/encryptor_repository.dart';

/// Использование: Дешифрование сообщения
class DecryptMessageUseCase {
  const DecryptMessageUseCase(this.repository);
  final EncryptorRepository repository;

  Future<Either<EncryptionFailure, String>> execute({
    required String encryptedData,
    required String password,
  }) async {
    return repository.decrypt(encryptedData, password);
  }
}
