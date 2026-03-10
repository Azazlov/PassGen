import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import 'storage_controller.dart';

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
        // Поиск
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

        // Фильтр категорий
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
                    (cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text('${cat.icon} ${cat.name}'),
                    ),
                  ),
                ],
                onChanged: controller.setCategoryFilter,
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Список паролей
        Expanded(
          child: controller.isFilterEmpty
              ? StorageFilterEmptyState(
                  hasActiveFilter: controller.hasActiveFilter,
                  searchQuery: controller.searchQuery,
                )
              : ListView.builder(
                  key: const PageStorageKey('storage_passwords_list'),
                  itemCount: controller.passwordsCount,
                  itemBuilder: (context, index) {
                    final entry = controller.passwords[index];
                    final isSelected = controller.selectedEntry == entry;

                    return AnimatedContainer(
                      key: ValueKey('password_${entry.id}'),
                      duration: const Duration(milliseconds: 200),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      child: ListTile(
                        leading: FutureBuilder<List<Category>>(
                          future: context
                              .read<GetCategoriesUseCase>()
                              .execute(),
                          builder: (context, snapshot) {
                            final categories = snapshot.data ?? [];
                            final category = entry.categoryId != null
                                ? categories.cast<Category?>().firstWhere(
                                    (c) => c?.id == entry.categoryId,
                                    orElse: () => null,
                                  )
                                : null;
                            return Text(
                              category?.icon ?? '📁',
                              style: const TextStyle(fontSize: 24),
                            );
                          },
                        ),
                        title: Text(
                          entry.service,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${entry.login} • ${entry.categoryId ?? "Без категории"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Semantics(
                              label: 'Показать пароль для ${entry.service}',
                              button: true,
                              child: IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () => onEntrySelected?.call(entry),
                                tooltip: 'Показать пароль',
                              ),
                            ),
                            Semantics(
                              label: 'Копировать пароль для ${entry.service}',
                              button: true,
                              child: IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  // Копирование
                                  final passwordText = entry.displayPassword ?? '(зашифровано)';
                                  Clipboard.setData(ClipboardData(text: passwordText));

                                  // Автоочистка буфера обмена через 60 секунд
                                  Future.delayed(const Duration(seconds: 60), () {
                                    Clipboard.setData(const ClipboardData(text: ''));
                                  });
                                },
                                tooltip: 'Копировать пароль',
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Выбираем запись в контроллере
                          final controller = context.read<StorageController>();
                          controller.selectEntry(entry);
                        },
                        onLongPress: () {
                          _showDeleteConfirmation(context, entry);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, PasswordEntry entry) {
    final controller = context.read<StorageController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пароль?'),
        content: Text(
          'Вы точно хотите удалить пароль для сервиса "${entry.service}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteCurrentPassword();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
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
            color: theme.colorScheme.onSurface.withOpacity(0.3),
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
              color: theme.colorScheme.onSurface.withOpacity(0.6),
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
              color: theme.colorScheme.onSurface.withOpacity(0.3),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
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
