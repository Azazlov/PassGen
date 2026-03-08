import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/storage/export_passgen_usecase.dart';
import 'package:pass_gen/domain/repositories/password_export_repository.dart';
import 'package:pass_gen/core/errors/failures.dart';

import 'export_passgen_usecase_test.mocks.dart';

@GenerateMocks([PasswordExportRepository])
void main() {
  late ExportPassgenUseCase useCase;
  late MockPasswordExportRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordExportRepository();
    useCase = ExportPassgenUseCase(mockRepository);
  });

  group('ExportPassgenUseCase', () {
    const testMasterPassword = 'master123';
    const testPassgenData = 'PASSGEN_V1...encrypted_data...';

    test('должен вернуть .passgen данные при успешном экспорте', () async {
      // Arrange
      when(mockRepository.exportToPassgen(testMasterPassword))
          .thenAnswer((_) async => const Right(testPassgenData));

      // Act
      final result = await useCase.execute(testMasterPassword);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(testPassgenData));
      verify(mockRepository.exportToPassgen(testMasterPassword)).called(1);
    });

    test('должен вернуть пустые данные при пустом хранилище', () async {
      // Arrange
      const emptyData = 'PASSGEN_V1...';
      when(mockRepository.exportToPassgen(testMasterPassword))
          .thenAnswer((_) async => const Right(emptyData));

      // Act
      final result = await useCase.execute(testMasterPassword);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(emptyData));
      verify(mockRepository.exportToPassgen(testMasterPassword)).called(1);
    });

    test('должен вернуть StorageFailure при ошибке экспорта', () async {
      // Arrange
      const failure = StorageFailure(message: 'Ошибка экспорта в .passgen формат');
      when(mockRepository.exportToPassgen(testMasterPassword))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(testMasterPassword);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
      verify(mockRepository.exportToPassgen(testMasterPassword)).called(1);
    });

    test('должен вызвать repository.exportToPassgen с мастер-паролем', () async {
      // Arrange
      when(mockRepository.exportToPassgen(testMasterPassword))
          .thenAnswer((_) async => const Right(testPassgenData));

      // Act
      await useCase.execute(testMasterPassword);

      // Assert
      verify(mockRepository.exportToPassgen(testMasterPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с разными мастер-паролями', () async {
      // Arrange
      const differentPassword = 'anotherMaster456';
      when(mockRepository.exportToPassgen(differentPassword))
          .thenAnswer((_) async => const Right(testPassgenData));

      // Act
      final result = await useCase.execute(differentPassword);

      // Assert
      expect(result, isA<Right>());
      verify(mockRepository.exportToPassgen(differentPassword)).called(1);
    });
  });
}
