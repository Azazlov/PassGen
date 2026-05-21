import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/event_types.dart';
import '../../../core/errors/failures.dart';
import '../../../core/security/master_password_session.dart';
import '../../../data/datasources/encryptor_local_datasource.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/entities/password_history_entry.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';
import '../../../domain/usecases/password/generate_password_usecase.dart';
import '../../../domain/usecases/password/get_password_history_usecase.dart';
import '../../../domain/usecases/password/save_password_usecase.dart';
import '../../../domain/usecases/storage/delete_password_usecase.dart';
import '../../../domain/usecases/storage/export_passgen_usecase.dart';
import '../../../domain/usecases/storage/export_passwords_usecase.dart';
import '../../../domain/usecases/storage/get_passwords_usecase.dart';
import '../../../domain/usecases/storage/import_passgen_usecase.dart';
import '../../../domain/usecases/storage/import_passwords_usecase.dart';
import '../../../domain/usecases/storage/update_entry_usecase.dart';

/// Контроллер для экрана хранилища
class StorageController extends ChangeNotifier {
  StorageController({
    required this.getPasswordsUseCase,
    required this.deletePasswordUseCase,
    required this.exportPasswordsUseCase,
    required this.importPasswordsUseCase,
    required this.exportPassgenUseCase,
    required this.importPassgenUseCase,
    required this.logEventUseCase,
    this.updateEntryUseCase,
    this.getPasswordHistoryUseCase,
    this.generatePasswordUseCase,
    this.savePasswordUseCase,
  });
  final GetPasswordsUseCase getPasswordsUseCase;
  final DeletePasswordUseCase deletePasswordUseCase;
  final ExportPasswordsUseCase exportPasswordsUseCase;
  final ImportPasswordsUseCase importPasswordsUseCase;
  final ExportPassgenUseCase exportPassgenUseCase;
  final ImportPassgenUseCase importPassgenUseCase;
  final LogEventUseCase logEventUseCase;
  final UpdateEntryUseCase? updateEntryUseCase;
  final GetPasswordHistoryUseCase? getPasswordHistoryUseCase;
  final GeneratePasswordUseCase? generatePasswordUseCase;
  final SavePasswordUseCase? savePasswordUseCase;

  // Состояние
  List<PasswordEntry> _allPasswords = [];
  List<PasswordEntry> _passwords = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Фильтры
  int? _selectedCategoryId;
  String _searchQuery = '';
  PasswordEntry? _selectedEntry; // Для двухпанельного макета

  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  PasswordEntry? get selectedEntry => _selectedEntry;

  // Геттеры
  List<PasswordEntry> get passwords => _passwords;
  List<PasswordEntry> get allPasswords => _allPasswords;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _passwords.isEmpty;
  bool get hasNoPasswords => _allPasswords.isEmpty;
  bool get isFilterEmpty => _passwords.isEmpty;
  bool get hasActiveFilter =>
      _selectedCategoryId != null || _searchQuery.isNotEmpty;
  int get passwordsCount => _passwords.length;
  PasswordEntry? get currentPassword =>
      _currentIndex < _passwords.length ? _passwords[_currentIndex] : null;

  /// Выбор записи
  void selectEntry(PasswordEntry? entry) {
    _selectedEntry = entry;
    if (entry != null) {
      final index = _passwords.indexOf(entry);
      if (index != -1) {
        _currentIndex = index;
      }
    }
    notifyListeners();
  }

  /// Очистка выбора
  void clearSelection() {
    _selectedEntry = null;
    notifyListeners();
  }

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
      if (_selectedCategoryId != null) {
        // Если категория выбрана, показываем только записи с этой категорией
        // entry.categoryId может быть null, поэтому используем явное сравнение
        final entryCategoryId = entry.categoryId;
        if (entryCategoryId != _selectedCategoryId) {
          return false;
        }
      }
      // Поиск по сервису
      if (_searchQuery.isNotEmpty &&
          !entry.service.toLowerCase().contains(_searchQuery)) {
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

    // Восстанавливаем выбор первой записи
    _selectedEntry = _passwords.isNotEmpty ? _passwords.first : null;

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
    await deletePassword(_passwords[_currentIndex]);
  }

