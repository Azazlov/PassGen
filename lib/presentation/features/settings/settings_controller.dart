import 'package:flutter/material.dart';
import '../../../core/constants/event_types.dart';
import '../../../domain/usecases/settings/get_setting_usecase.dart';
import '../../../domain/usecases/settings/set_setting_usecase.dart';
import '../../../domain/usecases/auth/change_pin_usecase.dart';
import '../../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../../domain/usecases/log/get_logs_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';

/// Контроллер экрана настроек
class SettingsController extends ChangeNotifier {
  final GetSettingUseCase _getSettingUseCase;
  final SetSettingUseCase _setSettingUseCase;
  final ChangePinUseCase _changePinUseCase;
  final RemovePinUseCase _removePinUseCase;
  final GetLogsUseCase _getLogsUseCase;
  final LogEventUseCase _logEventUseCase;

  SettingsController({
    required GetSettingUseCase getSettingUseCase,
    required SetSettingUseCase setSettingUseCase,
    required ChangePinUseCase changePinUseCase,
    required RemovePinUseCase removePinUseCase,
    required GetLogsUseCase getLogsUseCase,
    required LogEventUseCase logEventUseCase,
  })  : _getSettingUseCase = getSettingUseCase,
        _setSettingUseCase = setSettingUseCase,
        _changePinUseCase = changePinUseCase,
        _removePinUseCase = removePinUseCase,
        _getLogsUseCase = getLogsUseCase,
        _logEventUseCase = logEventUseCase;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Получение настройки
  Future<String?> getSetting(String key) async {
    try {
      return await _getSettingUseCase.execute(key);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Сохранение настройки
  Future<void> setSetting(String key, String value, {bool encrypted = false}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _setSettingUseCase.execute(key, value, encrypted: encrypted);
      
      // Логирование изменения настроек (SETTINGS_CHG)
      _logEventUseCase.execute(
        EventTypes.settingsChanged,
        details: {
          'key': key,
          'value': value,
          'encrypted': encrypted,
        },
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Смена PIN-кода
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await _changePinUseCase.execute(oldPin, newPin);
      
      // Логирование смены PIN
      result.fold(
        (_) => null,
        (_) => _logEventUseCase.execute(
          EventTypes.pinChanged,
          details: {'success': true},
        ),
      );
      
      return result.fold(
        (failure) => false,
        (_) => true,
      );
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Удаление PIN-кода
  Future<bool> removePin(String pin) async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await _removePinUseCase.execute(pin);
      
      // Логирование удаления PIN
      result.fold(
        (_) => null,
        (_) => _logEventUseCase.execute(
          EventTypes.pinRemoved,
          details: {'success': true},
        ),
      );
      
      return result.fold(
        (failure) => false,
        (_) => true,
      );
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Получение количества логов
  Future<int> getLogsCount() async {
    try {
      final logs = await _getLogsUseCase.execute(limit: 1);
      return logs.length;
    } catch (e) {
      return 0;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
