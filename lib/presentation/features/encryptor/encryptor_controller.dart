import 'package:flutter/material.dart';
import '../../../domain/usecases/encryptor/encrypt_message_usecase.dart';
import '../../../domain/usecases/encryptor/decrypt_message_usecase.dart';

/// Контроллер для экрана шифратора/дешифратора
class EncryptorController extends ChangeNotifier {
  final EncryptMessageUseCase encryptUseCase;
  final DecryptMessageUseCase decryptUseCase;

  EncryptorController({
    required this.encryptUseCase,
    required this.decryptUseCase,
  });

  // Текстовые контроллеры
  final TextEditingController messageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Состояние
  String _result = '';
  bool _isLoading = false;
  String? _error;
  bool _isEncryptMode = true;

  // Геттеры
  String get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEncryptMode => _isEncryptMode;

  String get resultLabel => _isEncryptMode ? 'Скопировать шифр' : 'Скопировать сообщение';

  /// Переключает режим (шифрование/дешифрование)
  void toggleMode() {
    _isEncryptMode = !_isEncryptMode;
    _result = '';
    _error = null;
    notifyListeners();
  }

  /// Шифрует сообщение
  Future<void> encrypt() async {
    if (_isLoading) return;

    final message = messageController.text.trim();
    final password = passwordController.text.trim();

    if (message.isEmpty) {
      _error = 'Сообщение не должно быть пустым';
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      _error = 'Пароль не должен быть пустым';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final eitherResult = await encryptUseCase.execute(
        message: message,
        password: password,
      );

      eitherResult.fold(
        (failure) {
          _error = failure.message;
        },
        (encrypted) {
          _result = encrypted;
        },
      );
    } catch (e) {
      _error = 'Ошибка шифрования: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Дешифрует сообщение
  Future<void> decrypt() async {
    if (_isLoading) return;

    final encryptedData = messageController.text.trim();
    final password = passwordController.text.trim();

    if (encryptedData.isEmpty) {
      _error = 'Зашифрованные данные не должны быть пустыми';
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      _error = 'Пароль не должен быть пустым';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final eitherResult = await decryptUseCase.execute(
        encryptedData: encryptedData,
        password: password,
      );

      eitherResult.fold(
        (failure) {
          _error = failure.message;
        },
        (decrypted) {
          _result = decrypted;
        },
      );
    } catch (e) {
      _error = 'Ошибка дешифрования: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Выполняет текущую операцию
  Future<void> execute() async {
    if (_isEncryptMode) {
      await encrypt();
    } else {
      await decrypt();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
