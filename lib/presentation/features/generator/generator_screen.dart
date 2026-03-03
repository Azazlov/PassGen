import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/widgets/app_button.dart';
import '../../../presentation/widgets/app_switch.dart';
import '../../../presentation/widgets/app_text_field.dart';
import '../../../presentation/widgets/copyable_password.dart';
import '../../../presentation/widgets/app_dialogs.dart';
import 'generator_controller.dart';
import '../storage/storage_controller.dart';

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

              const SizedBox(height: 24),

              // Слайдер сложности
              Text(
                'Сложность пароля',
                style: theme.textTheme.titleMedium,
              ),
              Slider(
                value: controller.strength.toDouble(),
                min: 0,
                max: 4,
                divisions: 4,
                label: controller.strengthLabel,
                activeColor: controller.strengthColor,
                onChanged: (value) {
                  controller.updateStrength(value.toInt());
                },
              ),
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
}
