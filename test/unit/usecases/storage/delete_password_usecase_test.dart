import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/domain/repositories/storage_repository.dart';
import 'package:pass_gen/domain/usecases/storage/delete_password_usecase.dart';

import 'delete_password_usecase_test.mocks.dart';

@GenerateMocks([StorageRepository])
void main() {
  late DeletePasswordUseCase useCase;
  late MockStorageRepository mockRepository;

  setUp(() {
    mockRepository = MockStorageRepository();
    useCase = DeletePasswordUseCase(mockRepository);
  });

  group('DeletePasswordUseCase', () {
    const testIndex = 0;

    test('должен вернуть true при успешном удалении', () async {
      // Arrange
      when(mockRepository.removePasswordAt(testIndex))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(testIndex);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.removePasswordAt(testIndex)).called(1);
    });

    test('должен вернуть false при неудачном удалении', () async {
      // Arrange
      when(mockRepository.removePasswordAt(testIndex))
          .thenAnswer((_) async => const Right(false));

      // Act
      final result = await useCase.execute(testIndex);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isFalse);
      verify(mockRepository.removePasswordAt(testIndex)).called(1);
    });

    test('должен вернуть StorageFailure при ошибке', () async {
      // Arrange
      const failure = StorageFailure(message: 'Ошибка удаления пароля');
      when(mockRepository.removePasswordAt(testIndex))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.execute(testIndex);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, equals(failure));
      verify(mockRepository.removePasswordAt(testIndex)).called(1);
    });

    test('должен вызвать repository.removePasswordAt с правильным индексом', () async {
      // Arrange
      when(mockRepository.removePasswordAt(testIndex))
          .thenAnswer((_) async => const Right(true));

      // Act
      await useCase.execute(testIndex);

      // Assert
      verify(mockRepository.removePasswordAt(testIndex)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с разными индексами', () async {
      // Arrange
      when(mockRepository.removePasswordAt(5))
          .thenAnswer((_) async => const Right(true));

      // Act
      await useCase.execute(5);

      // Assert
      verify(mockRepository.removePasswordAt(5)).called(1);
    });
  });
}
