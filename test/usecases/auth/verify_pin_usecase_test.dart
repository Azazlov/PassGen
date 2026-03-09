import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/domain/entities/auth_result.dart';
import 'package:pass_gen/domain/repositories/auth_repository.dart';
import 'package:pass_gen/domain/usecases/auth/verify_pin_usecase.dart';

import 'verify_pin_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late VerifyPinUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyPinUseCase(mockRepository);
  });

  group('VerifyPinUseCase', () {
    const testPin = '1234';

    test('должен вернуть success при правильном PIN', () async {
      // Arrange
      when(mockRepository.verifyPin(testPin))
          .thenAnswer((_) async => const Right(AuthResult.success));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(AuthResult.success));
      verify(mockRepository.verifyPin(testPin)).called(1);
    });

    test('должен вернуть wrongPin при неверном PIN', () async {
      // Arrange
      when(mockRepository.verifyPin(testPin))
          .thenAnswer((_) async => const Right(AuthResult.wrongPin));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(AuthResult.wrongPin));
      verify(mockRepository.verifyPin(testPin)).called(1);
    });

    test('должен вернуть locked после 5 неудачных попыток', () async {
      // Arrange
      when(mockRepository.verifyPin(testPin))
          .thenAnswer((_) async => const Right(AuthResult.locked));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(AuthResult.locked));
      verify(mockRepository.verifyPin(testPin)).called(1);
    });

    test('должен вызвать repository.verifyPin с правильным PIN', () async {
      // Arrange
      when(mockRepository.verifyPin(testPin))
          .thenAnswer((_) async => const Right(AuthResult.success));

      // Act
      await useCase.execute(testPin);

      // Assert
      verify(mockRepository.verifyPin(testPin)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен обработать пустой PIN', () async {
      // Arrange
      when(mockRepository.verifyPin(''))
          .thenAnswer((_) async => const Right(AuthResult.wrongPin));

      // Act
      final result = await useCase.execute('');

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(AuthResult.wrongPin));
    });
  });
}
