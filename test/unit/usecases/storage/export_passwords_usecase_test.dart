import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/storage/export_passwords_usecase.dart';
import 'package:pass_gen/domain/repositories/password_export_repository.dart';
import 'package:pass_gen/core/errors/failures.dart';

import 'export_passwords_usecase_test.mocks.dart';

@GenerateMocks([PasswordExportRepository])
void main() {
  late ExportPasswordsUseCase useCase;
  late MockPasswordExportRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordExportRepository();
    useCase = ExportPasswordsUseCase(mockRepository);
  });

  group('ExportPasswordsUseCase', () {
    test('должен вернуть JSON строку при успешном экспорте', () async {
      // Arrange
      const testJson = '[{"service":"Gmail","password":"test123"}]';
      when(mockRepository.exportToJson())
          .thenAnswer((_) async => const Right(testJson));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(testJson));
      verify(mockRepository.exportToJson()).called(1);
    });

    test('должен вернуть пустой JSON массив при пустом хранилище', () async {
      // Arrange
      const testJson = '[]';
      when(mockRepository.exportToJson())
          .thenAnswer((_) async => const Right(testJson));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(testJson));
      verify(mockRepository.exportToJson()).called(1);
    });

    test('должен вернуть StorageFailure при ошибке экспорта', () async {
      // Arrange
      const failure = StorageFailure(message: 'Ошибка экспорта паролей');
      when(mockRepository.exportToJson())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
      verify(mockRepository.exportToJson()).called(1);
    });

    test('должен вызвать repository.exportToJson()', () async {
      // Arrange
      when(mockRepository.exportToJson())
          .thenAnswer((_) async => const Right('[]'));

      // Act
      await useCase.execute();

      // Assert
      verify(mockRepository.exportToJson()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
