import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/entities/password_history_entry.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import 'storage_controller.dart';

/// Панель деталей пароля
class StorageDetailPane extends StatefulWidget {
  const StorageDetailPane({super.key, this.entry});
  final PasswordEntry? entry;

  @override
  State<StorageDetailPane> createState() => _StorageDetailPaneState();
}

class _StorageDetailPaneState extends State<StorageDetailPane> {
  String? _decryptedPassword;
  bool _isDecrypting = false;
  int? _decryptingEntryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<StorageController>();
    final effectiveEntry = controller.selectedEntry ?? widget.entry;
    if (effectiveEntry == null) {
      return const StorageEmptyDetailState();
    }

    // Сбрасываем расшифровку если изменилась запись
    final entryId = effectiveEntry.id ?? effectiveEntry.createdAt.millisecondsSinceEpoch;
    if (_decryptingEntryId != entryId) {
      _decryptingEntryId = entryId;
      _decryptedPassword = null;
      _isDecrypting = false;
    }

    // Запускаем расшифровку, если ещё не запущена
    if (effectiveEntry.isEncrypted && !effectiveEntry.hasPlainText && !_isDecrypting) {
      _isDecrypting = true;
      controller.decryptEntryPassword(effectiveEntry).then((password) {
        if (mounted) {
          setState(() {
            _decryptedPassword = password;
            _isDecrypting = false;
          });
        }
      });
    }

