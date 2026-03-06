import 'package:flutter/material.dart';

/// Виджет ввода PIN-кода с цифровыми ячейками
class PinInputWidget extends StatelessWidget {
  final int pinLength;
  final int maxLength;
  final bool isError;
  final bool isLocked;
  final VoidCallback? onDigitTap;

  const PinInputWidget({
    super.key,
    this.pinLength = 0,
    this.maxLength = 8,
    this.isError = false,
    this.isLocked = false,
    this.onDigitTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Ячейки для ввода PIN
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLength, (index) {
            final isFilled = index < pinLength;
            final isLast = index == pinLength;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isError
                      ? theme.colorScheme.error
                      : isLast && !isFilled
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isLast && !isFilled
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isFilled
                    ? const Icon(
                        Icons.circle,
                        size: 20,
                      )
                    : null,
              ),
            );
          }),
        ),

        // Сообщение об ошибке или блокировке
        if (isError || isLocked) ...[
          const SizedBox(height: 16),
          Text(
            isLocked
                ? 'Слишком много попыток. Подождите...'
                : 'Неверный PIN',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

/// Виджет цифровой клавиатуры
class NumericKeypad extends StatelessWidget {
  final Function(String) onDigitTap;
  final VoidCallback? onBackspace;
  final bool isLoading;

  const NumericKeypad({
    super.key,
    required this.onDigitTap,
    this.onBackspace,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Ряды 1-3, 4-6, 7-9
          for (var row = 0; row < 3; row++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (col) {
                  final digit = row * 3 + col + 1;
                  return _KeypadButton(
                    label: digit.toString(),
                    onTap: isLoading ? null : () => onDigitTap(digit.toString()),
                    isLoading: isLoading,
                  );
                }),
              ),
            ),

          // Ряд 0, backspace
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _KeypadButton(
                  label: '',
                  onTap: null,
                  isLoading: isLoading,
                ),
                _KeypadButton(
                  label: '0',
                  onTap: isLoading ? null : () => onDigitTap('0'),
                  isLoading: isLoading,
                ),
                _KeypadButton(
                  label: '',
                  icon: Icons.backspace_outlined,
                  onTap: isLoading ? null : onBackspace,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _KeypadButton({
    required this.label,
    this.icon,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Center(
                child: icon != null
                    ? Icon(icon, size: 28)
                    : Text(
                        label,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
              ),
      ),
    );
  }
}
