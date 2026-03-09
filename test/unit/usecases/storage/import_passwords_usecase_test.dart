import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/domain/repositories/password_import_repository.dart';
import 'package:pass_gen/domain/usecases/storage/import_passwords_usecase.dart';

import 'import_passwords_usecase_test.mocks.dart';

@GenerateMocks([PasswordImportRepository])
void main() {
  late ImportPasswordsUseCase useCase;
  late MockPasswordImportRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordImportRepository();
    useCase = ImportPasswordsUseCase(mockRepository);
  });

  group('ImportPasswordsUseCase', () {
    const testJson = '[{"service":"Gmail","password":"test123"}]';

    test('должен вернуть true при успешном импорте', () async {
      // Arrange
      when(mockRepository.importFromJson(testJson))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(testJson);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.importFromJson(testJson)).called(1);
    });

    test('должен вернуть false при неудачном импорте', () async {
      // Arrange
      when(mockRepository.importFromJson(testJson))
          .thenAnswer((_) async => const Right(false));

      // Act
      final result = await useCase.execute(testJson);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isFalse);
      verify(mockRepository.importFromJson(testJson)).called(1);
    });

    test('должен вернуть StorageFailure при ошибке импорта', () async {
      // Arrange
      const failure = StorageFailure(message: 'Ошибка импорта паролей');
      when(mockRepository.importFromJson(testJson))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.execute(testJson);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
      verify(mockRepository.importFromJson(testJson)).called(1);
    });

    test('должен вызвать repository.importFromJson с правильной JSON строкой', () async {
      // Arrange
      when(mockRepository.importFromJson(testJson))
          .thenAnswer((_) async => const Right(true));

      // Act
      await useCase.execute(testJson);

      // Assert
      verify(mockRepository.importFromJson(testJson)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с пустым JSON массивом', () async {
      // Arrange
      const emptyJson = '[]';
      when(mockRepository.importFromJson(emptyJson))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(emptyJson);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.importFromJson(emptyJson)).called(1);
    });

    test('должен работать с некорректным JSON', () async {
      // Arrange
      const invalidJson = '{invalid}';
      const failure = StorageFailure(message: 'Некорректный формат JSON');
      when(mockRepository.importFromJson(invalidJson))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.execute(invalidJson);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
    });
  });
}
