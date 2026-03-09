import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/domain/repositories/auth_repository.dart';
import 'package:pass_gen/domain/usecases/auth/change_pin_usecase.dart';

import 'change_pin_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late ChangePinUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ChangePinUseCase(mockRepository);
  });

  group('ChangePinUseCase', () {
    const oldPin = '1234';
    const newPin = '5678';

    test('должен успешно сменить PIN', () async {
      // Arrange
      when(mockRepository.changePin(oldPin, newPin))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(oldPin, newPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.changePin(oldPin, newPin)).called(1);
    });

    test('должен вернуть false при неверном старом PIN', () async {
      // Arrange
      when(mockRepository.changePin(oldPin, newPin))
          .thenAnswer((_) async => const Right(false));

      // Act
      final result = await useCase.execute(oldPin, newPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isFalse);
    });

    test('должен вернуть ошибку при пустом старом PIN', () async {
      // Arrange
      when(mockRepository.changePin('', newPin))
          .thenAnswer((_) async => const Left<AuthFailure, bool>(AuthFailure(message: 'Старый PIN не может быть пустым')));

      // Act
      final result = await useCase.execute('', newPin);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('Старый PIN не может быть пустым'));
    });

    test('должен вернуть ошибку при пустом новом PIN', () async {
      // Arrange
      when(mockRepository.changePin(oldPin, ''))
          .thenAnswer((_) async => const Left<AuthFailure, bool>(AuthFailure(message: 'Новый PIN не может быть пустым')));

      // Act
      final result = await useCase.execute(oldPin, '');

      // Assert
      expect(result, isA<Left>());
    });

    test('должен вызвать repository.changePin с правильными параметрами', () async {
      // Arrange
      when(mockRepository.changePin(oldPin, newPin))
          .thenAnswer((_) async => const Right(true));

      // Act
      await useCase.execute(oldPin, newPin);

      // Assert
      verify(mockRepository.changePin(oldPin, newPin)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
