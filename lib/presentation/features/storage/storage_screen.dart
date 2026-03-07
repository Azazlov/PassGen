import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../presentation/widgets/app_button.dart';
import '../../../presentation/widgets/app_dialogs.dart';
import '../../../presentation/widgets/shimmer_effect.dart';
import 'storage_controller.dart';
import '../categories/categories_controller.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/entities/category.dart';

/// Экран хранилища паролей
class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => context.read<StorageController>(),
      child: const _StorageScreenContent(),
    );
  }
}

class _StorageScreenContent extends StatefulWidget {
  const _StorageScreenContent();

  @override
  State<_StorageScreenContent> createState() => _StorageScreenContentState();
}

class _StorageScreenContentState extends State<_StorageScreenContent> {
  @override
  void initState() {
    super.initState();
    // Загружаем пароли после завершения сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorageController>().loadPasswords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<StorageController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Хранилище'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: controller.loadPasswords,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, controller),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'import_json', child: Text('Импорт JSON')),
              const PopupMenuItem(value: 'export_json', child: Text('Экспорт JSON')),
              const PopupMenuItem(value: 'import_passgen', child: Text('Импорт .passgen')),
              const PopupMenuItem(value: 'export_passgen', child: Text('Экспорт .passgen')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Удалить всё', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: controller.isLoading
            ? ShimmerList(itemCount: 5, itemHeight: 120)
            : controller.isEmpty
                ? _buildEmptyState(theme)
                : _buildContent(controller, theme),
      ),
    );
  }

  Widget _buildContent(StorageController controller, ThemeData theme) {
    if (controller.isEmpty) {
      return _buildEmptyState(theme);
    }

    final password = controller.currentPassword;
    if (password == null) {
      return _buildEmptyState(theme);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Поиск
        TextField(
          decoration: InputDecoration(
            hintText: 'Поиск по сервису...',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
          ),
          onChanged: (value) => controller.setSearchQuery(value),
        ),

        const SizedBox(height: 16),

        // Фильтр категорий
        _buildCategoryFilter(controller, theme),

        const SizedBox(height: 24),

        // Навигация между паролями
        _buildNavigation(controller, theme),

        const SizedBox(height: 32),

        // Карточка сервиса
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Иконка категории (используем заглушку, т.к. category не загружен)
                FutureBuilder<List<Category>>(
                  future: context.read<GetCategoriesUseCase>().execute(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    final category = password.categoryId != null
                        ? categories.cast<Category?>().firstWhere(
                            (c) => c?.id == password.categoryId,
                            orElse: () => null,
                          )
                        : null;
                    return Text(
                      category?.icon ?? '📁',
                      style: const TextStyle(fontSize: 48),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  password.service,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.currentIndex + 1} / ${controller.passwordsCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Отображение пароля
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Пароль',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        password.password,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: password.password));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароль скопирован')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Кнопка копирования
        AppButton(
          label: 'Скопировать пароль',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: password.password));
            showAppDialog(
              context: context,
              title: 'Скопировано',
              content: 'Пароль скопирован в буфер обмена',
            );
          },
          icon: Icons.copy,
        ),

        const SizedBox(height: 16),

        // Ошибка
        if (controller.error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.error!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.clearError,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNavigation(StorageController controller, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: controller.passwordsCount > 1 && controller.currentIndex > 0
              ? controller.prevPassword
              : null,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${controller.currentIndex + 1} / ${controller.passwordsCount}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: controller.passwordsCount > 1 && controller.currentIndex < controller.passwordsCount - 1
              ? controller.nextPassword
              : null,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Хранилище пусто',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Сгенерируйте пароль и сохраните его в хранилище',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _deletePassword(StorageController controller) {
    if (controller.isEmpty) {
      showAppDialog(
        context: context,
        title: 'Ошибка',
        content: 'Хранилище пустое',
      );
      return;
    }

    showConfirmationDialog(
      context: context,
      title: 'Удалить пароль?',
      content: 'Вы точно хотите удалить пароль для сервиса "${controller.currentPassword?.service}"?',
      confirmLabel: 'Удалить',
      cancelLabel: 'Отмена',
      onConfirm: controller.deleteCurrentPassword,
    );
  }

  void _handleMenuAction(String value, StorageController controller) async {
    switch (value) {
      case 'import_json':
        await _importPasswords(controller);
        break;
      case 'export_json':
        await _exportPasswords(controller);
        break;
      case 'import_passgen':
        await _importPassgen(controller);
        break;
      case 'export_passgen':
        await _exportPassgen(controller);
        break;
      case 'delete':
        _deletePassword(controller);
        break;
    }
  }

  Future<void> _importPasswords(StorageController controller) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Выберите файл с паролями',
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        showAppDialog(
          context: context,
          title: 'Отменено',
          content: 'Файл не выбран',
        );
        return;
      }

      final file = result.files.first;
      final jsonString = utf8.decode(file.bytes as List<int>);
      
      final success = await controller.importPasswords(jsonString);
      
      if (!context.mounted) return;
      
      if (success) {
        showAppDialog(
          context: context,
          title: 'Импортировано',
          content: 'Пароли успешно импортированы',
        );
      } else {
        showAppDialog(
          context: context,
          title: 'Ошибка',
          content: controller.error ?? 'При импорте произошла ошибка',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      showAppDialog(
        context: context,
        title: 'Ошибка',
        content: 'При импорте файла произошла ошибка: $e',
      );
    }
  }

  Future<void> _exportPasswords(StorageController controller) async {
    if (controller.isEmpty) {
      showAppDialog(
        context: context,
        title: 'Ошибка',
        content: 'Хранилище пустое',
      );
      return;
    }

    try {
      final result = await controller.exportPasswords();
      
      if (!context.mounted) return;
      
      result.fold(
        (failure) {
          showAppDialog(
            context: context,
            title: 'Ошибка',
            content: failure.message,
          );
        },
        (jsonString) async {
          try {
            final directory = await getTemporaryDirectory();
            final file = File('${directory.path}/passwords_export.json');
            await file.writeAsString(jsonString);

            await Share.shareXFiles([XFile(file.path)]);
          } catch (e) {
            if (context.mounted) {
              showAppDialog(
                context: context,
                title: 'Ошибка',
                content: 'При экспорте произошла ошибка: $e',
              );
            }
          }
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppDialog(
        context: context,
        title: 'Ошибка',
        content: 'При экспорте произошла ошибка: $e',
      );
    }
  }

  // ==================== .passgen ЭКСПОРТ/ИМПОРТ ====================

  Future<void> _exportPassgen(StorageController controller) async {
    if (controller.isEmpty) {
      showAppDialog(
        context: context,
        title: 'Ошибка',
        content: 'Хранилище пустое',
      );
      return;
    }

    // Запрашиваем мастер-пароль
    final masterPasswordController = TextEditingController();
    
    if (!context.mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Экспорт в .passgen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите мастер-пароль для шифрования:'),
            const SizedBox(height: 16),
            TextField(
              controller: masterPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Мастер-пароль',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Экспорт'),
          ),
        ],
      ),
    );

    masterPasswordController.dispose();

    if (confirmed != true) return;

    try {
      final result = await controller.exportPassgen(masterPasswordController.text);

      if (!context.mounted) return;

      result.fold(
        (failure) {
          showAppDialog(
            context: context,
            title: 'Ошибка',
            content: failure.message,
          );
        },
        (base64Data) async {
          try {
            final directory = await getTemporaryDirectory();
            final file = File('${directory.path}/passwords_export.passgen');
            await file.writeAsString(base64Data);

            await Share.shareXFiles([XFile(file.path)]);
            
            if (context.mounted) {
              showAppDialog(
                context: context,
                title: 'Экспорт выполнен',
                content: 'Пароли экспортированы в формате .passgen',
              );
            }
          } catch (e) {
            if (context.mounted) {
              showAppDialog(
                context: context,
                title: 'Ошибка',
                content: 'При экспорте произошла ошибка: $e',
              );
            }
          }
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppDialog(
        context: context,
        title: 'Ошибка',
        content: 'При экспорте произошла ошибка: $e',
      );
    }
  }

  Future<void> _importPassgen(StorageController controller) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['passgen'],
        dialogTitle: 'Выберите файл .passgen',
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        showAppDialog(
          context: context,
          title: 'Отменено',
          content: 'Файл не выбран',
        );
        return;
      }

      final file = result.files.first;
      final base64Data = utf8.decode(file.bytes as List<int>);

      // Запрашиваем мастер-пароль
      final masterPasswordController = TextEditingController();
      
      if (!context.mounted) return;
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Импорт из .passgen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Введите мастер-пароль для дешифрования:'),
              const SizedBox(height: 16),
              TextField(
                controller: masterPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Мастер-пароль',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Импорт'),
            ),
          ],
        ),
      );

      masterPasswordController.dispose();

      if (confirmed != true) return;

      final success = await controller.importPassgen(base64Data, masterPasswordController.text);

      if (!context.mounted) return;

      if (success) {
        showAppDialog(
          context: context,
          title: 'Импортировано',
          content: 'Пароли успешно импортированы из .passgen',
        );
      } else {
        showAppDialog(
          context: context,
          title: 'Ошибка',
          content: controller.error ?? 'Ошибка импорта',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      showAppDialog(
        context: context,
        title: 'Ошибка',
        content: 'При импорте произошла ошибка: $e',
      );
    }
  }

  /// Построение фильтра категорий
  Widget _buildCategoryFilter(StorageController controller, ThemeData theme) {
    return FutureBuilder<List<Category>>(
      future: context.read<GetCategoriesUseCase>().execute(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Фильтр "Все"
            FilterChip(
              label: const Text('Все'),
              selected: controller.selectedCategoryId == null,
              onSelected: (_) => controller.setCategoryFilter(null),
              avatar: const Icon(Icons.all_inclusive),
            ),
            // Фильтры по категориям
            ...categories.map((category) {
              final isSelected = controller.selectedCategoryId == category.id;
              return FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) => controller.setCategoryFilter(isSelected ? null : category.id),
                avatar: Text(category.icon ?? '📁', style: const TextStyle(fontSize: 16)),
              );
            }),
          ],
        );
      },
    );
  }
}
