import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/encryptor/decrypt_message_usecase.dart';
import 'package:pass_gen/domain/repositories/encryptor_repository.dart';
import 'package:pass_gen/core/errors/failures.dart';

import 'decrypt_message_usecase_test.mocks.dart';

@GenerateMocks([EncryptorRepository])
void main() {
  late DecryptMessageUseCase useCase;
  late MockEncryptorRepository mockRepository;

  setUp(() {
    mockRepository = MockEncryptorRepository();
    useCase = DecryptMessageUseCase(mockRepository);
  });

  group('DecryptMessageUseCase', () {
    test('должен дешифровать сообщение', () async {
      // Arrange
      const encryptedData = 'encrypted_base64_data';
      const testPassword = 'password123';
      const decryptedMessage = 'Secret message';

      when(mockRepository.decrypt(encryptedData, testPassword))
          .thenAnswer((_) async => const Right(decryptedMessage));

      // Act
      final result = await useCase.execute(encryptedData: encryptedData, password: testPassword);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(decryptedMessage));
      verify(mockRepository.decrypt(encryptedData, testPassword)).called(1);
    });

    test('должен дешифровать сообщение с кириллицей', () async {
      // Arrange
      const encryptedData = 'encrypted_cyrillic_data';
      const testPassword = 'password123';
      const decryptedMessage = 'Секретное сообщение';

      when(mockRepository.decrypt(encryptedData, testPassword))
          .thenAnswer((_) async => const Right(decryptedMessage));

      // Act
      final result = await useCase.execute(encryptedData: encryptedData, password: testPassword);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(decryptedMessage));
    });

    test('должен вернуть EncryptionFailure при неверном пароле', () async {
      // Arrange
      const encryptedData = 'encrypted_data';
      const wrongPassword = 'wrong_password';
      const failure = EncryptionFailure(message: 'Неверный пароль или повреждённые данные');

      when(mockRepository.decrypt(encryptedData, wrongPassword))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(encryptedData: encryptedData, password: wrongPassword);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
    });

    test('должен вернуть EncryptionFailure при некорректных данных', () async {
      // Arrange
      const invalidData = 'invalid_encrypted_data';
      const testPassword = 'password';
      const failure = EncryptionFailure(message: 'Некорректный формат зашифрованных данных');

      when(mockRepository.decrypt(invalidData, testPassword))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(encryptedData: invalidData, password: testPassword);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
    });

    test('должен вызвать repository.decrypt с правильными параметрами', () async {
      // Arrange
      const encryptedData = 'test_encrypted';
      const testPassword = 'secure_password';
      when(mockRepository.decrypt(encryptedData, testPassword))
          .thenAnswer((_) async => const Right('decrypted'));

      // Act
      await useCase.execute(encryptedData: encryptedData, password: testPassword);

      // Assert
      verify(mockRepository.decrypt(encryptedData, testPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
