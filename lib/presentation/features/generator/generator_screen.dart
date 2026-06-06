import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/password_generator_repository.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/generator/validate_generator_settings_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';
import '../../../domain/usecases/password/generate_password_usecase.dart';
import '../../../domain/usecases/password/save_password_usecase.dart';
import '../../../domain/usecases/storage/get_passwords_usecase.dart';
import '../../../presentation/widgets/app_dialogs.dart';
import '../../../presentation/widgets/app_text_field.dart';
import '../../../presentation/widgets/character_set_display.dart';
import '../../../presentation/widgets/copyable_password.dart';
import '../../../presentation/widgets/lottie_animations.dart';
import '../storage/storage_controller.dart';
import 'generator_controller.dart';

/// Экран генератора паролей
class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GeneratorController(
        generatePasswordUseCase: context.read<GeneratePasswordUseCase>(),
        savePasswordUseCase: context.read<SavePasswordUseCase>(),
        validateSettingsUseCase: context
            .read<ValidateGeneratorSettingsUseCase>(),
        logEventUseCase: context.read<LogEventUseCase>(),
        repository: context.read<PasswordGeneratorRepository>(),
        getPasswordsUseCase: context.read<GetPasswordsUseCase>(),
      ),
      child: const _GeneratorScreenContent(),
    );
  }
}

class _GeneratorScreenContent extends StatefulWidget {
  const _GeneratorScreenContent();

  @override
  State<_GeneratorScreenContent> createState() =>
      _GeneratorScreenContentState();
}

