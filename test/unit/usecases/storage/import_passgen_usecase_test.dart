import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/storage/import_passgen_usecase.dart';
import 'package:pass_gen/domain/repositories/password_import_repository.dart';
import 'package:pass_gen/core/errors/failures.dart';

import 'import_passgen_usecase_test.mocks.dart';

@GenerateMocks([PasswordImportRepository])
void main() {
  late ImportPassgenUseCase useCase;
  late MockPasswordImportRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordImportRepository();
    useCase = ImportPassgenUseCase(mockRepository);
  });

  group('ImportPassgenUseCase', () {
    const testData = 'PASSGEN_V1...encrypted_data...';
    const testMasterPassword = 'master123';

    test('должен вернуть true при успешном импорте .passgen', () async {
      // Arrange
      when(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(
        data: testData,
        masterPassword: testMasterPassword,
      );

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).called(1);
    });

    test('должен вернуть false при неудачном импорте', () async {
      // Arrange
      when(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).thenAnswer((_) async => const Right(false));

      // Act
      final result = await useCase.execute(
        data: testData,
        masterPassword: testMasterPassword,
      );

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isFalse);
      verify(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).called(1);
    });

    test('должен вернуть StorageFailure при ошибке импорта', () async {
      // Arrange
      const failure = StorageFailure(message: 'Ошибка импорта из .passgen формата');
      when(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(
        data: testData,
        masterPassword: testMasterPassword,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
      verify(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).called(1);
    });

    test('должен вызвать repository.importFromPassgen с правильными параметрами', () async {
      // Arrange
      when(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).thenAnswer((_) async => const Right(true));

      // Act
      await useCase.execute(
        data: testData,
        masterPassword: testMasterPassword,
      );

      // Assert
      verify(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: testMasterPassword,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен вернуть StorageFailure при неверном мастер-пароле', () async {
      // Arrange
      const wrongPassword = 'wrongPassword';
      const failure = StorageFailure(message: 'Неверный мастер-пароль');
      when(mockRepository.importFromPassgen(
        data: testData,
        masterPassword: wrongPassword,
      )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(
        data: testData,
        masterPassword: wrongPassword,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
    });

    test('должен вернуть StorageFailure при некорректном формате данных', () async {
      // Arrange
      const invalidData = 'INVALID_FORMAT';
      const failure = StorageFailure(message: 'Некорректный формат .passgen файла');
      when(mockRepository.importFromPassgen(
        data: invalidData,
        masterPassword: testMasterPassword,
      )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(
        data: invalidData,
        masterPassword: testMasterPassword,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
    });
  });
}
