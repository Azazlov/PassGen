import 'package:flutter/material.dart';

import '../../../core/constants/breakpoints.dart';
import 'storage_detail_pane.dart';
import 'storage_list_pane.dart';

/// Адаптивный макет хранилища с двухпанельным режимом
class StorageAdaptiveLayout extends StatelessWidget {
  const StorageAdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.desktopMin) {
      return const StorageListPane();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: const StorageListPane(),
      ),
    );
  }
}

/// Мобильный макет (одна панель)
class StorageMobileLayout extends StatelessWidget {
  const StorageMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const StorageListPane();
  }
}

/// Планшетный макет (две панели)
class StorageTabletLayout extends StatelessWidget {
  const StorageTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const StorageListPane();
  }
}

/// Десктопный макет (три панели)
class StorageDesktopLayout extends StatelessWidget {
  const StorageDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: const StorageListPane(),
      ),
    );
  }
}

/// Экран деталей для мобильного режима
class StorageDetailScreen extends StatelessWidget {
  const StorageDetailScreen({super.key, required this.entry});
  final dynamic entry;

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
  const StorageEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
