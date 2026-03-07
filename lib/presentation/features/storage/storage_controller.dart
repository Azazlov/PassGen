import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/event_types.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/usecases/storage/get_passwords_usecase.dart';
import '../../../domain/usecases/storage/delete_password_usecase.dart';
import '../../../domain/usecases/storage/export_passwords_usecase.dart';
import '../../../domain/usecases/storage/import_passwords_usecase.dart';
import '../../../domain/usecases/storage/export_passgen_usecase.dart';
import '../../../domain/usecases/storage/import_passgen_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';

/// Контроллер для экрана хранилища
class StorageController extends ChangeNotifier {
  final GetPasswordsUseCase getPasswordsUseCase;
  final DeletePasswordUseCase deletePasswordUseCase;
  final ExportPasswordsUseCase exportPasswordsUseCase;
  final ImportPasswordsUseCase importPasswordsUseCase;
  final ExportPassgenUseCase exportPassgenUseCase;
  final ImportPassgenUseCase importPassgenUseCase;
  final LogEventUseCase logEventUseCase;

  StorageController({
    required this.getPasswordsUseCase,
    required this.deletePasswordUseCase,
    required this.exportPasswordsUseCase,
    required this.importPasswordsUseCase,
    required this.exportPassgenUseCase,
    required this.importPassgenUseCase,
    required this.logEventUseCase,
  });

  // Состояние
  List<PasswordEntry> _allPasswords = [];
  List<PasswordEntry> _passwords = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Фильтры
  int? _selectedCategoryId;
  String _searchQuery = '';

  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  // Геттеры
  List<PasswordEntry> get passwords => _passwords;
  List<PasswordEntry> get allPasswords => _allPasswords;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _passwords.isEmpty;
  int get passwordsCount => _passwords.length;
  PasswordEntry? get currentPassword => _currentIndex < _passwords.length ? _passwords[_currentIndex] : null;

  /// Установка категории фильтра
  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  /// Установка поискового запроса
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  /// Применение фильтров
  void _applyFilters() {
    _passwords = _allPasswords.where((entry) {
      // Фильтр по категории
      if (_selectedCategoryId != null && entry.categoryId != _selectedCategoryId) {
        return false;
      }
      // Поиск по сервису
      if (_searchQuery.isNotEmpty && !entry.service.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      return true;
    }).toList();
    _currentIndex = 0;
    notifyListeners();
  }

  /// Сброс фильтров
  void clearFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    _passwords = List.from(_allPasswords);
    _currentIndex = 0;
    notifyListeners();
  }

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
          _allPasswords = [];
          _passwords = [];
          _currentIndex = 0;
        },
        (passwordsList) {
          _allPasswords = passwordsList;
          _applyFilters(); // Применяем фильтры
        },
      );
    } catch (e) {
      _error = 'Ошибка загрузки: $e';
      _allPasswords = [];
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
          // Логируем удаление пароля
          final entry = _passwords.length > _currentIndex
              ? _passwords[_currentIndex]
              : null;
          
          logEventUseCase.execute(
            EventTypes.pwdDeleted,
            details: {
              'service': entry?.service ?? 'unknown',
              'category_id': entry?.categoryId,
            },
          );

          _passwords.removeAt(_currentIndex);
          // Также удаляем из всех паролей
          if (entry != null) {
            _allPasswords.removeWhere((e) =>
              e.service == entry.service && e.password == entry.password);
          }
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
    final result = await exportPasswordsUseCase.execute();

    // Логируем экспорт
    result.fold(
      (failure) => null,
      (data) {
        logEventUseCase.execute(
          EventTypes.dataExport,
          details: {'count': _passwords.length},
        );
      },
    );

    return result;
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
          // Логируем импорт
          logEventUseCase.execute(
            EventTypes.dataImport,
            details: {'success': true, 'format': 'json'},
          );
          
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

  /// Экспорт паролей в формат .passgen
  Future<Either<StorageFailure, String>> exportPassgen(String masterPassword) async {
    final result = await exportPassgenUseCase.execute(masterPassword);
    
    // Логируем экспорт
    result.fold(
      (failure) => null,
      (data) {
        logEventUseCase.execute(
          EventTypes.dataExport,
          details: {'count': _passwords.length, 'format': 'passgen'},
        );
      },
    );
    
    return result;
  }

  /// Импорт паролей из формата .passgen
  Future<bool> importPassgen(String data, String masterPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await importPassgenUseCase.execute(
        data: data,
        masterPassword: masterPassword,
      );

      return result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          // Логируем импорт
          logEventUseCase.execute(
            EventTypes.dataImport,
            details: {'success': true, 'format': 'passgen'},
          );
          
          await loadPasswords();
          return true;
        },
      );
    } catch (e) {
      _error = 'Ошибка импорта .passgen: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }
}
