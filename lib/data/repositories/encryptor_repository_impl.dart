import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/repositories/encryptor_repository.dart';
import '../datasources/encryptor_local_datasource.dart';

/// Реализация репозитория шифрования/дешифрования
class EncryptorRepositoryImpl implements EncryptorRepository {
  const EncryptorRepositoryImpl(this.dataSource);
  final EncryptorLocalDataSource dataSource;

  @override
  Future<Either<EncryptionFailure, String>> encrypt(
    String message,
    String password,
  ) async {
    try {
      final messageBytes = utf8.encode(message);
      final passwordBytes = utf8.encode(password);

      final encryptedMini = await dataSource.encryptToMini(
        message: messageBytes,
        password: passwordBytes,
      );

      return Right(encryptedMini);
    } catch (e) {
      return Left(EncryptionFailure(message: 'Ошибка шифрования: $e'));
    }
  }

  @override
  Future<Either<EncryptionFailure, String>> decrypt(
    String encryptedData,
    String password,
  ) async {
    try {
      final passwordBytes = utf8.encode(password);

      final decryptedBytes = await dataSource.decryptFromMini(
        miniEncrypted: encryptedData,
        password: passwordBytes,
      );

      final decryptedMessage = utf8.decode(decryptedBytes);

      return Right(decryptedMessage);
    } catch (e) {
      return Left(EncryptionFailure(message: 'Ошибка дешифрования: $e'));
    }
  }
}
