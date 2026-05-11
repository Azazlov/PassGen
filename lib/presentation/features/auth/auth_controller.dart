import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/event_types.dart';
import '../../../core/security/master_password_session.dart';
import '../../../domain/entities/auth_result.dart';
import '../../../domain/entities/auth_state.dart';
import '../../../domain/repositories/biometric_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/services/vault_unlock_service.dart';
import '../../../domain/usecases/auth/change_pin_usecase.dart';
import '../../../domain/usecases/auth/get_auth_state_usecase.dart';
import '../../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../../domain/usecases/auth/setup_pin_usecase.dart';
import '../../../domain/usecases/auth/verify_pin_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';

/// Контроллер для экрана аутентификации (v0.6 — per-profile + biometric)
class AuthController extends ChangeNotifier {
  AuthController({
    required this.setupPinUseCase,
    required this.verifyPinUseCase,
    required this.changePinUseCase,
    required this.removePinUseCase,
    required this.getAuthStateUseCase,
    required this.logEventUseCase,
    this.biometricRepository,
    this.profileRepository,
    this.vaultUnlockService,
  }) {
    _loadAuthState();
  }
  final SetupPinUseCase setupPinUseCase;
  final VerifyPinUseCase verifyPinUseCase;
  final ChangePinUseCase changePinUseCase;
  final RemovePinUseCase removePinUseCase;
  final GetAuthStateUseCase getAuthStateUseCase;
  final LogEventUseCase logEventUseCase;
  final BiometricRepository? biometricRepository;
  final ProfileRepository? profileRepository;
  final VaultUnlockService? vaultUnlockService;

  // Таймер неактивности
  Timer? _inactivityTimer;
  static const Duration inactivityTimeout = Duration(minutes: 5);

  // Состояние
  AuthState _authState = const AuthState();
  bool _isLoading = false;
  String? _error;
  bool _isSetupMode = false;

  // Для ввода PIN
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _enteredPin = '';

  // Геттеры
  AuthState get authState => _authState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSetupMode => _isSetupMode;
  TextEditingController get pinController => _pinController;
  TextEditingController get confirmPinController => _confirmPinController;
  String get enteredPin => _enteredPin;

  int get pinLength => _enteredPin.length;
  bool get isPinComplete => _enteredPin.length >= 4;

  /// Доступна ли биометрия для текущего профиля
  bool get isBiometricAvailableForProfile =>
      _authState.isBiometricAvailable && _authState.isBiometricEnabled;

  /// Загружает состояние аутентификации
  Future<void> _loadAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Небольшая задержка чтобы дать БД инициализироваться
      await Future.delayed(const Duration(milliseconds: 100));

