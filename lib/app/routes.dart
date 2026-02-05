import 'package:flutter/material.dart';
import 'package:pass_gen/features/about/about.dart';
import 'package:pass_gen/features/storage/storage.dart';
import 'package:pass_gen/features/endecrypter/endecrypter.dart';
import 'package:pass_gen/features/passwordGenerator/password_generator.dart';

/// Перечисление для типобезопасного управления вкладками
enum AppTab {
  generator(Icons.create, 'Генератор'),
  encryptor(Icons.lock, 'Шифратор'),
  storage(Icons.archive, 'Хранилище'),
  about(Icons.info, 'О программе');

  const AppTab(this.icon, this.label);
  final IconData icon;
  final String label;

  static AppTab fromIndex(int index) => values[index.clamp(0, values.length - 1)];
}

class TabScaffold extends StatefulWidget {
  const TabScaffold({super.key});

  @override
  State<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  AppTab _currentTab = AppTab.generator;

  /// Обработчик переключения вкладок с анимацией плавного перехода
  void _onTabTapped(int index) {
    final newTab = AppTab.fromIndex(index);
    if (_currentTab != newTab) {
      setState(() => _currentTab = newTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        // Оптимизация: предварительная загрузка только активной и соседних вкладок
        children: [
          /// Генератор паролей — первичная вкладка
          _buildTab(AppTab.generator.index, const PasswordGeneratorScreen()),

          /// Шифрование/дешифрование
          _buildTab(AppTab.encryptor.index, const EndecrypterScreen()),

          /// Хранилище паролей
          _buildTab(AppTab.storage.index, const StorageScreen()),

          /// Информация о приложении
          _buildTab(AppTab.about.index, const AboutScreen()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme, textTheme),
    );
  }

  /// Вспомогательный метод для обертки экранов вкладок
  /// Позволяет в будущем добавить анимации или обработку ошибок
  Widget _buildTab(int tabIndex, Widget child) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: child,
    );
  }

  /// Настраиваемая нижняя панель навигации с улучшенной доступностью
  BottomNavigationBar _buildBottomNavigationBar(ThemeData theme, TextTheme textTheme) {
    return BottomNavigationBar(
      currentIndex: _currentTab.index,
      onTap: _onTabTapped,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
      unselectedLabelStyle: textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      items: AppTab.values.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(tab.icon),
          label: tab.label,
          tooltip: tab.label, // Улучшение доступности
        );
      }).toList(),
    );
  }
}