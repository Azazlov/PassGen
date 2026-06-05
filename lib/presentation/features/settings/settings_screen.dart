import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../data/database/database_helper.dart';
import '../../../domain/usecases/auth/change_pin_usecase.dart';
import '../../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../../domain/usecases/log/clear_logs_usecase.dart';
import '../../../domain/usecases/log/get_logs_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';
import '../../../domain/usecases/settings/get_setting_usecase.dart';
import '../../../domain/usecases/settings/set_setting_usecase.dart';
import '../../widgets/app_text_field.dart';
import '../about/about_screen.dart';
import '../auth/auth_controller.dart';
import '../logs/logs_screen.dart';
import 'settings_controller.dart';

/// Экран настроек приложения
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsController(
        getSettingUseCase: context.read<GetSettingUseCase>(),
        setSettingUseCase: context.read<SetSettingUseCase>(),
        changePinUseCase: context.read<ChangePinUseCase>(),
        removePinUseCase: context.read<RemovePinUseCase>(),
        getLogsUseCase: context.read<GetLogsUseCase>(),
        clearLogsUseCase: context.read<ClearLogsUseCase>(),
        logEventUseCase: context.read<LogEventUseCase>(),
        databaseHelper: context.read<DatabaseHelper>(),
      ),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatefulWidget {
  const _SettingsScreenContent();

  @override
  State<_SettingsScreenContent> createState() => _SettingsScreenContentState();
}

