import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'categories_controller.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/category/create_category_usecase.dart';
import '../../../domain/usecases/category/update_category_usecase.dart';
import '../../../domain/usecases/category/delete_category_usecase.dart';
import '../../widgets/app_text_field.dart';

/// Экран управления категориями
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CategoriesController(
        getCategoriesUseCase: context.read<GetCategoriesUseCase>(),
        createCategoryUseCase: context.read<CreateCategoryUseCase>(),
        updateCategoryUseCase: context.read<UpdateCategoryUseCase>(),
        deleteCategoryUseCase: context.read<DeleteCategoryUseCase>(),
      )..loadCategories(),
      child: const _CategoriesScreenContent(),
    );
  }
}

class _CategoriesScreenContent extends StatelessWidget {
  const _CategoriesScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<CategoriesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Добавить категорию',
            onPressed: () => _showAddCategoryDialog(context, controller),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.isEmpty
              ? _buildEmptyState(theme)
              : _buildCategoriesList(controller, theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Нет категорий',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите + чтобы добавить',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(CategoriesController controller, ThemeData theme) {
    final systemCategories = controller.getSystemCategories();
    final userCategories = controller.getUserCategories();

    return Builder(
      builder: (context) => ListView(
        key: const PageStorageKey('categories_list'),
        padding: const EdgeInsets.all(16),
        children: [
          if (systemCategories.isNotEmpty) ...[
            _buildSectionTitle('Системные', theme),
            ...systemCategories.map((cat) => _buildCategoryTile(cat, controller, theme, isSystem: true, context: context)),
            const SizedBox(height: 16),
          ],
          if (userCategories.isNotEmpty) ...[
            _buildSectionTitle('Пользовательские', theme),
            ...userCategories.map((cat) => _buildCategoryTile(cat, controller, theme, context: context)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryTile(Category category, CategoriesController controller, ThemeData theme, {bool isSystem = false, required BuildContext context}) {
    return Card(
      key: ValueKey('category_${category.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(category.icon ?? '📁', style: const TextStyle(fontSize: 24)),
        title: Text(category.name),
        subtitle: Text(isSystem ? 'Системная' : 'Пользовательская'),
        trailing: isSystem
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: ValueKey('edit_${category.id}'),
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditCategoryDialog(context, controller, category),
                  ),
                  IconButton(
                    key: ValueKey('delete_${category.id}'),
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context, controller, category),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, CategoriesController controller) async {
    final nameController = TextEditingController();
    String selectedIcon = '📁';

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Новая категория'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                label: 'Название',
                hint: 'Введите название категории',
              ),
              const SizedBox(height: 16),
              const Text('Иконка:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['📁', '📂', '🗂️', '📑', '🏷️', '📌', '⭐', '🔖', '💼', '🎮', '🛒', '🏦', '📧', '👥', '🔐', '🌐']
                    .map((icon) => GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedIcon == icon
                                    ? Theme.of(ctx).colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(icon, style: const TextStyle(fontSize: 24)),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Введите название категории')),
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                final success = await controller.createCategory(
                  nameController.text.trim(),
                  selectedIcon,
                );
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Категория создана')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(controller.error ?? 'Ошибка')),
                    );
                  }
                }
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
  }

  void _showEditCategoryDialog(BuildContext context, CategoriesController controller, Category category) async {
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon ?? '📁';

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Редактировать категорию'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                label: 'Название',
                hint: 'Введите название категории',
              ),
              const SizedBox(height: 16),
              const Text('Иконка:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['📁', '📂', '🗂️', '📑', '🏷️', '📌', '⭐', '🔖', '💼', '🎮', '🛒', '🏦', '📧', '👥', '🔐', '🌐']
                    .map((icon) => GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedIcon == icon
                                    ? Theme.of(ctx).colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(icon, style: const TextStyle(fontSize: 24)),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Введите название категории')),
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                final updated = category.copyWith(
                  name: nameController.text.trim(),
                  icon: selectedIcon,
                );
                final success = await controller.updateCategory(updated);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Категория обновлена')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(controller.error ?? 'Ошибка')),
                    );
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
  }

  void _confirmDelete(BuildContext context, CategoriesController controller, Category category) async {
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удаление категории'),
        content: Text('Вы уверены, что хотите удалить категорию "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.deleteCategory(category.id!, category.isSystem);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Категория удалена')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(controller.error ?? 'Ошибка')),
          );
        }
      }
    }
  }
}
