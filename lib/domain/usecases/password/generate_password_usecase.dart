import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../entities/password_generation_settings.dart';
import '../../entities/password_result.dart';
import '../../repositories/password_generator_repository.dart';

/// Использование: Генерация пароля
class GeneratePasswordUseCase {
  const GeneratePasswordUseCase(this.repository);
  final PasswordGeneratorRepository repository;

  Future<Either<PasswordGenerationFailure, PasswordResult>> execute(
    PasswordGenerationSettings settings,
  ) async {
    return repository.generatePassword(settings);
  }

  /// Получение настроек по уровню сложности
  static PasswordGenerationSettings getSettingsByStrength(int strength) {
    final flags =
        PasswordFlags.strengthFlags[strength] ??
        PasswordFlags.strengthFlags[2]!;
    final lengthRange =
        PasswordFlags.strengthLengthRanges[strength] ??
        PasswordFlags.strengthLengthRanges[2]!;

    return PasswordGenerationSettings(
      strength: strength,
      lengthRange: lengthRange,
      flags: flags,
      requireUppercase: (flags & PasswordFlags.uppercaseRequired) != 0,
      requireLowercase: (flags & PasswordFlags.lowercaseRequired) != 0,
      requireDigits: (flags & PasswordFlags.digitsRequired) != 0,
      requireSymbols: (flags & PasswordFlags.symbolsRequired) != 0,
      allUnique: (flags & PasswordFlags.allUnique) != 0,
    );
  }
}
