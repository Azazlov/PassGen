import 'package:flutter/material.dart';

/// Сервис навигации между вкладками приложения
class NavigationService extends ChangeNotifier {
  AppTab _currentTab = AppTab.generator;

  AppTab get currentTab => _currentTab;

  /// Переключает на указанную вкладку
  void navigateTo(AppTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }

  /// Переключает на вкладку хранилища
  void navigateToStorage() {
    navigateTo(AppTab.storage);
  }

  /// Переключает на вкладку генератора
  void navigateToGenerator() {
    navigateTo(AppTab.generator);
  }

  /// Переключает на вкладку шифратора
  void navigateToEncryptor() {
    navigateTo(AppTab.encryptor);
  }

  /// Переключает на вкладку настроек
  void navigateToSettings() {
    navigateTo(AppTab.settings);
  }
}

/// Перечисление для типобезопасного управления вкладками приложения
enum AppTab {
  generator(Icons.create, 'Генератор'),
  encryptor(Icons.lock, 'Шифратор'),
  storage(Icons.archive, 'Хранилище'),
  settings(Icons.settings, 'Настройки');

  const AppTab(this.icon, this.label);
  final IconData icon;
  final String label;

  static AppTab fromIndex(int index) =>
      values[index.clamp(0, values.length - 1).toInt()];
}
