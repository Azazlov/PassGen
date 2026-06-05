import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import 'storage_controller.dart';
import 'storage_detail_pane.dart';


/// Панель списка паролей
class StorageListPane extends StatelessWidget {
  const StorageListPane({super.key, this.onEntrySelected});
  final Function(dynamic)? onEntrySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<StorageController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск по сервису...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            onChanged: controller.setSearchQuery,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List<Category>>(
            future: context.read<GetCategoriesUseCase>().execute(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              return DropdownButtonFormField<int?>(
                initialValue: controller.selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Все категории'),
                  ),
                  ...categories.map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text('${category.icon ?? '📁'} ${category.name}'),
                    ),
                  ),
                ],
                onChanged: controller.setCategoryFilter,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: controller.isFilterEmpty
              ? StorageFilterEmptyState(
                  hasActiveFilter: controller.hasActiveFilter,
                  searchQuery: controller.searchQuery,
                )
              : ListView.builder(
                  key: const ValueKey('storage_passwords_list'),
                  itemCount: controller.passwordsCount,
                  itemBuilder: (context, index) {
                    final entry = controller.passwords[index];
                    final isSelected = controller.selectedEntry == entry;
                    final key =
                        entry.id ?? entry.createdAt.millisecondsSinceEpoch;

                    return Dismissible(
                      key: ValueKey('password_$key'),
                      direction: DismissDirection.horizontal,
                      background: _buildSwipeBackground(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        icon: Icons.copy,
                        label: 'Копировать',
                      ),
                      secondaryBackground: _buildSwipeBackground(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        icon: Icons.delete,
                        label: 'Удалить',
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await _copyPassword(context, entry);
                          return false;
                        }
                        return _showDeleteConfirmationSwipe(context, entry);
                      },
                      onDismissed: (_) {
                        context.read<StorageController>().deletePassword(entry);
                      },
                      child: _buildPasswordCard(
                        context,
                        controller,
                        entry,
                        isSelected,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required Alignment alignment,
    required IconData icon,
    required String label,
  }) {
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      color: color,
      alignment: alignment,
      padding: EdgeInsets.only(left: isLeft ? 16 : 0, right: isLeft ? 0 : 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ] else ...[
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordCard(
    BuildContext context,
    StorageController controller,
    PasswordEntry entry,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              controller.selectEntry(entry);
              onEntrySelected?.call(entry);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  FutureBuilder<List<Category>>(
                    future: context.read<GetCategoriesUseCase>().execute(),
                    builder: (context, snapshot) {
                      final category = _findCategory(snapshot.data ?? [], entry);
                      return Text(
                        category?.icon ?? '📁',
                        style: const TextStyle(fontSize: 24),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: controller.getDisplayService(entry),
                          builder: (context, snapshot) {
                            final text = snapshot.data ??
                                (entry.service.trim().isNotEmpty ? entry.service : 'Загрузка...');
                            return Text(
                              text,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        FutureBuilder<List<Category>>(
                          future: context.read<GetCategoriesUseCase>().execute(),
                          builder: (context, snapshot) {
                            final category = _findCategory(snapshot.data ?? [], entry);
                            final login = entry.login?.isNotEmpty == true
                                ? entry.login!
                                : 'Без логина';
                            return Text('$login • ${category?.name ?? 'Без категории'}');
                          },
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isSelected ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildExpandedDetails(context, entry),
            ),
            crossFadeState: isSelected
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(BuildContext context, PasswordEntry entry) {
    final theme = Theme.of(context);
    final passwordText = entry.hasPlainText
        ? entry.password!
        : (entry.isEncrypted ? '(нажмите "Копировать")' : (entry.password ?? '(зашифровано)'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),

        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                // используем тот же диалог редактирования, что и в detail-pane
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<StorageController>(),
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text('Редактировать запись'),
                        ),
                        body: StorageDetailPane(entry: entry),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Редактировать'),
            ),
          ),
        ),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.key),
          title: const Text('Пароль'),
          subtitle: SelectableText(
            passwordText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Копировать пароль',
            onPressed: () => _copyPassword(context, entry),
          ),
        ),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: const Text('Логин'),
          subtitle: Text(
            entry.login?.isNotEmpty == true ? entry.login! : 'Не указан',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.tune),
          title: const Text('Конфигурация'),
          subtitle: SelectableText(
            entry.config.isNotEmpty ? entry.config : 'Не указана',
            maxLines: 2,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('Создан'),
          subtitle: Text(_formatDate(entry.createdAt)),
        ),
      ],
    );
  }

  Category? _findCategory(List<Category> categories, PasswordEntry entry) {
    if (entry.categoryId == null) return null;
    return categories.cast<Category?>().firstWhere(
      (category) => category?.id == entry.categoryId,
      orElse: () => null,
    );
  }

  Future<void> _copyPassword(BuildContext context, PasswordEntry entry) async {
    final controller = context.read<StorageController>();
    String passwordText;
    if (entry.isEncrypted && !entry.hasPlainText) {
      final decrypted = await controller.decryptEntryPassword(entry);
      passwordText = decrypted ?? '(ошибка)';
    } else {
      passwordText = entry.password ?? '(зашифровано)';
    }
    await Clipboard.setData(ClipboardData(text: passwordText));
    Future.delayed(const Duration(seconds: 60), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пароль скопирован'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationSwipe(
    BuildContext context,
    PasswordEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пароль?'),
        content: Text(
          'Вы точно хотите удалить пароль для сервиса "${entry.service}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year} $hour:$minute';
  }
}

/// Пустое состояние списка
class StorageEmptyListState extends StatelessWidget {
  const StorageEmptyListState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет сохранённых паролей',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Создайте первый пароль прямо сейчас',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Пустое состояние при фильтрации
class StorageFilterEmptyState extends StatelessWidget {
  const StorageFilterEmptyState({
    super.key,
    required this.hasActiveFilter,
    required this.searchQuery,
  });
  final bool hasActiveFilter;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilter ? Icons.filter_alt_off : Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilter ? 'Нет записей по фильтру' : 'Ничего не найдено',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (hasActiveFilter) ...[
              Text(
                'Измените параметры фильтра или сбросьте его',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final controller = context.read<StorageController>();
                  controller.clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Сбросить фильтры'),
              ),
            ] else ...[
              Text(
                'Попробуйте другой поисковый запрос',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
