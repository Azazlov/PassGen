import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/event_types.dart';
import '../../../core/security/master_password_session.dart';
import '../../../domain/entities/character_set.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/entities/password_generation_settings.dart';
import '../../../domain/entities/password_result.dart';
import '../../../domain/repositories/password_generator_repository.dart';
import '../../../domain/usecases/generator/validate_generator_settings_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';
import '../../../domain/usecases/password/generate_password_usecase.dart';
import '../../../domain/usecases/password/save_password_usecase.dart';
import '../../../domain/usecases/storage/get_passwords_usecase.dart';

/// Конфигурация уровня сложности пароля
class StrengthConfig {
  const StrengthConfig({required this.label, required this.colorIndex});

  final String label;
  final int colorIndex;
}

/// Контроллер для экрана генератора паролей
class GeneratorController extends ChangeNotifier {
  GeneratorController({
    required this.generatePasswordUseCase,
    required this.savePasswordUseCase,
    required this.validateSettingsUseCase,
    required this.logEventUseCase,
    required this.repository,
    required this.getPasswordsUseCase,
  }) {
    _updateSettingsByStrength(_strength);
    _updateControllersFromSettings();
  }
  final GeneratePasswordUseCase generatePasswordUseCase;
  final SavePasswordUseCase savePasswordUseCase;
  final ValidateGeneratorSettingsUseCase validateSettingsUseCase;
  final LogEventUseCase logEventUseCase;
  final PasswordGeneratorRepository repository;
  final GetPasswordsUseCase getPasswordsUseCase;

  // Состояние
  PasswordGenerationSettings _settings = const PasswordGenerationSettings();
  PasswordResult? _lastResult;
  bool _isLoading = false;
  String? _error;

  // Rate limiting для защиты от DoS
  static const int _maxGenerationsPerMinute = 60;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const Duration _minimumGenerationDuration = Duration(
    milliseconds: 250,
  );
  final List<DateTime> _generationTimestamps = [];

  // Текстовые контроллеры
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController minLengthController = TextEditingController();
  final TextEditingController maxLengthController = TextEditingController();