    // Если пароль уже расшифрован (в процессе текущей сессии)
    final passwordText = effectiveEntry.hasPlainText
        ? effectiveEntry.password!
        : (_decryptedPassword ?? (effectiveEntry.isEncrypted
            ? (_isDecrypting ? 'Расшифровка...' : '')
            : effectiveEntry.password ?? ''));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              FutureBuilder<List<Category>>(
                future: context.read<GetCategoriesUseCase>().execute(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];
                  final category = effectiveEntry.categoryId != null
                      ? categories.cast<Category?>().firstWhere(
                          (c) => c?.id == effectiveEntry.categoryId,
                          orElse: () => null,
                        )
                      : null;
                  return Text(
                    category?.icon ?? '📁',
                    style: const TextStyle(fontSize: 32),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectiveEntry.service,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      effectiveEntry.login ?? 'Нет логина',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Пароль
          _buildPasswordField(context, theme, passwordText),

          const SizedBox(height: 24),

          // Категория
          _buildCategoryField(context, theme, effectiveEntry),

          if ((effectiveEntry.url ?? '').isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPlainField(
              context,
              theme,
              title: 'URL',
              value: effectiveEntry.url!,
              icon: Icons.link,
            ),
          ],

          if ((effectiveEntry.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPlainField(
              context,
              theme,
              title: 'Заметки',
              value: effectiveEntry.notes!,
              icon: Icons.note_outlined,
            ),
          ],

          const SizedBox(height: 24),

          // Даты
          _buildDatesFields(theme, effectiveEntry),

          const SizedBox(height: 32),

          // Кнопки действий
          _buildActionButtons(context, theme, controller, effectiveEntry),

          const SizedBox(height: 24),

          // История изменений пароля
          _buildHistorySection(context, theme, controller, effectiveEntry),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    ThemeData theme,
    StorageController controller,
    PasswordEntry effectiveEntry,
  ) {
    return FutureBuilder<List<PasswordHistoryEntry>>(
      future: controller.getHistoryForEntry(effectiveEntry.id),
      builder: (context, snapshot) {
        final history = snapshot.data ?? const <PasswordHistoryEntry>[];
        return Card(
          child: Theme(
            // Убираем разделители ExpansionTile (визуальный шум).
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: const Icon(Icons.history),
              title: Text('История изменений',
                  style: theme.textTheme.titleSmall),
              subtitle: Text(
                snapshot.connectionState == ConnectionState.waiting
                    ? 'Загрузка...'
                    : (history.isEmpty
                        ? 'Изменений нет'
                        : 'Версий: ${history.length}'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              children: history.isEmpty
                  ? const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Предыдущие версии пароля не сохранены.',
                        ),
                      ),
                    ]
                  : history
                      .map((h) => _buildHistoryTile(theme, h))
                      .toList(growable: false),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTile(
    ThemeData theme,
    PasswordHistoryEntry h,
  ) {
    return GestureDetector(
      onTap: () => _showHistoryPasswordDialog(h),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_clock,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(h.createdAt),
                    style: theme.textTheme.bodyMedium,
                  ),
                  if ((h.reason ?? '').isNotEmpty)
                    Text(
                      h.reason!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  Text(
                    'Нажмите для просмотра',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryPasswordDialog(PasswordHistoryEntry h) {
    final controller = context.read<StorageController>();

    showDialog(
      context: context,
      builder: (ctx) {
        return _HistoryPasswordDialog(
          entry: h,
          controller: controller,
          onPasswordTap: (password) {
            Clipboard.setData(ClipboardData(text: password));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Пароль скопирован')),
            );
          },
        );
      },
    );
  }

  Widget _historyField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    ThemeData theme,
    String displayText,
  ) {
    return _passwordCard(context, theme, displayText);
  }

  /// Карточка отображения пароля
  Widget _passwordCard(
    BuildContext context,
    ThemeData theme,
    String displayText,
  ) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: Semantics(
                    label: 'Пароль: $displayText',
                    value: displayText,
                    child: Text(
                      displayText,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Semantics(
                  label: 'Копировать пароль в буфер обмена',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: displayText),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Пароль скопирован')),
                      );
                    },
                    tooltip: 'Копировать пароль',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField(
    BuildContext context,
    ThemeData theme,
    PasswordEntry effectiveEntry,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Категория', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            FutureBuilder<List<Category>>(
              future: context.read<GetCategoriesUseCase>().execute(),
              builder: (context, snapshot) {
                if (effectiveEntry.categoryId == null) {
                  return Text('Без категории',
                      style: theme.textTheme.bodyLarge);
                }
                final categories = snapshot.data ?? [];
                final match = categories.cast<Category?>().firstWhere(
                      (c) => c?.id == effectiveEntry.categoryId,
                      orElse: () => null,
                    );
                final name = match?.name ?? '#${effectiveEntry.categoryId}';
                return Text(name, style: theme.textTheme.bodyLarge);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlainField(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesFields(ThemeData theme, PasswordEntry effectiveEntry) {
    final expireDays = effectiveEntry.expireDays;
    Duration? remaining;
    bool isExpired = false;
    if (expireDays != null && expireDays > 0) {
      final expiryDate = effectiveEntry.createdAt.add(Duration(days: expireDays));
      remaining = expiryDate.difference(DateTime.now());
      isExpired = remaining.isNegative;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Создан', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(effectiveEntry.createdAt),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (effectiveEntry.updatedAt != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Обновлено', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          _formatRelativeDate(effectiveEntry.updatedAt!),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (expireDays != null && expireDays > 0) ...[
          const SizedBox(height: 16),
          Card(
            color: isExpired
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpired ? Icons.warning_amber_rounded : Icons.schedule,
                    size: 20,
                    color: isExpired
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExpired ? 'Срок действия истёк' : 'Действует до',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isExpired
                                ? theme.colorScheme.onErrorContainer
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isExpired
                              ? 'Истёк ${_formatDuration(-remaining!)} назад'
                              : 'Осталось ${_formatDuration(remaining!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isExpired
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays >= 30) {
      final months = d.inDays ~/ 30;
      final days = d.inDays % 30;
      if (months > 0 && days > 0) return '$months мес. $days дн.';
      if (months > 0) return '$months мес.';
      return '$days дн.';
    }
    if (d.inDays > 0) return '${d.inDays} дн.';
    if (d.inHours > 0) return '${d.inHours} ч.';
    if (d.inMinutes > 0) return '${d.inMinutes} мин.';
    return 'менее минуты';
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    StorageController controller,
    PasswordEntry effectiveEntry,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final editBtn = ElevatedButton.icon(
          onPressed: () => _showEditDialog(context, controller, effectiveEntry),
          icon: const Icon(Icons.edit),
          label: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Редактировать'),
          ),
        );
        final regenBtn = OutlinedButton.icon(
          onPressed: () => _showRegenerateConfirmation(context, controller, effectiveEntry),
          icon: const Icon(Icons.refresh),
          label: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Регенерировать'),
          ),
        );
        final deleteBtn = OutlinedButton.icon(
          onPressed: () => _showDeleteConfirmation(context, controller),
          icon: const Icon(Icons.delete),
          label: const Text('Удалить'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        );

        // На узких экранах (< 480px) располагаем кнопки вертикально
        if (constraints.maxWidth < 480) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: editBtn),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: regenBtn),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: deleteBtn),
            ],
          );
        }

        // На широких экранах - горизонтально
        return Row(
          children: [
            Expanded(child: editBtn),
            const SizedBox(width: 12),
            Expanded(child: regenBtn),
            const SizedBox(width: 12),
            Expanded(child: deleteBtn),
          ],
        );
      },
    );
  }

  void _showRegenerateConfirmation(
    BuildContext context,
    StorageController controller,
    PasswordEntry entryForRegen,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Регенерировать пароль?'),
        content: const Text(
          'Будет сгенерирован новый пароль с теми же настройками длины '
          'и набора символов, что и текущий. Предыдущая версия '
          'сохранится в истории.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Генерация нового пароля...'),
                  duration: Duration(seconds: 1),
                ),
              );
              controller.regeneratePassword(entryForRegen).then((ok) {
                if (!context.mounted) return;
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Пароль регенерирован'
                          : (controller.error ?? 'Не удалось регенерировать'),
                    ),
                  ),
                );
              });
            },
            child: const Text('Регенерировать'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    StorageController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пароль?'),
        content: const Text('Вы уверены, что хотите удалить этот пароль?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteCurrentPassword();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StorageController controller,
    PasswordEntry entry,
  ) {
    final serviceController = TextEditingController(text: entry.service);
    final loginController = TextEditingController(text: entry.login ?? '');
    final urlController = TextEditingController(text: entry.url ?? '');
    final notesController = TextEditingController(text: entry.notes ?? '');
    int? selectedCategoryId = entry.categoryId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Редактировать запись'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serviceController,
                  decoration: const InputDecoration(
                    labelText: 'Сервис',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: loginController,
                  decoration: const InputDecoration(
                    labelText: 'Логин',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Заметки',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Category>>(
                  future: context.read<GetCategoriesUseCase>().execute(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final categories = snapshot.data!;
                    final validValue = categories.any((c) => c.id == selectedCategoryId)
                        ? selectedCategoryId
                        : null;
                    if (validValue != selectedCategoryId) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => selectedCategoryId = null);
                      });
                    }
                    return DropdownButtonFormField<int?>(
                      initialValue: validValue,
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Без категории'),
                        ),
                        ...categories.map(
                          (c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text('${c.icon} ${c.name}'),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => selectedCategoryId = v),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final service = serviceController.text.trim();
                if (service.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Сервис не может быть пустым'),
                    ),
                  );
                  return;
                }
                final loginText = loginController.text.trim();
                final urlText = urlController.text.trim();
                final notesText = notesController.text.trim();
                final updated = entry.copyWith(
                  service: service,
                  login: loginText.isEmpty ? null : loginText,
                  url: urlText.isEmpty ? null : urlText,
                  notes: notesText.isEmpty ? null : notesText,
                  categoryId: selectedCategoryId,
                  clearUrl: urlText.isEmpty,
                  clearNotes: notesText.isEmpty,
                );
                final ok = await controller.updateEntry(updated);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Запись обновлена'
                          : (controller.error ?? 'Не удалось обновить'),
                    ),
                  ),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(date.year, date.month, date.day);

    if (logDate == today) {
      return 'Сегодня';
    } else if (logDate == yesterday) {
      return 'Вчера';
    } else {
      return _formatDate(date);
    }
  }
}

