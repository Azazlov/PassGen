import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/domain/entities/password_entry.dart';
import 'package:pass_gen/domain/repositories/storage_repository.dart';
import 'package:pass_gen/domain/usecases/storage/get_passwords_usecase.dart';

import 'get_passwords_usecase_test.mocks.dart';

@GenerateMocks([StorageRepository])
void main() {
  late GetPasswordsUseCase useCase;
  late MockStorageRepository mockRepository;

  setUp(() {
    mockRepository = MockStorageRepository();
    useCase = GetPasswordsUseCase(mockRepository);
  });

  group('GetPasswordsUseCase', () {
    test('должен вернуть список паролей при успехе', () async {
      // Arrange
      final testPasswords = [
        PasswordEntry(
          service: 'Gmail',
          password: 'test123',
          config: '{}',
          login: 'user@gmail.com',
          createdAt: DateTime(2024, 1, 1),
        ),
        PasswordEntry(
          service: 'Facebook',
          password: 'fb456',
          config: '{}',
          login: 'user@fb.com',
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      when(mockRepository.getPasswords())
          .thenAnswer((_) async => Right(testPasswords));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(testPasswords));
      verify(mockRepository.getPasswords()).called(1);
    });

    test('должен вернуть пустой список, если хранилище пустое', () async {
      // Arrange
      when(mockRepository.getPasswords())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isEmpty);
      verify(mockRepository.getPasswords()).called(1);
    });

    test('должен вернуть StorageFailure при ошибке', () async {
      // Arrange
      const failure = StorageFailure(message: 'Ошибка получения паролей');
      when(mockRepository.getPasswords())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
      verify(mockRepository.getPasswords()).called(1);
    });

    test('должен вызвать repository.getPasswords()', () async {
      // Arrange
      when(mockRepository.getPasswords())
          .thenAnswer((_) async => const Right([]));

      // Act
      await useCase.execute();

      // Assert
      verify(mockRepository.getPasswords()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
