import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/auth/remove_pin_usecase.dart';
import 'package:pass_gen/domain/repositories/auth_repository.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'remove_pin_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RemovePinUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RemovePinUseCase(mockRepository);
  });

  group('RemovePinUseCase', () {
    const testPin = '1234';

    test('должен успешно удалить PIN', () async {
      // Arrange
      when(mockRepository.removePin(testPin))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.removePin(testPin)).called(1);
    });

    test('должен вернуть false при неверном PIN', () async {
      // Arrange
      when(mockRepository.removePin(testPin))
          .thenAnswer((_) async => const Right(false));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isFalse);
    });

    test('должен вернуть ошибку при пустом PIN', () async {
      // Arrange
      when(mockRepository.removePin(''))
          .thenAnswer((_) async => Left<AuthFailure, bool>(AuthFailure(message: 'PIN не может быть пустым')));

      // Act
      final result = await useCase.execute('');

      // Assert
      expect(result, isA<Left>());
    });

    test('должен вызвать repository.removePin ровно 1 раз', () async {
      // Arrange
      when(mockRepository.removePin(testPin))
          .thenAnswer((_) async => const Right(true));

      // Act
      await useCase.execute(testPin);

      // Assert
      verify(mockRepository.removePin(testPin)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
