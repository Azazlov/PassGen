import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/usecases/storage/get_passwords_usecase.dart';
import '../../../domain/usecases/storage/delete_password_usecase.dart';
import '../../../domain/usecases/storage/export_passwords_usecase.dart';
import '../../../domain/usecases/storage/import_passwords_usecase.dart';

/// Контроллер для экрана хранилища
class StorageController extends ChangeNotifier {
  final GetPasswordsUseCase getPasswordsUseCase;
  final DeletePasswordUseCase deletePasswordUseCase;
  final ExportPasswordsUseCase exportPasswordsUseCase;
  final ImportPasswordsUseCase importPasswordsUseCase;

  StorageController({
    required this.getPasswordsUseCase,
    required this.deletePasswordUseCase,
    required this.exportPasswordsUseCase,
    required this.importPasswordsUseCase,
  });

  // Состояние
  List<PasswordEntry> _passwords = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Геттеры
  List<PasswordEntry> get passwords => _passwords;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _passwords.isEmpty;
  int get passwordsCount => _passwords.length;
  PasswordEntry? get currentPassword => _currentIndex < _passwords.length ? _passwords[_currentIndex] : null;

  /// Инициализация - загрузка паролей
  Future<void> loadPasswords() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getPasswordsUseCase.execute();

      result.fold(
        (failure) {
          _error = failure.message;
          _passwords = [];
          _currentIndex = 0;
        },
        (passwordsList) {
          _passwords = passwordsList;
          _currentIndex = 0;
        },
      );
    } catch (e) {
      _error = 'Ошибка загрузки: $e';
      _passwords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Переход к следующему паролю
  void nextPassword() {
    if (_currentIndex < _passwords.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Переход к предыдущему паролю
  void prevPassword() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Удаление текущего пароля
  Future<void> deleteCurrentPassword() async {
    if (_passwords.isEmpty || _currentIndex >= _passwords.length) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await deletePasswordUseCase.execute(_currentIndex);

      result.fold(
        (failure) {
          _error = failure.message;
        },
        (_) {
          _passwords.removeAt(_currentIndex);
          if (_currentIndex >= _passwords.length) {
            _currentIndex = _passwords.isEmpty ? 0 : _passwords.length - 1;
          }
        },
      );
    } catch (e) {
      _error = 'Ошибка удаления: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Экспорт паролей в JSON
  Future<Either<StorageFailure, String>> exportPasswords() async {
    return await exportPasswordsUseCase.execute();
  }

  /// Импорт паролей из JSON
  Future<bool> importPasswords(String jsonString) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await importPasswordsUseCase.execute(jsonString);

      return result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          await loadPasswords();
          return true;
        },
      );
    } catch (e) {
      _error = 'Ошибка импорта: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }
}
