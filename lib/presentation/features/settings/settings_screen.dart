import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_controller.dart';
import '../../../domain/usecases/settings/get_setting_usecase.dart';
import '../../../domain/usecases/settings/set_setting_usecase.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/auth/change_pin_usecase.dart';
import '../../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../../domain/usecases/log/get_logs_usecase.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_text_field.dart';
import '../categories/categories_screen.dart';
import '../logs/logs_screen.dart';

/// Экран настроек приложения
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsController(
        getSettingUseCase: context.read<GetSettingUseCase>(),
        setSettingUseCase: context.read<SetSettingUseCase>(),
        getCategoriesUseCase: context.read<GetCategoriesUseCase>(),
        changePinUseCase: context.read<ChangePinUseCase>(),
        removePinUseCase: context.read<RemovePinUseCase>(),
        getLogsUseCase: context.read<GetLogsUseCase>(),
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
  int _logsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLogsCount();
  }

  Future<void> _loadLogsCount() async {
    final count = await context.read<SettingsController>().getLogsCount();
    if (mounted) {
      setState(() => _logsCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Секция: Безопасность
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

          const SizedBox(height: 16),

          // Секция: Данные
          _buildSectionHeader('Данные', theme),
          _buildListTile(
            icon: Icons.folder,
            title: 'Категории',
            subtitle: 'Управление категориями паролей',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Секция: Логи
          _buildSectionHeader('Журнал событий', theme),
          _buildListTile(
            icon: Icons.history,
            title: 'Просмотр логов',
            subtitle: 'Записей: $_logsCount',
            onTap: () => _showLogsDialog(context, controller),
          ),
          _buildListTile(
            icon: Icons.delete_sweep,
            title: 'Очистить логи',
            onTap: () => _confirmClearLogs(context, controller),
            textColor: Colors.orange,
          ),

          const SizedBox(height: 16),

          // Секция: О приложении
          _buildSectionHeader('О приложении', theme),
          _buildListTile(
            icon: Icons.info,
            title: 'Версия',
            subtitle: '0.4.0',
            onTap: () => _showInfoDialog(
              context,
              'PassGen',
              'Менеджер паролей с локальным шифрованием\n\nВерсия: 0.4.0\nFlutter + SQLite\nChaCha20-Poly1305',
            ),
          ),
          _buildListTile(
            icon: Icons.description,
            title: 'Лицензия',
            subtitle: 'MIT License',
            onTap: () => _showInfoDialog(
              context,
              'Лицензия',
              'MIT License\n\nCopyright (c) 2024',
            ),
          ),
        ],
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
        title: Text(title, style: textColor != null ? TextStyle(color: textColor) : null),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, SettingsController controller) async {
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
              if (oldPinController.text.length < 4 || newPinController.text.length < 4) {
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

  void _showRemovePinDialog(BuildContext context, SettingsController controller) async {
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

  void _showLogsDialog(BuildContext context, SettingsController controller) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LogsScreen()),
    );
  }

  void _confirmClearLogs(BuildContext context, SettingsController controller) async {
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистка логов'),
        content: const Text('Вы уверены, что хотите очистить все логи безопасности?'),
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
      _showInfoDialog(context, 'Очистка', 'Очистка логов будет реализована в следующей версии');
    }
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