  /// Удаление указанного пароля.
  Future<void> deletePassword(PasswordEntry entry) async {
    final storageIndex = _allPasswords.indexWhere((password) {
      if (entry.id != null && password.id == entry.id) return true;
      return password.service == entry.service &&
          password.login == entry.login &&
          password.createdAt == entry.createdAt;
    });

    if (storageIndex == -1) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await deletePasswordUseCase.execute(storageIndex);

      result.fold(
        (failure) {
          _error = failure.message;
        },
        (_) {
          // Логируем удаление пароля
          logEventUseCase.execute(
            EventTypes.pwdDeleted,
            details: {
              'service': entry.service,
              'category_id': entry.categoryId,
            },
          );

          _allPasswords.removeAt(storageIndex);
          _applyFilters();
          if (_currentIndex >= _passwords.length) {
            _currentIndex = _passwords.isEmpty ? 0 : _passwords.length - 1;
          }
          if (_selectedEntry == entry) {
            _selectedEntry = null;
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

  /// Обновляет метаданные существующей записи (service, login, url, notes,
  /// category). Перезагружает список после успеха. Возвращает `true` при
  /// успешном сохранении.
  Future<bool> updateEntry(PasswordEntry updated) async {
    if (updateEntryUseCase == null) {
      _error = 'Обновление записей недоступно';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final result = await updateEntryUseCase!.execute(updated);
      return await result.fold(
        (failure) async {
          _error = failure.message;
          return false;
        },
        (_) async {
          logEventUseCase.execute(
            EventTypes.pwdUpdated,
            details: {
              'service': updated.service,
              'category_id': updated.categoryId,
            },
          );
          await loadPasswords();
          // Восстанавливаем выбор обновлённой записи (по id).
          if (updated.id != null) {
            final restored = _allPasswords.firstWhere(
              (e) => e.id == updated.id,
              orElse: () => updated,
            );
            _selectedEntry = restored;
          }
          return true;
        },
      );
    } catch (e) {
      _error = 'Ошибка обновления: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Возвращает историю изменений пароля для записи [entryId] (новые сначала).
  /// Возвращает пустой список, если history use case не подключен или запись
  /// без id (до миграции на SQLite).
  Future<List<PasswordHistoryEntry>> getHistoryForEntry(int? entryId) async {
    if (entryId == null || getPasswordHistoryUseCase == null) {
      return const [];
    }
    final result = await getPasswordHistoryUseCase!.execute(entryId);
    return result.fold((_) => const [], (list) => list);
  }

  /// Расшифровывает пароль для указанной записи.
  ///
  /// Возвращает расшифрованный пароль или `null` при ошибке.
  /// НЕ вызывает notifyListeners() — чтобы не сбрасывать виджеты,
  /// использующие FutureBuilder.
  Future<String> getDisplayService(PasswordEntry entry) async {
    // Если plaintext service уже есть — показываем его без дешифрования.
    if (entry.service.trim().isNotEmpty) return entry.service;

    // Если есть зашифрованный blob — пытаемся дешифровать.
    if (entry.encryptedServiceBlob == null || entry.encryptedServiceBlob!.isEmpty) {
      return entry.service.trim().isNotEmpty ? entry.service : 'Неизвестный сервис';
    }

    final masterPassword = MasterPasswordSession.getAny();
    if (masterPassword == null || masterPassword.isEmpty) {
      return 'Неизвестный сервис';
    }

    try {
      // Используем тот же encryptor, что и для decryptEntryPassword.
      final encryptor = EncryptorLocalDataSource();
      final decryptedBytes = await encryptor.decryptFieldWithKey(
        blob: entry.encryptedServiceBlob!,
        keyBytes: utf8.encode(masterPassword),
      );
      final decryptedService = utf8.decode(decryptedBytes).trim();
      return decryptedService.isNotEmpty ? decryptedService : 'Неизвестный сервис';
    } catch (_) {
      return 'Неизвестный сервис';
    }
  }

  Future<String?> decryptEntryPassword(PasswordEntry entry) async {
    final masterPassword = MasterPasswordSession.getAny();
    if (masterPassword == null || masterPassword.isEmpty ||
        !entry.isEncrypted) {
      return entry.password;
    }
    try {
      final encryptor = EncryptorLocalDataSource();
      final decryptedBytes = await encryptor.decryptFromMini(
        miniEncrypted: entry.encryptedPassword!,
        password: utf8.encode(masterPassword),
      );
      return utf8.decode(decryptedBytes);
    } catch (_) {
      return null;
    }
  }

  /// Регенерирует пароль для существующей записи, сохраняя предыдущую
  /// версию в `password_history` (через `SavePasswordUseCase`).
  ///
  /// Использует настройки уровня «Сложный» (length 16, все классы символов)
  /// чтобы не зависеть от прежней конфигурации, которая хранится зашифрованной.
  /// Возвращает `true` при успехе.
  Future<bool> regeneratePassword(PasswordEntry entry) async {
    final generate = generatePasswordUseCase;
    final save = savePasswordUseCase;
    if (generate == null || save == null) {
      _error = 'Регенерация недоступна';
      notifyListeners();
      return false;
    }
    final masterPassword = MasterPasswordSession.getAny();
    if (masterPassword == null || masterPassword.isEmpty) {
      _error = 'Сессия мастер-пароля не активна';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final settings = GeneratePasswordUseCase.getSettingsByStrength(2);
      final generated = await generate.execute(settings);
      final newPassword = generated.fold<String?>((_) => null, (r) => r.password);
      final newConfig = generated.fold<String?>((_) => null, (r) => r.config);
      if (newPassword == null || newConfig == null) {
        _error = 'Не удалось сгенерировать пароль';
        return false;
      }

      final result = await save.execute(
        service: entry.service,
        password: newPassword,
        config: newConfig,
        categoryId: entry.categoryId,
        login: entry.login,
        entryId: entry.id,
        encryptedPassword: entry.encryptedPassword,
        nonce: entry.nonce,
        reason: 'Регенерация',
        masterPassword: masterPassword,
      );

      return await result.fold(
        (failure) async {
          _error = failure.message;
          return false;
        },
        (_) async {
          logEventUseCase.execute(
            EventTypes.pwdUpdated,
            details: {
              'service': entry.service,
              'reason': 'regenerate',
            },
          );
          await loadPasswords();
          if (entry.id != null) {
            _selectedEntry = _allPasswords.firstWhere(
              (e) => e.id == entry.id,
              orElse: () => entry,
            );
          }
          return true;
        },
      );
    } catch (e) {
      _error = 'Ошибка регенерации: $e';
      return false;
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
    result.fold((failure) => null, (data) {
      logEventUseCase.execute(
        EventTypes.dataExport,
        details: {'count': _passwords.length},
      );
    });

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
  Future<Either<StorageFailure, String>> exportPassgen(
    String masterPassword,
  ) async {
    final result = await exportPassgenUseCase.execute(masterPassword);

    // Логируем экспорт
    result.fold((failure) => null, (data) {
      logEventUseCase.execute(
        EventTypes.dataExport,
        details: {'count': _passwords.length, 'format': 'passgen'},
      );
    });

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

  @override
  void dispose() {
    _allPasswords.clear();
    _passwords.clear();
    super.dispose();
  }
}
