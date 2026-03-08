import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/auth/setup_pin_usecase.dart';
import 'package:pass_gen/domain/repositories/auth_repository.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'setup_pin_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SetupPinUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SetupPinUseCase(mockRepository);
  });

  group('SetupPinUseCase', () {
    const testPin = '1234';
    const testPinLong = '12345678';

    test('должен успешно установить PIN', () async {
      // Arrange
      when(mockRepository.setupPin(testPin))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.setupPin(testPin)).called(1);
    });

    test('должен установить длинный PIN (8 цифр)', () async {
      // Arrange
      when(mockRepository.setupPin(testPinLong))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase.execute(testPinLong);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, isTrue);
      verify(mockRepository.setupPin(testPinLong)).called(1);
    });

    test('должен вернуть ошибку при коротком PIN (< 4 цифр)', () async {
      // Arrange
      when(mockRepository.setupPin('123'))
          .thenAnswer((_) async => Left<AuthFailure, bool>(AuthFailure(message: 'PIN должен быть от 4 до 8 цифр')));

      // Act
      final result = await useCase.execute('123');

      // Assert
      expect(result, isA<Left>());
      verify(mockRepository.setupPin('123')).called(1);
    });

    test('должен вернуть ошибку при длинном PIN (> 8 цифр)', () async {
      // Arrange
      when(mockRepository.setupPin('123456789'))
          .thenAnswer((_) async => Left<AuthFailure, bool>(AuthFailure(message: 'PIN должен быть от 4 до 8 цифр')));

      // Act
      final result = await useCase.execute('123456789');

      // Assert
      expect(result, isA<Left>());
    });

    test('должен вернуть ошибку при пустом PIN', () async {
      // Arrange
      when(mockRepository.setupPin(''))
          .thenAnswer((_) async => Left<AuthFailure, bool>(AuthFailure(message: 'PIN не может быть пустым')));

      // Act
      final result = await useCase.execute('');

      // Assert
      expect(result, isA<Left>());
    });

    test('должен вызвать repository.setupPin ровно 1 раз', () async {
      // Arrange
      when(mockRepository.setupPin(testPin))
          .thenAnswer((_) async => const Right(true));

      // Act
      await useCase.execute(testPin);

      // Assert
      verify(mockRepository.setupPin(testPin)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
