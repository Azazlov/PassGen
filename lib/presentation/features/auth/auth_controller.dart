import 'package:flutter/material.dart';
import '../../../domain/entities/auth_state.dart';
import '../../../domain/entities/auth_result.dart';
import '../../../domain/usecases/auth/setup_pin_usecase.dart';
import '../../../domain/usecases/auth/verify_pin_usecase.dart';
import '../../../domain/usecases/auth/change_pin_usecase.dart';
import '../../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../../domain/usecases/auth/get_auth_state_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';
import '../../../core/constants/event_types.dart';

/// Контроллер для экрана аутентификации
class AuthController extends ChangeNotifier {
  final SetupPinUseCase setupPinUseCase;
  final VerifyPinUseCase verifyPinUseCase;
  final ChangePinUseCase changePinUseCase;
  final RemovePinUseCase removePinUseCase;
  final GetAuthStateUseCase getAuthStateUseCase;
  final LogEventUseCase logEventUseCase;

  AuthController({
    required this.setupPinUseCase,
    required this.verifyPinUseCase,
    required this.changePinUseCase,
    required this.removePinUseCase,
    required this.getAuthStateUseCase,
    required this.logEventUseCase,
  }) {
    _loadAuthState();
  }

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

  /// Загружает состояние аутентификации
  Future<void> _loadAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      _authState = await getAuthStateUseCase.execute();
      _isSetupMode = !_authState.isPinSetup;
    } catch (e) {
      _error = 'Ошибка загрузки состояния: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обрабатывает ввод цифры PIN
  void addDigit(String digit) {
    if (_enteredPin.length < 8) {
      _enteredPin += digit;
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
              isAuthenticated: true,
            );
            _isSetupMode = false;
            _enteredPin = '';
            
            // Логируем установку PIN
            await logEventUseCase.execute(EventTypes.pinSetup);
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
            _authState = _authState.copyWith(
              isAuthenticated: true,
              isLocked: false,
            );
            _enteredPin = '';

            // Логируем успешный вход
            logEventUseCase.execute(EventTypes.authSuccess);
          } else if (authResult == AuthResult.wrongPin) {
            // Логируем неудачную попытку
            logEventUseCase.execute(EventTypes.authFailure, details: {
              'attempt': _authState.remainingAttempts,
            });
          } else if (authResult == AuthResult.locked) {
            // Логируем блокировку
            logEventUseCase.execute(EventTypes.authLockout);
            _loadAuthState(); // Обновляем состояние блокировки
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

  /// Сбрасывает ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _enteredPin = '';
    super.dispose();
  }
}