  // Выбор категории
  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  void updateSelectedCategoryId(int? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  // Геттеры
  int get strength => _strength;
  PasswordGenerationSettings get settings => _settings;
  PasswordResult? get lastResult => _lastResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get password => _lastResult?.password ?? '';
  String get config => _lastResult?.config ?? '';
  double get strengthValue => _lastResult?.strength ?? 0.0;
  double get evaluatedStrengthValue =>
      (_lastResult?.strength ?? (_strength / 4.0)).clamp(0.0, 1.0);

  // Уровень сложности
  int _strength = AppConstants.defaultPasswordStrength;

  String get strengthLabel {
    return strengthConfigs[_strength]?.label ?? 'Неизвестная сложность';
  }

  Color get strengthColor {
    final colorIndex = strengthConfigs[_strength]!.colorIndex;
    return strengthColors[colorIndex];
  }

  String get evaluatedStrengthLabel {
    final value = evaluatedStrengthValue;
    if (value < 0.2) return 'Очень слабый';
    if (value < 0.4) return 'Слабый';
    if (value < 0.6) return 'Средний';
    if (value < 0.8) return 'Надёжный';
    return 'Очень надёжный';
  }

  Color get evaluatedStrengthColor {
    final value = evaluatedStrengthValue;
    if (value < 0.2) return strengthColors[0];
    if (value < 0.4) return strengthColors[1];
    if (value < 0.6) return strengthColors[2];
    if (value < 0.8) return strengthColors[3];
    return strengthColors[4];
  }

  // Переключатели обязательности символов
  bool get requireUppercase => _settings.requireUppercase;
  bool get requireLowercase => _settings.requireLowercase;
  bool get requireDigits => _settings.requireDigits;
  bool get requireSymbols => _settings.requireSymbols;
  bool get excludeSimilar => _settings.excludeSimilar;
  bool get allUnique => _settings.allUnique;
  bool get useCustomLowercase => _settings.useCustomLowercase;
  bool get useCustomUppercase => _settings.useCustomUppercase;
  bool get useCustomDigits => _settings.useCustomDigits;
  bool get useCustomSymbols => _settings.useCustomSymbols;

  /// Конфигурация уровней сложности пароля
  static const Map<int, StrengthConfig> strengthConfigs = {
    0: StrengthConfig(label: 'Очень слабый', colorIndex: 0),
    1: StrengthConfig(label: 'Слабый', colorIndex: 1),
    2: StrengthConfig(label: 'Средний', colorIndex: 2),
    3: StrengthConfig(label: 'Надёжный', colorIndex: 3),
    4: StrengthConfig(label: 'Очень надёжный', colorIndex: 4),
  };

  /// Конфигурация уровня сложности
  static const List<Color> strengthColors = [
    Colors.red, // 0: Очень слабый
    Colors.orange, // 1: Слабый
    Color.fromARGB(255, 215, 223, 52), // 2: Средний
    Colors.green, // 3: Надёжный
    Colors.blue, // 4: Очень надёжный
  ];

  /// Обновляет уровень сложности
  void updateStrength(int value) {
    _strength = value;
    _updateSettingsByStrength(value);
    _updateControllersFromSettings();
    generatePassword();
  }

  /// Переключает опцию "Исключить похожие символы"
  void toggleExcludeSimilar(bool value) {
    _settings = _settings.copyWith(excludeSimilar: value);
    generatePassword();
  }

  /// Переключает опцию "Без повторяющихся символов" (уникальные символы)
  void toggleAllUnique(bool value) {
    _settings = _settings.copyWith(allUnique: value);
    generatePassword();
  }

  /// Переключает использование строчных букв
  void toggleUseLowercase(bool value) {
    _settings = _settings.copyWith(useCustomLowercase: value);
    generatePassword();
  }

  /// Переключает использование заглавных букв
  void toggleUseUppercase(bool value) {
    _settings = _settings.copyWith(useCustomUppercase: value);
    generatePassword();
  }

  /// Переключает использование цифр
  void toggleUseDigits(bool value) {
    _settings = _settings.copyWith(useCustomDigits: value);
    generatePassword();
  }

  /// Переключает использование спецсимволов
  void toggleUseSymbols(bool value) {
    _settings = _settings.copyWith(useCustomSymbols: value);
    generatePassword();
  }

  /// Обновляет настройки на основе уровня сложности
  void _updateSettingsByStrength(int strength) {
    final flags =
        PasswordFlags.strengthFlags[strength] ??
        PasswordFlags.strengthFlags[2]!;
    final lengthRange =
        PasswordFlags.strengthLengthRanges[strength] ??
        PasswordFlags.strengthLengthRanges[2]!;

    _settings = PasswordGenerationSettings(
      strength: strength,
      lengthRange: lengthRange,
      flags: flags,
      requireUppercase: (flags & PasswordFlags.uppercaseRequired) != 0,
      requireLowercase: (flags & PasswordFlags.lowercaseRequired) != 0,
      requireDigits: (flags & PasswordFlags.digitsRequired) != 0,
      requireSymbols: (flags & PasswordFlags.symbolsRequired) != 0,
    );
  }

  /// Обновляет текстовые контроллеры из настроек
  void _updateControllersFromSettings() {
    minLengthController.text = _settings.lengthRange.first.toString();
    maxLengthController.text = _settings.lengthRange.last.toString();
  }

  /// Переключает флаг обязательности символа
  void toggleRequireUppercase(bool value) {
    _settings = _settings.copyWith(
      requireUppercase: value,
      flags: _updateFlags(
        _settings.flags,
        PasswordFlags.uppercase,
        PasswordFlags.uppercaseRequired,
        value,
      ),
    );
    generatePassword();
  }

  void toggleRequireLowercase(bool value) {
    _settings = _settings.copyWith(
      requireLowercase: value,
      flags: _updateFlags(
        _settings.flags,
        PasswordFlags.lowercase,
        PasswordFlags.lowercaseRequired,
        value,
      ),
    );
    generatePassword();
  }

  void toggleRequireDigits(bool value) {
    _settings = _settings.copyWith(
      requireDigits: value,
      flags: _updateFlags(
        _settings.flags,
        PasswordFlags.digits,
        PasswordFlags.digitsRequired,
        value,
      ),
    );
    generatePassword();
  }

  void toggleRequireSymbols(bool value) {
    _settings = _settings.copyWith(
      requireSymbols: value,
      flags: _updateFlags(
        _settings.flags,
        PasswordFlags.symbols,
        PasswordFlags.symbolsRequired,
        value,
      ),
    );
    generatePassword();
  }

  /// Обновляет флаги
  int _updateFlags(
    int flags,
    int categoryFlag,
    int requiredFlag,
    bool isEnabled,
  ) {
    if (isEnabled) {
      return flags | categoryFlag | requiredFlag;
    } else {
      return flags & ~categoryFlag & ~requiredFlag;
    }
  }

  /// Обновляет диапазон длин
  void updateLengthRange(int min, int max) {
    if (min > max || min < 1 || max > 64) {
      _error = 'Недопустимый диапазон длин';
      notifyListeners();
      return;
    }

    _error = null;
    _settings = _settings.copyWith(lengthRange: [min, max]);
    _updateControllersFromSettings();
    notifyListeners();
  }

  /// Завершает изменение диапазона длин и генерирует пароль
  void finishLengthRange(int min, int max) {
    updateLengthRange(min, max);
    generatePassword();
  }

  /// Генерирует новый пароль
  Future<void> generatePassword() async {
    if (_isLoading) return;
    final startedAt = DateTime.now();

    // Rate limiting check
    final now = DateTime.now();
    _generationTimestamps.removeWhere(
      (t) => now.difference(t) > _rateLimitWindow,
    );
    if (_generationTimestamps.length >= _maxGenerationsPerMinute) {
      _error = 'Слишком много запросов. Подождите минуту.';
      notifyListeners();
      return;
    }
    _generationTimestamps.add(now);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Парсим длину из контроллеров
      final min =
          int.tryParse(minLengthController.text) ?? _settings.lengthRange.first;
      final max =
          int.tryParse(maxLengthController.text) ?? _settings.lengthRange.last;

      _settings = _settings.copyWith(lengthRange: [min, max]);

      // Валидация настроек в Domain слое
      final validationResult = validateSettingsUseCase.execute(_settings);

      await validationResult.fold<Future<void>>(
        (failure) async {
          _error = failure.message;
        },
        (validatedSettings) async {
          final result = await generatePasswordUseCase.execute(
            validatedSettings,
          );

          result.fold(
            (failure) {
              _error = failure.message;
            },
            (passwordResult) {
              _lastResult = passwordResult;
            },
          );
        },
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < _minimumGenerationDuration) {
        await Future<void>.delayed(_minimumGenerationDuration - elapsed);
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Сохраняет пароль в хранилище
  /// Возвращает true если успешно, false если ошибка
  /// updated = true если пароль был обновлён, false если создан новый
  Future<Map<String, dynamic>> savePassword() async {
    if (_lastResult == null) {
      _error = 'Сначала сгенерируйте пароль';
      notifyListeners();
      return {'success': false, 'updated': false};
    }

    final serviceValidation = _validateServiceInput(serviceController.text);
    if (serviceValidation != null) {
      _error = serviceValidation;
      notifyListeners();
      return {'success': false, 'updated': false};
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Ищем существующую запись по (service, login), чтобы передать в use case
      // entryId и старые крипто-поля — это включит запись в password_history.
      final loginText = loginController.text.trim();

      PasswordEntry? existingEntry;
      try {
        final passwordsResult = await getPasswordsUseCase.execute();
        existingEntry = passwordsResult.fold((_) => null, (entries) {
          final lowerService = serviceController.text.toLowerCase();
          for (final entry in entries) {
            final matchesService = entry.service.toLowerCase() == lowerService;
            if (!matchesService) continue;

            if (loginText.isNotEmpty) {
              final entryLogin = entry.login;
              if (entryLogin != null &&
                  entryLogin.toLowerCase() == loginText.toLowerCase()) {
                return entry;
              }
            } else {
              // если логин не задан — ищем запись без логина
              if (entry.login == null || entry.login!.isEmpty) {
                return entry;
              }
            }
          }
          return null;
        });
      } catch (_) {
        existingEntry = null;
      }

      final masterPassword = MasterPasswordSession.getAny();
      final result = await savePasswordUseCase.execute(
        service: serviceController.text,
        password: _lastResult!.password,
        config: _lastResult!.config,
        categoryId: _selectedCategoryId,
        login: loginText.isEmpty ? null : loginText,
        entryId: existingEntry?.id,
        encryptedPassword: existingEntry?.encryptedPassword,
        nonce: existingEntry?.nonce,
        masterPassword: masterPassword,
      );

      return result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return {'success': false, 'updated': false};
        },
        (data) {
          // Логируем создание пароля
          logEventUseCase.execute(
            EventTypes.pwdCreated,
            details: {
              'service': serviceController.text,
              'category_id': _selectedCategoryId,
            },
          );

          // data может быть Map из dataSource или bool из repository
          return data;
        },
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'updated': false};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    serviceController.dispose();
    loginController.dispose();
    minLengthController.dispose();
    maxLengthController.dispose();
    super.dispose();
  }

  /// Валидирует ввод service/login
  ///
  /// Защита от:
  /// - XSS (при отображении в WebView)
  /// - SQL injection (если в будущем будет DB)
  /// - Спецсимволов, которые могут сломать парсинг
  String? _validateServiceInput(String input) {
    if (input.isEmpty) {
      return 'Укажите сервис для сохранения пароля';
    }

    if (input.length > 100) {
      return 'Название сервиса слишком длинное (макс. 100 символов)';
    }

    // Запрещённые символы которые могут сломать формат
    final forbiddenChars = RegExp(r'[\x00-\x1F\x7F]');
    if (forbiddenChars.hasMatch(input)) {
      return 'Название сервиса содержит недопустимые символы';
    }

    return null;
  }

  /// Получает наборы символов из репозитория
  Future<List<CharacterSet>> getCharacterSets() {
    return repository.getCharacterSets(settings: _settings);
  }
}
