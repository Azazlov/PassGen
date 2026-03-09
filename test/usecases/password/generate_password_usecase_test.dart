import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/domain/entities/password_generation_settings.dart';
import 'package:pass_gen/domain/entities/password_result.dart';
import 'package:pass_gen/domain/repositories/password_generator_repository.dart';
import 'package:pass_gen/domain/usecases/password/generate_password_usecase.dart';

import 'generate_password_usecase_test.mocks.dart';

@GenerateMocks([PasswordGeneratorRepository])
void main() {
  late GeneratePasswordUseCase useCase;
  late MockPasswordGeneratorRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordGeneratorRepository();
    useCase = GeneratePasswordUseCase(mockRepository);
  });

  group('GeneratePasswordUseCase', () {
    test('должен успешно сгенерировать пароль', () async {
      // Arrange
      const settings = PasswordGenerationSettings();
      
      const expectedPassword = PasswordResult(
        password: 'TestPass123',
        strength: 85.0,
        config: 'config_string',
      );

      when(mockRepository.generatePassword(settings))
          .thenAnswer((_) async => const Right(expectedPassword));

      // Act
      final result = await useCase.execute(settings);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value.password, equals('TestPass123'));
      verify(mockRepository.generatePassword(settings)).called(1);
    });

    test('должен вернуть ошибку при неудачной генерации', () async {
      // Arrange
      const settings = PasswordGenerationSettings();
      
      when(mockRepository.generatePassword(settings))
          .thenAnswer((_) async => const Left(PasswordGenerationFailure(message: 'Ошибка генерации')));

      // Act
      final result = await useCase.execute(settings);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('Ошибка генерации'));
    });

    test('должен вызвать repository.generatePassword', () async {
      // Arrange
      const settings = PasswordGenerationSettings();
      
      when(mockRepository.generatePassword(settings))
          .thenAnswer((_) async => const Right(PasswordResult(password: 'pass', strength: 50, config: '')));

      // Act
      await useCase.execute(settings);

      // Assert
      verify(mockRepository.generatePassword(settings)).called(1);
    });
  });
}