class _SettingsScreenContentState extends State<_SettingsScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _autoLockController = TextEditingController(text: '5');
  final _maxAttemptsController = TextEditingController(text: '5');

  int _logsCount = 0;
  bool _biometricLogin = false;

  @override
  void initState() {
    super.initState();
    _loadLogsCount();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  @override
  void dispose() {
    _autoLockController.dispose();
    _maxAttemptsController.dispose();
    super.dispose();
  }

  Future<void> _loadLogsCount() async {
    final count = await context.read<SettingsController>().getLogsCount();
    if (mounted) {
      setState(() => _logsCount = count);
    }
  }

  Future<void> _loadSettings() async {
    final controller = context.read<SettingsController>();
    final authController = context.read<AuthController>();

    final autoLock = await controller.getSetting('security.auto_lock_minutes');
    final maxAttempts = await controller.getSetting('security.max_pin_attempts');

    if (!mounted) return;

    setState(() {
      _autoLockController.text = autoLock ?? '5';
      _maxAttemptsController.text = maxAttempts ?? '5';
      _biometricLogin = authController.authState.isBiometricEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<SettingsController>();
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tabletMin;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Form(
        key: _formKey,
        child: isMobile
            ? _buildSettingsList(theme, controller)
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: _buildSettingsList(theme, controller),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'save_settings',
        onPressed: controller.isLoading ? null : () => _saveAllSettings(context),
        child: controller.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
      ),
    );
  }

  Widget _buildSettingsList(ThemeData theme, SettingsController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Безопасность', theme),
        _buildListTile(
          icon: Icons.pin,
          title: 'Сменить PIN-код',
          onTap: () => _showChangePinDialog(context, controller),
        ),
        _buildListTile(
          icon: Icons.lock_outline,
          title: 'Удалить PIN-код',
          onTap: () => _showRemovePinDialog(context, controller),
          textColor: Colors.red,
        ),
        _buildSwitchTile(
          icon: Icons.fingerprint,
          title: 'Биометрическая аутентификация',
          value: _biometricLogin,
          onChanged: _toggleBiometric,
        ),
        _buildNumberField(
          icon: Icons.timer,
          title: 'Автоблокировка',
          suffix: 'мин',
          controller: _autoLockController,
          min: 1,
          max: 10,
        ),
        _buildNumberField(
          icon: Icons.password,
          title: 'Максимум попыток PIN до блокировки',
          suffix: 'поп.',
          controller: _maxAttemptsController,
          min: 3,
          max: 10,
        ),
        _buildListTile(
          icon: Icons.lock_clock,
          title: 'Экстренная блокировка',
          subtitle: 'Немедленно заблокировать и выйти на экран PIN',
          onTap: () => _confirmEmergencyLock(context),
          textColor: Colors.orange,
        ),
        _buildListTile(
          icon: Icons.history,
          title: 'Журнал безопасности',
          subtitle: 'Записей: $_logsCount',
          onTap: () => _showLogsDialog(context, controller),
        ),
        _buildListTile(
          icon: Icons.delete_sweep,
          title: 'Очистить журнал',
          onTap: () => _confirmClearLogs(context, controller),
          textColor: Colors.orange,
        ),
        _buildListTile(
          icon: Icons.delete_forever,
          title: 'Сбросить все данные',
          subtitle: 'Удалить все пароли, настройки и профили',
          onTap: () => _confirmResetAllData(context, controller),
          textColor: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('О приложении', theme),
        _buildInfoTile(
          icon: Icons.password,
          title: AppConstants.appName,
          subtitle: 'Версия ${AppConstants.appVersion}',
        ),
        _buildInfoTile(
          icon: Icons.person,
          title: 'Разработчик',
          subtitle: AppConstants.developer,
        ),
        _buildListTile(
          icon: Icons.info,
          title: 'Открыть раздел',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
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

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: textColor != null ? TextStyle(color: textColor) : null,
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        secondary: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField({
    required IconData icon,
    required String title,
    required String suffix,
    required TextEditingController controller,
    required int min,
    required int max,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            const SizedBox(width: 12),
            SizedBox(
              width: 132,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  suffixText: suffix,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) => _validateNumber(value, min, max),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAllSettings(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проверьте корректность введённых значений')),
      );
      return;
    }

    final controller = context.read<SettingsController>();

    final messenger = ScaffoldMessenger.of(context);
    final authController = context.read<AuthController>();

    await Future.wait([
      controller.setSetting('security.auto_lock_minutes', _autoLockController.text),
      controller.setSetting('security.max_pin_attempts', _maxAttemptsController.text),
    ]);

    if (!mounted) return;

    await authController.reloadInactivityTimeout();

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Настройки сохранены')),
    );
  }

  String? _validateNumber(String? value, int min, int max) {
    final number = int.tryParse(value ?? '');
    if (number == null) return 'Число';
    if (number < min || number > max) return '$min-$max';
    return null;
  }

  Future<void> _toggleBiometric(bool value) async {
    final authController = context.read<AuthController>();

    if (!value) {
      final pin = await _requestPinForBiometric(
        context,
        submitLabel: 'Отключить',
      );
      if (pin == null || pin.isEmpty) return;

      final success = await authController.disableBiometric(pin);
      if (!mounted) return;
      setState(() => _biometricLogin = !success);
      if (!success) {
        _showErrorDialog(
          context,
          authController.error ?? 'Не удалось отключить биометрию',
        );
      }
      return;
    }

    final pin = await _requestPinForBiometric(
      context,
      submitLabel: 'Включить',
    );
    if (pin == null || pin.isEmpty) return;

    final success = await authController.enableBiometric(pin);
    if (!mounted) return;

    setState(() => _biometricLogin = success);
    if (!success) {
      _showErrorDialog(
        context,
        authController.error ?? 'Не удалось включить биометрию',
      );
    }
  }

  Future<String?> _requestPinForBiometric(
    BuildContext context, {
    required String submitLabel,
  }) async {
    final pinController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подтвердите PIN'),
        content: AppTextField(
          controller: pinController,
          label: 'PIN-код',
          hint: 'Введите текущий PIN',
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(pinController.text),
            child: Text(submitLabel),
          ),
        ],
      ),
    );

    return result;
  }

  Future<void> _showChangePinDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const ChangePinDialog(),
    );

    if (result == null || !context.mounted) return;

    final oldPin = result['oldPin']!;
    final newPin = result['newPin']!;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('PIN-код изменяется...'),
        duration: Duration(seconds: 1),
      ),
    );

    final success = await controller.changePin(oldPin, newPin);

    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    final errorColor = Theme.of(context).colorScheme.error;
    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'PIN-код успешно изменён' : 'Ошибка смены PIN-кода'),
        backgroundColor: success ? null : errorColor,
      ),
    );
  }

  void _showRemovePinDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => RemovePinDialog(
        controller: controller,
        onResult: (success, pin) async {
          Navigator.of(ctx).pop();
          if (success) {
            // При удалении PIN отключаем биометрию
            final authController = context.read<AuthController>();
            if (authController.authState.isBiometricEnabled) {
              await authController.disableBiometric(pin);
              if (mounted) {
                setState(() => _biometricLogin = false);
              }
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? 'PIN-код удалён' : 'Ошибка удаления PIN-кода',
              ),
              backgroundColor:
                  success ? null : Theme.of(context).colorScheme.error,
            ),
          );
        },
      ),
    );
  }

  void _confirmEmergencyLock(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Заблокировать приложение?'),
        content: const Text(
          'Приложение будет немедленно заблокировано. '
          'Для разблокировки потребуется ввести PIN-код.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Заблокировать'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.read<AuthController>().lockApp(reason: 'manual_lock');
  }

  void _confirmResetAllData(
    BuildContext context,
    SettingsController controller,
  ) async {
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить все данные?'),
        content: const Text(
          'ВНИМАНИЕ: Это действие удалит ВСЕ данные безвозвратно:\n\n'
          '• Все сохранённые пароли\n'
          '• Все профили пользователей\n'
          '• Все настройки приложения\n'
          '• Весь журнал безопасности\n\n'
          'Приложение будет сброшено к состоянию как при первой установке.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.resetAllData();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Все данные удалены')));
          await context.read<AuthController>().refreshState();
        } else {
          _showErrorDialog(context, controller.error ?? 'Ошибка сброса данных');
        }
      }
    }
  }

  void _showLogsDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LogsScreen()));
    if (context.mounted) {
      await _loadLogsCount();
    }
  }

  void _confirmClearLogs(
    BuildContext context,
    SettingsController controller,
  ) async {
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистка логов'),
        content: const Text(
          'Вы уверены, что хотите очистить все логи безопасности?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ok = await controller.clearLogs();
      if (!context.mounted) return;
      if (ok) {
        await _loadLogsCount();
        if (!context.mounted) return;
        _showSuccessDialog(context, 'Логи очищены');
      } else {
        _showErrorDialog(context, 'Не удалось очистить логи');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Диалог удаления PIN-кода (StatefulWidget для безопасного управления
/// TextEditingController'ами).
class RemovePinDialog extends StatefulWidget {
  const RemovePinDialog({super.key, required this.controller, required this.onResult});
  final SettingsController controller;
  final void Function(bool success, String pin) onResult;

  @override
  State<RemovePinDialog> createState() => _RemovePinDialogState();
}

class _RemovePinDialogState extends State<RemovePinDialog> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Удаление PIN-кода'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Это действие удалит защиту приложения. Вы уверены?'),
          const SizedBox(height: 16),
          AppTextField(
            controller: _pinController,
            label: 'Подтвердите PIN',
            hint: 'Введите текущий PIN',
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final pin = _pinController.text;
            if (pin.length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите PIN')),
              );
              return;
            }
            final success = await widget.controller.removePin(pin);
            widget.onResult(success, pin);
          },
          child: const Text('Удалить'),
        ),
      ],
    );
  }
}

/// Диалог смены PIN-кода (StatefulWidget для безопасного управления
/// TextEditingController'ами).
class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Смена PIN-кода'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _oldPinController,
            label: 'Старый PIN',
            hint: 'Введите старый PIN',
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _newPinController,
            label: 'Новый PIN',
            hint: 'Введите новый PIN (4-8 цифр)',
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final oldPin = _oldPinController.text;
            final newPin = _newPinController.text;
            if (oldPin.length < 4 || newPin.length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN должен содержать минимум 4 цифры'),
                ),
              );
              return;
            }
            Navigator.of(context).pop({'oldPin': oldPin, 'newPin': newPin});
          },
          child: const Text('Сменить'),
        ),
      ],
    );
  }
}