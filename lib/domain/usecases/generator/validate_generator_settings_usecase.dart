import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../entities/password_generation_settings.dart';
import '../../validators/password_settings_validator.dart';

/// Use Case для валидации настроек генератора
class ValidateGeneratorSettingsUseCase {
  final PasswordSettingsValidator validator;

  const ValidateGeneratorSettingsUseCase(this.validator);

  Either<PasswordGenerationFailure, PasswordGenerationSettings> execute(
    PasswordGenerationSettings settings,
  ) {
    return validator.validate(settings);
  }
}
