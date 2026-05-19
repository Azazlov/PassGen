import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/domain/entities/character_set.dart';
import 'package:pass_gen/domain/entities/password_config.dart';
import 'package:pass_gen/domain/entities/password_entry.dart';
import 'package:pass_gen/domain/entities/password_generation_settings.dart';
import 'package:pass_gen/domain/entities/password_result.dart';
import 'package:pass_gen/domain/entities/security_log.dart';
import 'package:pass_gen/domain/repositories/password_generator_repository.dart';
import 'package:pass_gen/domain/repositories/security_log_repository.dart';
import 'package:pass_gen/domain/repositories/storage_repository.dart';
import 'package:pass_gen/domain/usecases/generator/validate_generator_settings_usecase.dart';
import 'package:pass_gen/domain/usecases/log/log_event_usecase.dart';
import 'package:pass_gen/domain/usecases/password/generate_password_usecase.dart';
import 'package:pass_gen/domain/usecases/password/save_password_usecase.dart';
import 'package:pass_gen/domain/usecases/storage/get_passwords_usecase.dart';
import 'package:pass_gen/domain/validators/password_settings_validator.dart';
import 'package:pass_gen/presentation/features/generator/generator_controller.dart';

void main() {
  late _FakePasswordGeneratorRepository passwordRepository;
  late GeneratorController controller;

  setUp(() {
    passwordRepository = _FakePasswordGeneratorRepository();
    controller = GeneratorController(
      generatePasswordUseCase: GeneratePasswordUseCase(passwordRepository),
      savePasswordUseCase: SavePasswordUseCase(passwordRepository),
      validateSettingsUseCase: const ValidateGeneratorSettingsUseCase(
        PasswordSettingsValidator(),
      ),
      logEventUseCase: LogEventUseCase(_FakeSecurityLogRepository()),
      repository: passwordRepository,
      getPasswordsUseCase: GetPasswordsUseCase(_FakeStorageRepository()),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('generatePassword ожидает завершения и сбрасывает loading', () async {
    final generation = controller.generatePassword();

    expect(controller.isLoading, isTrue);

    await generation;

    expect(controller.isLoading, isFalse);
    expect(controller.password, 'Generated123!');
    expect(passwordRepository.generateCalls, 1);
  });

  test('savePassword уведомляет UI после сброса loading', () async {
    await controller.generatePassword();
    controller.serviceController.text = 'example.com';

    final loadingStates = <bool>[];
    controller.addListener(() => loadingStates.add(controller.isLoading));

    final result = await controller.savePassword();

    expect(result['success'], isTrue);
    expect(controller.isLoading, isFalse);
    expect(loadingStates, containsAllInOrder([true, false]));
  });
}

class _FakePasswordGeneratorRepository implements PasswordGeneratorRepository {
  int generateCalls = 0;

  @override
  Future<Either<PasswordGenerationFailure, PasswordResult>> generatePassword(
    PasswordGenerationSettings settings,
  ) async {
    generateCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const Right(
      PasswordResult(
        password: 'Generated123!',
        strength: 0.8,
        config: 'config',
      ),
    );
  }

  @override
  Future<Either<PasswordGenerationFailure, Map<String, dynamic>>> savePassword({
    required String service,
    required String password,
    required String config,
    String? masterPassword,
    int? categoryId,
    String? login,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const Right({'success': true, 'updated': false});
  }

  @override
  Future<Either<PasswordGenerationFailure, PasswordConfig>>
  createPasswordConfig({
    required String service,
    required String masterPassword,
    required PasswordGenerationSettings settings,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<PasswordGenerationFailure, String>> decryptConfig(
    String encryptedConfig,
    String masterPassword,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<PasswordGenerationFailure, String>> decryptPassword(
    PasswordConfig config,
    String masterPassword,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<CharacterSet>> getCharacterSets({
    required PasswordGenerationSettings settings,
  }) async {
    return const [];
  }

  @override
  Future<Either<PasswordGenerationFailure, PasswordResult>> restorePassword(
    String config,
  ) {
    throw UnimplementedError();
  }
}

class _FakeSecurityLogRepository implements SecurityLogRepository {
  @override
  Future<void> logEvent(
    String actionType, {
    Map<String, dynamic>? details,
    int? profileId,
  }) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> clearOldLogs({int keepLast = 1000}) async {}

  @override
  Future<int> count() async {
    return 0;
  }

  @override
  Future<List<SecurityLog>> getLogs({int limit = 1000, int? profileId}) async {
    return const [];
  }

  @override
  Future<List<SecurityLog>> getLogsByType(
    String actionType, {
    int limit = 100,
    int? profileId,
  }) async {
    return const [];
  }
}

class _FakeStorageRepository implements StorageRepository {
  @override
  Future<Either<StorageFailure, List<PasswordEntry>>> getPasswords() async {
    return const Right(<PasswordEntry>[]);
  }

  @override
  Future<Either<StorageFailure, bool>> savePasswords(
    List<PasswordEntry> passwords,
  ) async {
    return const Right(true);
  }

  @override
  Future<Either<StorageFailure, bool>> removePasswordAt(int index) async {
    return const Right(true);
  }

  @override
  Future<Either<StorageFailure, bool>> updateEntry(PasswordEntry updated) async {
    return const Right(true);
  }

  @override
  Future<Either<StorageFailure, bool>> clearStorage() async {
    return const Right(true);
  }
}