/// Пустое состояние панели деталей
class StorageEmptyDetailState extends StatelessWidget {
  const StorageEmptyDetailState({
    super.key,
    this.icon = Icons.touch_app,
    this.title = 'Выберите пароль',
    this.subtitle = 'или создайте новый',
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Диалог просмотра старого пароля из истории.
///
/// Открывается сразу с индикатором загрузки, расшифровывает пароль
/// асинхронно и обновляет содержимое по готовности.
class _HistoryPasswordDialog extends StatefulWidget {
  const _HistoryPasswordDialog({
    required this.entry,
    required this.controller,
    required this.onPasswordTap,
  });

  final PasswordHistoryEntry entry;
  final StorageController controller;
  final void Function(String password) onPasswordTap;

  @override
  State<_HistoryPasswordDialog> createState() => _HistoryPasswordDialogState();
}

class _HistoryPasswordDialogState extends State<_HistoryPasswordDialog> {
  String? _password;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _decrypt();
  }

  Future<void> _decrypt() async {
    try {
      final password = await widget.controller.decryptHistoryPassword(widget.entry);
      if (!mounted) return;
      setState(() {
        _password = password;
        _isLoading = false;
        _hasError = password == null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = widget.entry;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.history, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              h.reason ?? 'Предыдущая версия',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(context, 'Дата', _formatDate(h.createdAt)),
          const SizedBox(height: 12),
          _buildField(context, 'Сервис', h.service),
          if (h.login != null) ...[
            const SizedBox(height: 8),
            _buildField(context, 'Логин', h.login!),
          ],
          const SizedBox(height: 12),
          Text('Пароль', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : SelectableText(
                    _hasError
                        ? 'Не удалось расшифровать'
                        : _password!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
      actions: [
        if (!_isLoading && _password != null)
          TextButton.icon(
            onPressed: () => widget.onPasswordTap(_password!),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Копировать'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }

  Widget _buildField(BuildContext context, String label, String value) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(value, style: t.textTheme.bodyMedium),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inHours < 1) return '${diff.inMinutes} мин. назад';
    if (diff.inDays < 1) return '${diff.inHours} ч. назад';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
