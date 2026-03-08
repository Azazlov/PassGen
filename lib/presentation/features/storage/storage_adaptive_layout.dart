import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/breakpoints.dart';
import 'storage_controller.dart';
import 'storage_list_pane.dart';
import 'storage_detail_pane.dart';

/// Адаптивный макет хранилища с двухпанельным режимом
class StorageAdaptiveLayout extends StatelessWidget {
  const StorageAdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controller = context.watch<StorageController>();

    // Мобильный режим (< 600dp)
    if (width < Breakpoints.tabletMin) {
      return const StorageMobileLayout();
    }

    // Планшет (600-899dp) - двухпанельный макет
    if (width < Breakpoints.desktopMin) {
      return const StorageTabletLayout();
    }

    // Десктоп (≥ 900dp) - трёхпанельный макет с NavigationRail
    return const StorageDesktopLayout();
  }
}

/// Мобильный макет (одна панель)
class StorageMobileLayout extends StatelessWidget {
  const StorageMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StorageController>();

    return Column(
      children: [
        // Список паролей
        Expanded(
          child: StorageListPane(
            onEntrySelected: (entry) {
              // На мобильном переходим к деталям на отдельный экран
              if (entry != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StorageDetailScreen(entry: entry),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Планшетный макет (две панели)
class StorageTabletLayout extends StatelessWidget {
  const StorageTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StorageController>();

    return Row(
      children: [
        // Левая панель: Список (40%)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: StorageListPane(
            onEntrySelected: (entry) => controller.selectEntry(entry),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Правая панель: Детали (60%)
        Expanded(
          flex: 6,
          child: controller.selectedEntry != null
              ? StorageDetailPane(entry: controller.selectedEntry!)
              : const StorageEmptyState(
                  icon: Icons.archive,
                  title: 'Выберите пароль',
                  subtitle: 'или создайте новый',
                ),
        ),
      ],
    );
  }
}

/// Десктопный макет (три панели)
class StorageDesktopLayout extends StatelessWidget {
  const StorageDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StorageController>();

    return Row(
      children: [
        // Список с фиксированной шириной (280dp)
        const SizedBox(
          width: 280,
          child: StorageListPane(
            onEntrySelected: null, // Выбор через controller
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Детали (расширяемая панель, макс 800dp)
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: controller.selectedEntry != null
                    ? StorageDetailPane(entry: controller.selectedEntry!)
                    : const StorageEmptyState(
                        icon: Icons.archive,
                        title: 'Выберите пароль',
                        subtitle: 'или создайте новый',
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Экран деталей для мобильного режима
class StorageDetailScreen extends StatelessWidget {
  final dynamic entry;

  const StorageDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Удалить',
          ),
        ],
      ),
      body: StorageDetailPane(entry: entry),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пароль?'),
        content: const Text('Вы уверены, что хотите удалить этот пароль?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Удаление
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

/// Пустое состояние
class StorageEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const StorageEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
