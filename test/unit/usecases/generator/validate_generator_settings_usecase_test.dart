import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/generator/validate_generator_settings_usecase.dart';
import 'package:pass_gen/domain/validators/password_settings_validator.dart';
import 'package:pass_gen/domain/entities/password_generation_settings.dart';
import 'package:pass_gen/core/errors/failures.dart';

void main() {
  late ValidateGeneratorSettingsUseCase useCase;
  late PasswordSettingsValidator validator;

  setUp(() {
    validator = const PasswordSettingsValidator();
    useCase = ValidateGeneratorSettingsUseCase(validator);
  });

  group('ValidateGeneratorSettingsUseCase', () {
    test('должен вернуть успех для валидных настроек', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        strength: 2,
        lengthRange: [8, 16],
        flags: 1 | 4 | 16, // digits + lowercase + uppercase
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(settings));
    });

    test('должен вернуть ошибку при некорректной длине (мин < 1)', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        lengthRange: [0, 16],
        flags: 4,
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('от 1 до 64'));
    });

    test('должен вернуть ошибку при некорректной длине (макс > 64)', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        lengthRange: [8, 100],
        flags: 4,
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('от 1 до 64'));
    });

    test('должен вернуть ошибку, когда мин > макс', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        lengthRange: [20, 10],
        flags: 4,
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('не может быть больше'));
    });

    test('должен вернуть ошибку, если не выбрана ни одна категория', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        flags: 0,
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('хотя бы одну категорию'));
    });

    test('должен вернуть ошибку при allUnique с недостаточным количеством символов', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        lengthRange: [50, 60],
        flags: 1, // только цифры (10 символов)
        allUnique: true,
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('уникальными символами'));
    });

    test('должен принять настройки с excludeSimilar', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        lengthRange: [8, 12],
        flags: 4 | 16, // lowercase + uppercase
        excludeSimilar: true,
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Right>());
    });

    test('должен принять настройки с customCharacters', () {
      // Arrange
      const settings = PasswordGenerationSettings(
        lengthRange: [8, 12],
        flags: 0,
        customCharacters: 'ABC123',
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Right>());
    });

    test('должен принять стандартные настройки', () {
      // Arrange - стандартные настройки имеют strength=2, но flags=0
      // Поэтому нужно указать хотя бы одну категорию
      const settings = PasswordGenerationSettings(
        strength: 2,
        lengthRange: [8, 14],
        flags: 4 | 16, // lowercase + uppercase
      );

      // Act
      final result = useCase.execute(settings);

      // Assert
      expect(result, isA<Right>());
    });
  });
}
