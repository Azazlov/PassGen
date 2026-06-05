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
      return const Left(
        PasswordGenerationFailure(
          message: 'Длина пароля должна быть от 1 до 64 символов',
        ),
      );
    }

    if (min > max) {
      return const Left(
        PasswordGenerationFailure(
          message: 'Минимальная длина не может быть больше максимальной',
        ),
      );
    }

    return Right(settings);
  }

  /// Валидирует флаги
  Either<PasswordGenerationFailure, PasswordGenerationSettings> _validateFlags(
    PasswordGenerationSettings settings,
  ) {
    // Глитч-режим не требует флагов символов
    if (settings.glitchSource != null && settings.glitchSource!.isNotEmpty) {
      return Right(settings);
    }

    final flags = settings.flags;

    // Проверка что хотя бы одна категория выбрана
    final hasCategories =
        (flags & 1) != 0 || // digits
        (flags & 4) != 0 || // lowercase
        (flags & 16) != 0 || // uppercase
        (flags & 64) != 0; // symbols

    if (!hasCategories && settings.customCharacters == null) {
      return const Left(
        PasswordGenerationFailure(
          message: 'Выберите хотя бы одну категорию символов',
        ),
      );
    }

    return Right(settings);
  }

  /// Валидирует настройки уникальности
  Either<PasswordGenerationFailure, PasswordGenerationSettings>
  _validateUniqueSettings(PasswordGenerationSettings settings) {
    // Если используется пользовательский набор символов
    if (settings.customCharacters != null &&
        settings.customCharacters!.isNotEmpty) {
      final availableChars = settings.customCharacters!.length;
      final maxLength = settings.lengthRange.last;

      if (settings.allUnique && maxLength > availableChars) {
        return Left(
          PasswordGenerationFailure(
            message:
                'Невозможно сгенерировать пароль с уникальными символами: '
                'требуется $maxLength, доступно $availableChars в пользовательском наборе',
          ),
        );
      }
      return Right(settings);
    }

    // Подсчёт доступных символов по категориям
    int availableChars = 0;

    // Lowercase: 26 букв
    if ((settings.flags & 4) != 0) {
      availableChars += 26;
    }
    // Uppercase: 26 букв
    if ((settings.flags & 16) != 0) {
      availableChars += 26;
    }
    // Digits: 10 цифр
    if ((settings.flags & 1) != 0) {
      availableChars += 10;
    }
    // Symbols: 20 символов (!@#%^&*_+-=[]{};:,.?)
    if ((settings.flags & 64) != 0) {
      availableChars += 20;
    }

    // Исключаем похожие символы (1, l, I, 0, O, o)
    // Точный подсчёт пересечений:
    // - Digits: '1', '0' → -2
    // - Lowercase: 'l', 'o' → -2
    // - Uppercase: 'I', 'O' → -2
    if (settings.excludeSimilar) {
      if ((settings.flags & 1) != 0) availableChars -= 2; // 1, 0
      if ((settings.flags & 4) != 0) availableChars -= 2; // l, o
      if ((settings.flags & 16) != 0) availableChars -= 2; // I, O
    }

    final maxLength = settings.lengthRange.last;

    if (settings.allUnique && maxLength > availableChars) {
      return Left(
        PasswordGenerationFailure(
          message:
              'Невозможно сгенерировать пароль с уникальными символами: '
              'требуется $maxLength, доступно $availableChars символов',
        ),
      );
    }

    return Right(settings);
  }
}