      _authState = await getAuthStateUseCase.execute();
      _isSetupMode = !_authState.isPinSetup;
    } catch (e) {
      _error = 'Ошибка загрузки состояния: $e';
      // Если ошибка - считаем что PIN не установлен
      _authState = const AuthState(
        isPinSetup: false,
        isAuthenticated: false,
        isLocked: false,
      );
      _isSetupMode = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Устанавливает текущий профиль и обновляет состояние
  Future<void> setCurrentProfile(int profileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await profileRepository?.setActiveProfile(profileId);
      await _loadAuthState();
    } catch (e) {
      _error = 'Ошибка переключения профиля: $e';
      notifyListeners();
    }
  }

  /// Обрабатывает ввод цифры PIN
  void addDigit(String digit) {
    if (_enteredPin.length < 8) {
      _enteredPin += digit;
      // Вибрация при вводе (тактильная обратная связь)
      HapticFeedback.lightImpact();
      notifyListeners();
    }
  }

  /// Удаляет последнюю цифру PIN
  void removeDigit() {
    if (_enteredPin.isNotEmpty) {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      notifyListeners();
    }
  }

  /// Очищает введённый PIN
  void clearPin() {
    _enteredPin = '';
    notifyListeners();
  }

  /// Устанавливает новый PIN
  Future<bool> setupPin() async {
    if (_enteredPin.length < 4 || _enteredPin.length > 8) {
      _error = 'PIN должен содержать от 4 до 8 цифр';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await setupPinUseCase.execute(_enteredPin);
      return result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            _authState = _authState.copyWith(
              isPinSetup: true,
              isAuthenticated: false, // ← ОСТАВЛЯЕМ false для проверки входа
            );
            _isSetupMode = false;
            _enteredPin = ''; // Очищаем PIN для нового ввода
            // Логируем установку PIN
            await logEventUseCase.execute(
              EventTypes.pinSetup,
              profileId: _authState.currentProfileId,
            );
          }
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _error = 'Ошибка установки PIN: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Проверяет PIN
  Future<AuthResult> verifyPin() async {
    if (_enteredPin.length < 4 || _enteredPin.length > 8) {
      _error = 'Введите PIN';
      notifyListeners();
      return AuthResult.wrongPin;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await verifyPinUseCase.execute(_enteredPin);

      final authResult = result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return AuthResult.wrongPin;
        },
        (authResult) {
          if (authResult == AuthResult.success) {
            final profileId = _authState.currentProfileId ?? 1;
            final pinForSession = _enteredPin;
            MasterPasswordSession.setForProfile(
              profileId: profileId,
              pin: pinForSession,
            );
            // Разблокируем vault-ключ профиля и лениво дошифровываем
            // старые plaintext-метаданные. Ошибки не блокируют вход.
            unawaited(
              vaultUnlockService
                      ?.unlockWithPin(profileId: profileId, pin: pinForSession)
                      .catchError((_) => 0) ??
                  Future.value(0),
            );
            _authState = _authState.copyWith(
              isAuthenticated: true,
              isLocked: false,
            );
            _enteredPin = '';

            logEventUseCase.execute(
              EventTypes.authSuccess,
              profileId: _authState.currentProfileId,
            );
          } else if (authResult == AuthResult.wrongPin) {
            _refreshStateSilent();
            logEventUseCase.execute(
              EventTypes.authFailure,
              details: {'attempt': _authState.remainingAttempts},
              profileId: _authState.currentProfileId,
            );
          } else if (authResult == AuthResult.locked) {
            _refreshStateSilent();
            logEventUseCase.execute(
              EventTypes.authLockout,
              profileId: _authState.currentProfileId,
            );
          }
          notifyListeners();
          return authResult;
        },
      );

      return authResult;
    } catch (e) {
      _error = 'Ошибка проверки PIN: $e';
      notifyListeners();
      return AuthResult.wrongPin;
    } finally {
      _isLoading = false;
    }
  }

  /// Аутентификация по биометрии
  Future<AuthResult> authenticateWithBiometric() async {
    if (biometricRepository == null) return AuthResult.wrongPin;
    if (!await biometricRepository!.isAvailable()) return AuthResult.wrongPin;
    if (!await biometricRepository!.isEnabledForProfile(
      _authState.currentProfileId ?? 1,
    )) {
      return AuthResult.wrongPin;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authenticated = await biometricRepository!.authenticate(
        localizedReason: 'Подтвердите личность для входа в PassGen',
      );

      if (!authenticated) {
        _isLoading = false;
        notifyListeners();
        return AuthResult.wrongPin;
      }

      final retrievedPin = await biometricRepository!.retrievePinForProfile(
        _authState.currentProfileId ?? 1,
      );

      if (retrievedPin == null || retrievedPin.isEmpty) {
        _error = 'PIN не найден в защищённом хранилище';
        _isLoading = false;
        notifyListeners();
        return AuthResult.wrongPin;
      }

      // Используем retrievedPin для обычной верификации
      final result = await verifyPinUseCase.execute(retrievedPin);

      final authResult = result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return AuthResult.wrongPin;
        },
        (authResult) {
          if (authResult == AuthResult.success) {
            final profileId = _authState.currentProfileId ?? 1;
            MasterPasswordSession.setForProfile(
              profileId: profileId,
              pin: retrievedPin,
            );
            unawaited(
              vaultUnlockService
                      ?.unlockWithPin(profileId: profileId, pin: retrievedPin)
                      .catchError((_) => 0) ??
                  Future.value(0),
            );
            _authState = _authState.copyWith(
              isAuthenticated: true,
              isLocked: false,
            );
            logEventUseCase.execute(
              EventTypes.authSuccess,
              details: {'method': 'biometric'},
              profileId: _authState.currentProfileId,
            );
          }
          notifyListeners();
          return authResult;
        },
      );

      return authResult;
    } catch (e) {
      _error = 'Ошибка биометрической аутентификации: $e';
      notifyListeners();
      return AuthResult.wrongPin;
    } finally {
      _isLoading = false;
    }
  }

  /// Включает биометрию для текущего профиля
  Future<bool> enableBiometric(String pin) async {
    if (biometricRepository == null) return false;
    if (_authState.currentProfileId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await biometricRepository!.enableForProfile(
        _authState.currentProfileId!,
        pin,
      );
      if (success) {
        _authState = _authState.copyWith(isBiometricEnabled: true);
        await logEventUseCase.execute(
          EventTypes.pinSetup,
          details: {'action': 'enable_biometric'},
          profileId: _authState.currentProfileId,
        );
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Ошибка включения биометрии: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Отключает биометрию для текущего профиля
  Future<bool> disableBiometric() async {
    if (biometricRepository == null) return false;
    if (_authState.currentProfileId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await biometricRepository!.disableForProfile(_authState.currentProfileId!);
      _authState = _authState.copyWith(isBiometricEnabled: false);
      await logEventUseCase.execute(
        EventTypes.authFailure,
        details: {'action': 'disable_biometric'},
        profileId: _authState.currentProfileId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка отключения биометрии: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Меняет PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await changePinUseCase.execute(oldPin, newPin);

      return result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return false;
        },
        (success) {
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _error = 'Ошибка смены PIN: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Удаляет PIN
  Future<bool> removePin(String pin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await removePinUseCase.execute(pin);

      return result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return false;
        },
        (success) {
          if (success) {
            _authState = _authState.copyWith(
              isPinSetup: false,
              isAuthenticated: false,
            );
          }
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _error = 'Ошибка удаления PIN: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Обновляет состояние (проверка блокировки)
  Future<void> refreshState() async {
    await _loadAuthState();
  }

  /// Обновляет состояние без показа loading
  Future<void> _refreshStateSilent() async {
    try {
      _authState = await getAuthStateUseCase.execute();
    } catch (_) {
      // Игнорируем ошибки silent-обновления
    }
  }

  /// Сбрасывает ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== ТАЙМЕР НЕАКТИВНОСТИ ====================

  /// Запускает таймер неактивности
  void startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, _lockApp);
  }

  /// Сбрасывает таймер неактивности
  void resetInactivityTimer() {
    if (_authState.isAuthenticated) {
      startInactivityTimer();
    }
  }

  /// Блокирует приложение
  void _lockApp() {
    MasterPasswordSession.clear();
    vaultUnlockService?.lock();
    _authState = const AuthState(
      isAuthenticated: false,
      isPinSetup: true,
      isLocked: false,
      remainingAttempts: null,
      lockoutUntil: null,
    );
    _inactivityTimer?.cancel();
    notifyListeners();

    // Логируем блокировку
    logEventUseCase.execute(
      EventTypes.authFailure,
      details: {'reason': 'inactivity_timeout'},
      profileId: _authState.currentProfileId,
    );
  }

  /// Проверяет состояние блокировки
  bool get isLocked => !_authState.isAuthenticated;

  @override
  void dispose() {
    MasterPasswordSession.clear();
    vaultUnlockService?.lock();
    _pinController.dispose();
    _confirmPinController.dispose();
    _enteredPin = '';
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
