import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../../data/database/database_helper.dart';
import '../../../domain/usecases/auth/change_pin_usecase.dart';
import '../../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../../domain/usecases/log/clear_logs_usecase.dart';
import '../../../domain/usecases/log/get_logs_usecase.dart';
import '../../../domain/usecases/log/log_event_usecase.dart';
import '../../../domain/usecases/settings/get_setting_usecase.dart';
import '../../../domain/usecases/settings/set_setting_usecase.dart';
import '../../widgets/app_text_field.dart';
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
  final _defaultLengthController = TextEditingController(text: '16');
  final _backupIntervalController = TextEditingController(text: '7');

  int _logsCount = 0;
  bool _biometricLogin = false;
  bool _excludeSimilarByDefault = false;
  bool _useSymbolsByDefault = true;
  bool _autoBackup = false;

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
    _defaultLengthController.dispose();
    _backupIntervalController.dispose();
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
    final defaultLength = await controller.getSetting(
      'generator.default_length',
    );
    final excludeSimilar = await controller.getSetting(
      'generator.exclude_similar',
    );
    final useSymbols = await controller.getSetting('generator.use_symbols');
    final autoBackup = await controller.getSetting('backup.auto');
    final backupInterval = await controller.getSetting('backup.interval_days');

    if (!mounted) return;

    setState(() {
      _autoLockController.text = autoLock ?? '5';
      _maxAttemptsController.text = maxAttempts ?? '5';
      _defaultLengthController.text = defaultLength ?? '16';
      _backupIntervalController.text = backupInterval ?? '7';
      _biometricLogin = authController.authState.isBiometricEnabled;
      _excludeSimilarByDefault = _parseBool(excludeSimilar);
      _useSymbolsByDefault = useSymbols == null ? true : _parseBool(useSymbols);
      _autoBackup = _parseBool(autoBackup);
    });
  }

  bool _parseBool(String? value) {
    return value == 'true';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Form(
        key: _formKey,
        child: ListView(
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
              settingKey: 'security.auto_lock_minutes',
            ),
            _buildNumberField(
              icon: Icons.password,
              title: 'Максимум попыток PIN до блокировки',
              suffix: 'поп.',
              controller: _maxAttemptsController,
              min: 3,
              max: 10,
              settingKey: 'security.max_pin_attempts',
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
            _buildSectionHeader('Генератор', theme),
            _buildNumberField(
              icon: Icons.straighten,
              title: 'Длина по умолчанию',
              suffix: 'симв.',
              controller: _defaultLengthController,
              min: 4,
              max: 64,
              settingKey: 'generator.default_length',
            ),
            _buildSwitchTile(
              icon: Icons.block,
              title: 'Исключать похожие символы',
              value: _excludeSimilarByDefault,
              onChanged: (value) => _saveSwitchSetting(
                key: 'generator.exclude_similar',
                value: value,
                update: () => _excludeSimilarByDefault = value,
              ),
            ),
            _buildSwitchTile(
              icon: Icons.tag,
              title: 'Использовать спецсимволы',
              value: _useSymbolsByDefault,
              onChanged: (value) => _saveSwitchSetting(
                key: 'generator.use_symbols',
                value: value,
                update: () => _useSymbolsByDefault = value,
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Резервное копирование', theme),
            _buildSwitchTile(
              icon: Icons.backup,
              title: 'Автоматическое резервное копирование',
              value: _autoBackup,
              onChanged: (value) => _saveSwitchSetting(
                key: 'backup.auto',
                value: value,
                update: () => _autoBackup = value,
              ),
            ),
            _buildNumberField(
              icon: Icons.event_repeat,
              title: 'Интервал резервного копирования',
              suffix: 'дн.',
              controller: _backupIntervalController,
              min: 1,
              max: 365,
              settingKey: 'backup.interval_days',
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
              onTap: () =>
                  context.read<NavigationService>().navigateTo(AppTab.about),
            ),
          ],
        ),
      ),
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
    required String settingKey,
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
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'Сохранить',
                    onPressed: () => _saveNumberSetting(
                      controller: controller,
                      min: min,
                      max: max,
                      settingKey: settingKey,
                    ),
                  ),
                ),
                validator: (value) => _validateNumber(value, min, max),
                onFieldSubmitted: (_) => _saveNumberSetting(
                  controller: controller,
                  min: min,
                  max: max,
                  settingKey: settingKey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateNumber(String? value, int min, int max) {
    final number = int.tryParse(value ?? '');
    if (number == null) return 'Число';
    if (number < min || number > max) return '$min-$max';
    return null;
  }

  Future<void> _saveNumberSetting({
    required TextEditingController controller,
    required int min,
    required int max,
    required String settingKey,
  }) async {
    final error = _validateNumber(controller.text, min, max);
    if (error != null) {
      _showErrorDialog(context, 'Введите число в диапазоне $min-$max');
      return;
    }

    await context.read<SettingsController>().setSetting(
      settingKey,
      controller.text,
    );
  }

  Future<void> _saveSwitchSetting({
    required String key,
    required bool value,
    required VoidCallback update,
  }) async {
    setState(update);
    await context.read<SettingsController>().setSetting(key, value.toString());
  }

  Future<void> _toggleBiometric(bool value) async {
    final authController = context.read<AuthController>();

    if (!value) {
      final success = await authController.disableBiometric();
      if (!mounted) return;
      setState(() => _biometricLogin = !success);
      if (!success) {
        _showErrorDialog(context, 'Не удалось отключить биометрию');
      }
      return;
    }

    final pin = await _requestPinForBiometric(context);
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

  Future<String?> _requestPinForBiometric(BuildContext context) async {
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
            child: const Text('Включить'),
          ),
        ],
      ),
    );

    pinController.dispose();
    return result;
  }

  void _showChangePinDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Смена PIN-кода'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: oldPinController,
              label: 'Старый PIN',
              hint: 'Введите старый PIN',
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: newPinController,
              label: 'Новый PIN',
              hint: 'Введите новый PIN (4-8 цифр)',
              obscureText: true,
              keyboardType: TextInputType.number,
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
              if (oldPinController.text.length < 4 ||
                  newPinController.text.length < 4) {
                _showErrorDialog(ctx, 'PIN должен содержать минимум 4 цифры');
                return;
              }
              Navigator.of(ctx).pop();
              final success = await controller.changePin(
                oldPinController.text,
                newPinController.text,
              );
              if (context.mounted) {
                if (success) {
                  _showSuccessDialog(context, 'PIN-код успешно изменён');
                } else {
                  _showErrorDialog(context, 'Ошибка смены PIN-кода');
                }
              }
            },
            child: const Text('Сменить'),
          ),
        ],
      ),
    );

    oldPinController.dispose();
    newPinController.dispose();
  }

  void _showRemovePinDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    final pinController = TextEditingController();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удаление PIN-кода'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Это действие удалит защиту приложения. Вы уверены?'),
            const SizedBox(height: 16),
            AppTextField(
              controller: pinController,
              label: 'Подтвердите PIN',
              hint: 'Введите текущий PIN',
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (pinController.text.length < 4) {
                _showErrorDialog(ctx, 'Введите PIN');
                return;
              }
              Navigator.of(ctx).pop();
              final success = await controller.removePin(pinController.text);
              if (context.mounted) {
                if (success) {
                  _showSuccessDialog(context, 'PIN-код удалён');
                } else {
                  _showErrorDialog(context, 'Ошибка удаления PIN-кода');
                }
              }
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    pinController.dispose();
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
            Text(message),
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
            Text(message),
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