class _GeneratorScreenContentState extends State<_GeneratorScreenContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GeneratorController>().generatePassword();
      }
    });
  }

  Future<void> _handleCopyPassword() async {
    final controller = context.read<GeneratorController>();

    if (controller.password.isEmpty) {
      showAppDialog(
        context: context,
        title: 'Нет пароля',
        content: 'Сначала сгенерируйте пароль',
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: controller.password));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Пароль скопирован')));
  }

  Future<void> _handleSavePassword() async {
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

    showSavePasswordConfirmationDialog(
      context: context,
      service: controller.serviceController.text.isEmpty
          ? 'Не указан'
          : controller.serviceController.text,
      onConfirm: () async {
        final result = await controller.savePassword();

        if (!mounted) return;

        final success = result['success'] as bool? ?? false;
        final updated = result['updated'] as bool? ?? false;

        if (success && mounted) {
          // Автообновление хранилища
          await storageController.loadPasswords();

          if (mounted) {
            showAppDialog(
              context: context,
              title: 'Успешно',
              content: updated
                  ? 'Пароль для сервиса обновлён'
                  : 'Пароль сохранён в хранилище',
            );
          }
        } else {
          final error = controller.error;
          if (error != null && mounted) {
            showAppDialog(context: context, title: 'Ошибка', content: error);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<GeneratorController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < Breakpoints.tabletMin;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: isSmallScreen
              ? _buildMobileContent(theme, controller, screenWidth)
              : _buildDesktopContent(theme, controller),
        ),
      ),
      floatingActionButton: _buildFloatingActions(controller, theme),
    );
  }

  Widget _buildMobileContent(
    ThemeData theme,
    GeneratorController controller,
    double screenWidth,
  ) {
    final isSmallScreen = screenWidth < 600;

    return ListView(
      padding: EdgeInsets.only(
        left: isSmallScreen ? 12 : 16,
        right: isSmallScreen ? 12 : 16,
        top: isSmallScreen ? 12 : 16,
        bottom: 100,
      ),
      children: [
        SizedBox(height: isSmallScreen ? 8 : 16),
        _buildTitle(theme, isSmallScreen),
        SizedBox(height: isSmallScreen ? 16 : 32),
        if (controller.error != null) _buildErrorBox(controller, theme),
        if (controller.error != null) SizedBox(height: isSmallScreen ? 16 : 32),
        _buildPasswordDisplay(theme, isSmallScreen, controller),
        const SizedBox(height: 12),
        _buildStrengthMeter(controller, theme),
        SizedBox(height: isSmallScreen ? 16 : 24),
        _buildSaveFields(controller, theme),
        const SizedBox(height: 24),
        _buildStrengthChips(controller, theme),
        const SizedBox(height: 24),
        if (controller.isGlitchMode)
          _buildGlitchInput(controller, theme)
        else ...[
          _buildGeneratorSettingsPanel(controller, theme),
          const SizedBox(height: 16),
          CharacterSetDisplay(settings: controller.settings),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDesktopContent(
    ThemeData theme,
    GeneratorController controller,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          children: [
            SizedBox(
              width: 320,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStrengthChips(controller, theme),
                    const SizedBox(height: 24),
                    if (controller.isGlitchMode)
                      _buildGlitchInput(controller, theme)
                    else ...[
                      _buildGeneratorSettingsPanel(controller, theme),
                      const SizedBox(height: 16),
                      CharacterSetDisplay(settings: controller.settings),
                    ],
                  ],
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    child: Column(
                      children: [
                        _buildTitle(theme, false),
                        const SizedBox(height: 16),
                        if (controller.error != null) _buildErrorBox(controller, theme),
                        if (controller.error != null) const SizedBox(height: 16),
                        _buildPasswordDisplay(theme, false, controller),
                        const SizedBox(height: 12),
                        _buildStrengthMeter(controller, theme),
                        const SizedBox(height: 24),
                        _buildSaveFields(controller, theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, bool isSmallScreen) {
    return Text(
      'Генератор паролей',
      textAlign: TextAlign.center,
      style: isSmallScreen
          ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
          : theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildErrorBox(GeneratorController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        controller.error!,
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }

  Widget _buildPasswordDisplay(
    ThemeData theme,
    bool isSmallScreen,
    GeneratorController controller,
  ) {
    return Container(
      constraints: BoxConstraints(
        minHeight: isSmallScreen ? 100 : 120,
      ),
      child: CopyablePassword(
        label: 'Пароль',
        text: controller.password,
        isEmpty: controller.password.isEmpty,
      ),
    );
  }

  Widget _buildSaveFields(
    GeneratorController controller,
    ThemeData theme,
  ) {
    return Column(
      children: [
        AppTextField(
          label: 'Сервис',
          hint: 'Например: gmail.com',
          controller: controller.serviceController,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Логин (опционально)',
          hint: 'Например: user@gmail.com',
          controller: controller.loginController,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        _buildCategorySelector(controller, theme),
      ],
    );
  }

  Widget _buildStrengthChips(GeneratorController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Сложность пароля', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Стандартный'),
              selected: controller.strength == 2 && !controller.isGlitchMode,
              onSelected: (_) => controller.updateStrength(2),
              avatar: Semantics(
                label: 'Стандартный профиль генерации пароля',
                child: const Icon(Icons.star, size: 18),
              ),
            ),
            FilterChip(
              label: const Text('Надёжный'),
              selected: controller.strength == 3 && !controller.isGlitchMode,
              onSelected: (_) => controller.updateStrength(3),
              avatar: Semantics(
                label: 'Надёжный профиль генерации пароля',
                child: const Icon(Icons.verified, size: 18),
              ),
            ),
            FilterChip(
              label: const Text('Максимальный'),
              selected: controller.strength == 4 && !controller.isGlitchMode,
              onSelected: (_) => controller.updateStrength(4),
              avatar: Semantics(
                label: 'Максимальный профиль генерации пароля',
                child: const Icon(Icons.shield, size: 18),
              ),
            ),
            FilterChip(
              label: const Text('PIN'),
              selected: controller.strength == 0 && !controller.isGlitchMode,
              onSelected: (_) => controller.updateStrength(0),
              avatar: Semantics(
                label: 'PIN код профиль',
                child: const Icon(Icons.pin, size: 18),
              ),
            ),
            FilterChip(
              label: const Text('Свой+'),
              selected: controller.strength == 1 && !controller.isGlitchMode,
              onSelected: (_) => controller.updateStrength(1),
              avatar: Semantics(
                label: 'Пользовательский профиль генерации пароля',
                child: const Icon(Icons.tune, size: 18),
              ),
            ),
            FilterChip(
              label: const Text('Глитч'),
              selected: controller.isGlitchMode,
              onSelected: (_) => controller.toggleGlitchMode(),
              avatar: Semantics(
                label: 'Глитч-генерация пароля',
                child: const Icon(Icons.auto_fix_high, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlitchInput(
    GeneratorController controller,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Глитч-генерация', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Введите исходную строку для преобразования в leet-пароль',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.glitchSourceController,
              decoration: const InputDecoration(
                labelText: 'Исходная строка',
                hintText: 'Например: Elliot Alderson',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              minLines: 1,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthMeter(GeneratorController controller, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            value: controller.evaluatedStrengthValue,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              controller.evaluatedStrengthColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        LottieStrengthPulse(
          size: 32,
          strength: controller.evaluatedStrengthValue,
        ),
        const SizedBox(width: 8),
        Text(
          controller.evaluatedStrengthLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: controller.evaluatedStrengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratorSettingsPanel(
    GeneratorController controller,
    ThemeData theme,
  ) {
    final range = controller.settings.lengthRange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Настройки генерации', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Длина: ${range.first}-${range.last}',
              style: theme.textTheme.bodyMedium,
            ),
            RangeSlider(
              values: RangeValues(
                range.first.toDouble(),
                range.last.toDouble(),
              ),
              min: 4,
              max: 32,
              divisions: 32,
              labels: RangeLabels('${range.first}', '${range.last}'),
              onChanged: (values) {
                controller.updateLengthRange(
                  values.start.round(),
                  values.end.round(),
                );
              },
              onChangeEnd: (values) {
                controller.finishLengthRange(
                  values.start.round(),
                  values.end.round(),
                );
              },
            ),
            _buildSettingCheckbox(
              title: 'Заглавные буквы',
              value: controller.requireUppercase,
              onChanged: controller.toggleRequireUppercase,
            ),
            _buildSettingCheckbox(
              title: 'Строчные буквы',
              value: controller.requireLowercase,
              onChanged: controller.toggleRequireLowercase,
            ),
            _buildSettingCheckbox(
              title: 'Цифры',
              value: controller.requireDigits,
              onChanged: controller.toggleRequireDigits,
            ),
            _buildSettingCheckbox(
              title: 'Спец. символы',
              value: controller.requireSymbols,
              onChanged: controller.toggleRequireSymbols,
            ),
            const Divider(height: 12),
            _buildSettingCheckbox(
              title: 'Без повторяющихся символов',
              value: controller.allUnique,
              onChanged: controller.toggleAllUnique,
            ),
            _buildSettingCheckbox(
              title: 'Исключить похожие символы',
              subtitle: '1, l, I, 0, O, o',
              value: controller.excludeSimilar,
              onChanged: controller.toggleExcludeSimilar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCheckbox({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: (next) => onChanged(next ?? false),
    );
  }

  Widget _buildFloatingActions(
    GeneratorController controller,
    ThemeData theme,
  ) {
    final hasPassword = controller.password.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'generate_password',
          tooltip: 'Обновить',
          onPressed: controller.isLoading ? null : controller.generatePassword,
          child: controller.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Icon(Icons.refresh),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: 'copy_password',
          tooltip: 'Копировать',
          onPressed: hasPassword ? _handleCopyPassword : null,
          child: const Icon(Icons.copy),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: 'save_password',
          tooltip: 'Сохранить',
          onPressed: hasPassword ? _handleSavePassword : null,
          child: const Icon(Icons.save),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(
    GeneratorController controller,
    ThemeData theme,
  ) {
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
            Text('Категория', style: theme.textTheme.titleMedium),
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
                          final category = categories[index];
                          return ListTile(
                            leading: Text(
                              category.icon ?? '📁',
                              style: const TextStyle(fontSize: 20),
                            ),
                            title: Text(category.name),
                            subtitle: category.isSystem
                                ? const Text('Системная')
                                : null,
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
