import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/password_generation_settings.dart';

/// Валидатор настроек генератора паролей
class PasswordSettingsValidator {
  const PasswordSettingsValidator();

  /// Валидирует настройки генерации
  Either<PasswordGenerationFailure, PasswordGenerationSettings> validate(
    PasswordGenerationSettings settings,
  ) {
    // Валидация длины
    final lengthValidation = _validateLength(settings);
    if (lengthValidation.isLeft()) {
      return lengthValidation;
    }

    // Валидация флагов
    final flagsValidation = _validateFlags(settings);
    if (flagsValidation.isLeft()) {
      return flagsValidation;
    }

    // Валидация уникальности
    if (settings.allUnique) {
      final uniqueValidation = _validateUniqueSettings(settings);
      if (uniqueValidation.isLeft()) {
        return uniqueValidation;
      }
    }

    return Right(settings);
  }

  /// Валидирует диапазон длин
  Either<PasswordGenerationFailure, PasswordGenerationSettings> _validateLength(
    PasswordGenerationSettings settings,
  ) {
    final lengthRange = settings.lengthRange;
    final min = lengthRange.first;
    final max = lengthRange.last;

    if (min < 1 || max > 64) {
      return Left(PasswordGenerationFailure(
        message: 'Длина пароля должна быть от 1 до 64 символов',
      ));
    }

    if (min > max) {
      return Left(PasswordGenerationFailure(
        message: 'Минимальная длина не может быть больше максимальной',
      ));
    }

    return Right(settings);
  }

  /// Валидирует флаги
  Either<PasswordGenerationFailure, PasswordGenerationSettings> _validateFlags(PasswordGenerationSettings settings) {
    final flags = settings.flags;

    // Проверка что хотя бы одна категория выбрана
    final hasCategories = (flags & 1) != 0 ||  // digits
                         (flags & 4) != 0 ||  // lowercase
                         (flags & 16) != 0 || // uppercase
                         (flags & 64) != 0;   // symbols

    if (!hasCategories && settings.customCharacters == null) {
      return Left(PasswordGenerationFailure(
        message: 'Выберите хотя бы одну категорию символов',
      ));
    }

    return Right(settings);
  }

  /// Валидирует настройки уникальности
  Either<PasswordGenerationFailure, PasswordGenerationSettings> _validateUniqueSettings(
    PasswordGenerationSettings settings,
  ) {
    // Подсчёт доступных символов
    int availableChars = 0;

    if ((settings.flags & 4) != 0) availableChars += 26; // lowercase
    if ((settings.flags & 16) != 0) availableChars += 26; // uppercase
    if ((settings.flags & 1) != 0) availableChars += 10; // digits
    if ((settings.flags & 64) != 0) availableChars += 32; // symbols

    // Исключаем похожие символы
    if (settings.excludeSimilar) {
      availableChars -= 6; // 1, l, I, 0, O, o
    }

    final maxLength = settings.lengthRange.last;

    if (settings.allUnique && maxLength > availableChars) {
      return Left(PasswordGenerationFailure(
        message: 'Невозможно сгенерировать пароль с уникальными символами: '
            'требуется $maxLength, доступно $availableChars',
      ));
    }

    return Right(settings);
  }
}
