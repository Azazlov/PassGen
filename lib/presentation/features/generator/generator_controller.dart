import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/event_types.dart';
import '../../../domain/entities/password_generation_settings.dart';
import '../../../domain/entities/password_result.dart';
import '../../../domain/usecases/password/generate_password_usecase.dart';
import '../../../domain/usecases/password/save_password_usecase.dart';
import '../../../domain/usecases/generator/validate_generator_settings_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';

/// Контроллер для экрана генератора паролей
class GeneratorController extends ChangeNotifier {
  final GeneratePasswordUseCase generatePasswordUseCase;
  final SavePasswordUseCase savePasswordUseCase;
  final ValidateGeneratorSettingsUseCase validateSettingsUseCase;
  final LogEventUseCase logEventUseCase;

  GeneratorController({
    required this.generatePasswordUseCase,
    required this.savePasswordUseCase,
    required this.validateSettingsUseCase,
    required this.logEventUseCase,
  }) {
    _updateSettingsByStrength(_strength);
  }

  // Состояние
  PasswordGenerationSettings _settings = const PasswordGenerationSettings();
  PasswordResult? _lastResult;
  bool _isLoading = false;
  String? _error;

  // Текстовые контроллеры
  final TextEditingController serviceController = TextEditingController();
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

  // Уровень сложности
  int _strength = AppConstants.defaultPasswordStrength;

  String get strengthLabel {
    return PasswordFlags.strengthLabels[_strength] ?? 'Неизвестная сложность';
  }

  Color get strengthColor {
    switch (_strength) {
      case 0: return Colors.red;
      case 1: return Colors.orange;
      case 2: return const Color.fromARGB(255, 215, 223, 52);
      case 3: return Colors.green;
      case 4: return Colors.blue;
      default: return Colors.grey;
    }
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

  /// Обновляет уровень сложности
  void updateStrength(int value) {
    _strength = value;
    _updateSettingsByStrength(value);
    _updateControllersFromSettings();
    notifyListeners();
  }

  /// Переключает опцию "Исключить похожие символы"
  void toggleExcludeSimilar(bool value) {
    _settings = _settings.copyWith(excludeSimilar: value);
    notifyListeners();
  }

  /// Переключает опцию "Без повторяющихся символов" (уникальные символы)
  void toggleAllUnique(bool value) {
    _settings = _settings.copyWith(allUnique: value);
    notifyListeners();
  }

  /// Переключает использование строчных букв
  void toggleUseLowercase(bool value) {
    _settings = _settings.copyWith(useCustomLowercase: value);
    notifyListeners();
  }

  /// Переключает использование заглавных букв
  void toggleUseUppercase(bool value) {
    _settings = _settings.copyWith(useCustomUppercase: value);
    notifyListeners();
  }

  /// Переключает использование цифр
  void toggleUseDigits(bool value) {
    _settings = _settings.copyWith(useCustomDigits: value);
    notifyListeners();
  }

  /// Переключает использование спецсимволов
  void toggleUseSymbols(bool value) {
    _settings = _settings.copyWith(useCustomSymbols: value);
    notifyListeners();
  }

  /// Обновляет настройки на основе уровня сложности
  void _updateSettingsByStrength(int strength) {
    final flags = PasswordFlags.strengthFlags[strength] ?? PasswordFlags.strengthFlags[2]!;
    final lengthRange = PasswordFlags.strengthLengthRanges[strength] ?? PasswordFlags.strengthLengthRanges[2]!;

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
      flags: _updateFlags(_settings.flags, PasswordFlags.uppercase, PasswordFlags.uppercaseRequired, value),
    );
    notifyListeners();
  }

  void toggleRequireLowercase(bool value) {
    _settings = _settings.copyWith(
      requireLowercase: value,
      flags: _updateFlags(_settings.flags, PasswordFlags.lowercase, PasswordFlags.lowercaseRequired, value),
    );
    notifyListeners();
  }

  void toggleRequireDigits(bool value) {
    _settings = _settings.copyWith(
      requireDigits: value,
      flags: _updateFlags(_settings.flags, PasswordFlags.digits, PasswordFlags.digitsRequired, value),
    );
    notifyListeners();
  }

  void toggleRequireSymbols(bool value) {
    _settings = _settings.copyWith(
      requireSymbols: value,
      flags: _updateFlags(_settings.flags, PasswordFlags.symbols, PasswordFlags.symbolsRequired, value),
    );
    notifyListeners();
  }

  /// Обновляет флаги
  int _updateFlags(int flags, int categoryFlag, int requiredFlag, bool isEnabled) {
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

    _settings = _settings.copyWith(
      lengthRange: [min, max],
    );
    notifyListeners();
  }

  /// Генерирует новый пароль
  Future<void> generatePassword() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Парсим длину из контроллеров
      final min = int.tryParse(minLengthController.text) ?? _settings.lengthRange.first;
      final max = int.tryParse(maxLengthController.text) ?? _settings.lengthRange.last;

      _settings = _settings.copyWith(lengthRange: [min, max]);

      // Валидация настроек в Domain слое
      final validationResult = validateSettingsUseCase.execute(_settings);

      validationResult.fold(
        (failure) {
          _error = failure.message;
          _isLoading = false;
          notifyListeners();
          return;
        },
        (validatedSettings) async {
          final result = await generatePasswordUseCase.execute(validatedSettings);

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
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Сохраняет пароль в хранилище
  /// Возвращает true если успешно, false если ошибка
  /// updated = true если пароль был обновлён, false если создан новый
  Future<Map<String, dynamic>> savePassword() async {
    if (_lastResult == null || serviceController.text.isEmpty) {
      _error = 'Укажите сервис для сохранения пароля';
      notifyListeners();
      return {'success': false, 'updated': false};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await savePasswordUseCase.execute(
        service: serviceController.text,
        password: _lastResult!.password,
        config: _lastResult!.config,
        categoryId: _selectedCategoryId,
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
          if (data is Map<String, dynamic>) {
            return data;
          }
          return {'success': true, 'updated': false};
        },
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'updated': false};
    } finally {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    serviceController.dispose();
    minLengthController.dispose();
    maxLengthController.dispose();
    super.dispose();
  }
}
