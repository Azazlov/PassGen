import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/navigation_service.dart';

/// Виджет для отображения копируемого текста (пароля)
///
/// Копирует текст в буфер обмена с очисткой через настраиваемое время
/// Показывает уведомление при успешном копировании
class CopyablePassword extends StatefulWidget {
  const CopyablePassword({
    super.key,
    required this.label,
    required this.text,
    this.onTap,
    this.isEmpty = false,
    this.clipboardTimeoutSeconds = 60, // v0.5.1: настраиваемое время
  });
  final String label;
  final String text;
  final VoidCallback? onTap;
  final bool isEmpty;
  final int clipboardTimeoutSeconds; // v0.5.1: время очистки буфера (сек)

  @override
  State<CopyablePassword> createState() => _CopyablePasswordState();
}

class _CopyablePasswordState extends State<CopyablePassword> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
    if (widget.isEmpty || widget.text.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Semantics(
      label: '${widget.label}: ${widget.text}',
      button: true,
      hint: 'Дважды нажмите для копирования',
      child: GestureDetector(
        onTap: () {
          _copyToClipboard(context, widget.text);
          widget.onTap?.call();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label: 'Копировать пароль в буфер обмена',
                  button: true,
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

  /// Копирование в буфер обмена с очисткой через настраиваемое время (v0.5.1)
  void _copyToClipboard(BuildContext context, String value) {
    // Копируем в буфер
    Clipboard.setData(ClipboardData(text: value));

    // Показываем уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            // Иконка вместо Lottie анимации
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 12),
            Text('Пароль скопирован'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Открыть',
          textColor: Theme.of(context).colorScheme.onSecondary,
          onPressed: () {
            // Навигация к хранилищу
            try {
              final navigationService = context.read<NavigationService>();
              navigationService.navigateToStorage();
            } catch (e) {
              // Если сервис недоступен, игнорируем
              debugPrint('NavigationService not available: $e');
            }
          },
        ),
      ),
    );

    // Очищаем буфер через настраиваемое время (v0.5.1)
    Future.delayed(Duration(seconds: widget.clipboardTimeoutSeconds), () {
      Clipboard.setData(const ClipboardData(text: ''));

      // Показываем уведомление об очистке, если виджет ещё в дереве
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Буфер обмена очищен (${widget.clipboardTimeoutSeconds} сек)',
            ),
            duration: const Duration(seconds: 2),
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
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Center(
        child: Text(
          widget.text.isEmpty ? 'Нет данных' : widget.text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
