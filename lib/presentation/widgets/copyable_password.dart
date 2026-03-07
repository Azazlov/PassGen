import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Виджет для отображения копируемого текста (пароля)
/// 
/// Копирует текст в буфер обмена с очисткой через 60 секунд
class CopyablePassword extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback? onTap;
  final bool isEmpty;

  const CopyablePassword({
    super.key,
    required this.label,
    required this.text,
    this.onTap,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildContent(context, theme),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    if (isEmpty || text.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Semantics(
      label: '$label: $text',
      button: true,
      hint: 'Дважды нажмите для копирования',
      child: GestureDetector(
        onTap: () {
          _copyToClipboard(context, text);
          onTap?.call();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label: 'Копировать',
                  child: Icon(
                    Icons.copy,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Копирование в буфер обмена с очисткой через 60 секунд
  void _copyToClipboard(BuildContext context, String value) {
    // Копируем в буфер
    Clipboard.setData(ClipboardData(text: value));

    // Показываем уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, size: 20),
            const SizedBox(width: 12),
            const Text('Пароль скопирован'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Открыть',
          textColor: Theme.of(context).colorScheme.onSecondary,
          onPressed: () {
            // Можно добавить навигацию к хранилищу
          },
        ),
      ),
    );

    // Очищаем буфер через 60 секунд (согласно ТЗ)
    Future.delayed(const Duration(seconds: 60), () {
      Clipboard.setData(ClipboardData(text: ''));
      
      // Показываем уведомление об очистке, если виджет ещё в дереве
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Буфер обмена очищен'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          text.isEmpty ? 'Нет данных' : text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
