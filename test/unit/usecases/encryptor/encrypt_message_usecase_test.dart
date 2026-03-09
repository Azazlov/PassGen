import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/domain/repositories/encryptor_repository.dart';
import 'package:pass_gen/domain/usecases/encryptor/encrypt_message_usecase.dart';

import 'encrypt_message_usecase_test.mocks.dart';

@GenerateMocks([EncryptorRepository])
void main() {
  late EncryptMessageUseCase useCase;
  late MockEncryptorRepository mockRepository;

  setUp(() {
    mockRepository = MockEncryptorRepository();
    useCase = EncryptMessageUseCase(mockRepository);
  });

  group('EncryptMessageUseCase', () {
    test('должен зашифровать сообщение', () async {
      // Arrange
      const testMessage = 'Secret message';
      const testPassword = 'password123';
      const encryptedData = 'encrypted_base64_data';

      when(mockRepository.encrypt(testMessage, testPassword))
          .thenAnswer((_) async => const Right(encryptedData));

      // Act
      final result = await useCase.execute(message: testMessage, password: testPassword);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(encryptedData));
      verify(mockRepository.encrypt(testMessage, testPassword)).called(1);
    });

    test('должен зашифровать пустое сообщение', () async {
      // Arrange
      const testMessage = '';
      const testPassword = 'password123';
      const encryptedData = 'encrypted_empty_data';

      when(mockRepository.encrypt(testMessage, testPassword))
          .thenAnswer((_) async => const Right(encryptedData));

      // Act
      final result = await useCase.execute(message: testMessage, password: testPassword);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(encryptedData));
    });

    test('должен вернуть EncryptionFailure при ошибке', () async {
      // Arrange
      const testMessage = 'Secret';
      const testPassword = 'password';
      const failure = EncryptionFailure(message: 'Ошибка шифрования');

      when(mockRepository.encrypt(testMessage, testPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.execute(message: testMessage, password: testPassword);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
    });

    test('должен вызвать repository.encrypt с правильными параметрами', () async {
      // Arrange
      const testMessage = 'Test message';
      const testPassword = 'secure_password';
      when(mockRepository.encrypt(testMessage, testPassword))
          .thenAnswer((_) async => const Right('encrypted'));

      // Act
      await useCase.execute(message: testMessage, password: testPassword);

      // Assert
      verify(mockRepository.encrypt(testMessage, testPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с разными сообщениями', () async {
      // Arrange
      when(mockRepository.encrypt('msg1', 'pass1'))
          .thenAnswer((_) async => const Right('enc1'));
      when(mockRepository.encrypt('msg2', 'pass2'))
          .thenAnswer((_) async => const Right('enc2'));

      // Act
      final result1 = await useCase.execute(message: 'msg1', password: 'pass1');
      final result2 = await useCase.execute(message: 'msg2', password: 'pass2');

      // Assert
      expect((result1 as Right).value, equals('enc1'));
      expect((result2 as Right).value, equals('enc2'));
    });
  });
}
