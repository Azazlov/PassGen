import 'package:flutter/material.dart';
import '../../../core/constants/breakpoints.dart';

/// Адаптивная кнопка с иконкой и текстом
/// 
/// Автоматически подстраивает высоту под тип устройства:
/// - Мобильный: 48dp
/// - Планшет/Десктоп: 40dp
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonStyle? style;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= Breakpoints.desktopMin;
    
    // Адаптивная высота: 48dp для мобильных, 40dp для десктопа
    final buttonHeight = isDesktop ? 40.0 : 48.0;

    return Semantics(
      button: true,
      label: isLoading ? 'Загрузка' : label,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ??
            ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(buttonHeight),
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: isDesktop ? Spacing.sm : Spacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Semantics(
                      hidden: true,
                      child: Icon(icon, color: theme.colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
