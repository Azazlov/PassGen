import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'storage_controller.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';

/// Панель списка паролей
class StorageListPane extends StatelessWidget {
  final Function(dynamic)? onEntrySelected;

  const StorageListPane({super.key, this.onEntrySelected});

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
                value: controller.selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Все категории')),
                  ...categories.map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text('${cat.icon} ${cat.name}'),
                  )),
                ],
                onChanged: controller.setCategoryFilter,
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Список паролей
        Expanded(
          child: controller.isEmpty
              ? const StorageEmptyListState()
              : ListView.builder(
                  itemCount: controller.passwordsCount,
                  itemBuilder: (context, index) {
                    final entry = controller.passwords[index];
                    final isSelected = controller.selectedEntry == entry;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      child: ListTile(
                        leading: FutureBuilder<List<Category>>(
                          future: context.read<GetCategoriesUseCase>().execute(),
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
                                  Clipboard.setData(ClipboardData(text: entry.password));
                                },
                                tooltip: 'Копировать пароль',
                              ),
                            ),
                          ],
                        ),
                        onTap: () => onEntrySelected?.call(entry),
                        onLongPress: () {
                          // Показать меню удаления
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
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
