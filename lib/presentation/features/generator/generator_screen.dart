import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/widgets/app_button.dart';
import '../../../presentation/widgets/app_switch.dart';
import '../../../presentation/widgets/app_text_field.dart';
import '../../../presentation/widgets/copyable_password.dart';
import '../../../presentation/widgets/app_dialogs.dart';
import 'generator_controller.dart';
import '../storage/storage_controller.dart';
import '../categories/categories_controller.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/entities/category.dart';

/// Экран генератора паролей
class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => context.read<GeneratorController>(),
      child: const _GeneratorScreenContent(),
    );
  }
}

class _GeneratorScreenContent extends StatefulWidget {
  const _GeneratorScreenContent();

  @override
  State<_GeneratorScreenContent> createState() => _GeneratorScreenContentState();
}

class _GeneratorScreenContentState extends State<_GeneratorScreenContent> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handlePasswordTap() async {
    final controller = context.read<GeneratorController>();
    final storageController = context.read<StorageController>();

    if (controller.password.isEmpty) {
      showAppDialog(
        context: context,
        title: 'Нет пароля',
        content: 'Сначала сгенерируйте пароль',
      );
      return;
    }

    // Копируем пароль в буфер обмена
    showSavePasswordConfirmationDialog(
      context: context,
      service: controller.serviceController.text.isEmpty
          ? 'Не указан'
          : controller.serviceController.text,
      onConfirm: () async {
        final result = await controller.savePassword();

        if (!context.mounted) return;

        final success = result['success'] as bool? ?? false;
        final updated = result['updated'] as bool? ?? false;

        if (success) {
          // Автообновление хранилища
          await storageController.loadPasswords();
          
          showAppDialog(
            context: context,
            title: 'Успешно',
            content: updated
                ? 'Пароль для сервиса обновлён'
                : 'Пароль сохранён в хранилище',
          );
        } else {
          final error = controller.error;
          if (error != null && context.mounted) {
            showAppDialog(
              context: context,
              title: 'Ошибка',
              content: error,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<GeneratorController>();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),

              // Заголовок
              Text(
                'Генератор паролей',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Отображение пароля
              CopyablePassword(
                label: 'Пароль',
                text: controller.password,
                isEmpty: controller.password.isEmpty,
                onTap: _handlePasswordTap,
              ),

              const SizedBox(height: 24),

              // Поле сервиса
              AppTextField(
                label: 'Сервис',
                hint: 'Например: gmail.com',
                controller: controller.serviceController,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16),

              // Выбор категории
              _buildCategorySelector(controller, theme),

              const SizedBox(height: 24),

              // Пресеты сложности (FilterChip согласно ТЗ)
              Text(
                'Сложность пароля',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Стандартный'),
                    selected: controller.strength == 2,
                    onSelected: (_) => controller.updateStrength(2),
                  ),
                  FilterChip(
                    label: const Text('Надёжный'),
                    selected: controller.strength == 3,
                    onSelected: (_) => controller.updateStrength(3),
                  ),
                  FilterChip(
                    label: const Text('Максимальный'),
                    selected: controller.strength == 4,
                    onSelected: (_) => controller.updateStrength(4),
                  ),
                  FilterChip(
                    label: const Text('PIN'),
                    selected: controller.strength == 0,
                    onSelected: (_) => controller.updateStrength(0),
                  ),
                  FilterChip(
                    label: const Text('Свой+'),
                    selected: controller.strength == 1,
                    onSelected: (_) => controller.updateStrength(1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Индикатор стойкости
              LinearProgressIndicator(
                value: controller.strength / 4,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  controller.strengthColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.strengthLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: controller.strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              // Настройки длины
              ExpansionTile(
                title: const Text('Настройки длины пароля'),
                children: [
                  AppTextField(
                    label: 'Мин. длина',
                    hint: 'от 1 до 32',
                    controller: controller.minLengthController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => controller.generatePassword(),
                  ),
                  AppTextField(
                    label: 'Макс. длина',
                    hint: 'от 1 до 64',
                    controller: controller.maxLengthController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => controller.generatePassword(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Настройки обязательности
              ExpansionTile(
                title: const Text('Настройки обязательности'),
                children: [
                  AppSwitch(
                    label: 'Заглавные буквы',
                    subtitle: 'В пароле будут заглавные буквы',
                    value: controller.requireUppercase,
                    icon: Icons.text_fields,
                    onChanged: controller.toggleRequireUppercase,
                  ),
                  AppSwitch(
                    label: 'Строчные буквы',
                    subtitle: 'В пароле будут строчные буквы',
                    value: controller.requireLowercase,
                    icon: Icons.text_fields,
                    onChanged: controller.toggleRequireLowercase,
                  ),
                  AppSwitch(
                    label: 'Цифры',
                    subtitle: 'В пароле будут цифры',
                    value: controller.requireDigits,
                    icon: Icons.dialpad,
                    onChanged: controller.toggleRequireDigits,
                  ),
                  AppSwitch(
                    label: 'Спец. символы',
                    subtitle: 'В пароле будут спец. символы',
                    value: controller.requireSymbols,
                    icon: Icons.tag,
                    onChanged: controller.toggleRequireSymbols,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Кнопка генерации
              AppButton(
                label: 'Сгенерировать',
                onPressed: controller.generatePassword,
                isLoading: controller.isLoading,
                icon: Icons.refresh,
              ),

              const SizedBox(height: 16),

              // Отображение ошибки
              if (controller.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.error!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(GeneratorController controller, ThemeData theme) {
    return FutureBuilder(
      future: context.read<GetCategoriesUseCase>().execute(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        final selectedCategory = controller.selectedCategoryId != null
            ? categories.cast<Category?>().firstWhere(
                  (c) => c?.id == controller.selectedCategoryId,
                  orElse: () => null,
                )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Категория',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final result = await showDialog<Category?>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Выберите категорию'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (ctx, index) {
                          final category = categories[index] as Category;
                          return ListTile(
                            leading: Text(category.icon ?? '📁', style: const TextStyle(fontSize: 20)),
                            title: Text(category.name),
                            subtitle: category.isSystem ? const Text('Системная') : null,
                            onTap: () => Navigator.of(ctx).pop(category),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: const Text('Без категории'),
                      ),
                    ],
                  ),
                );
                controller.updateSelectedCategoryId(result?.id);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedCategory?.icon ?? '📁',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedCategory?.name ?? 'Без категории',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
