import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';
import '../../../domain/entities/auth_result.dart';
import 'pin_input_widget.dart';

/// Экран аутентификации
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthScreenContent();
  }
}

class _AuthScreenContent extends StatefulWidget {
  const _AuthScreenContent();

  @override
  State<_AuthScreenContent> createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends State<_AuthScreenContent> {
  @override
  void initState() {
    super.initState();
    // Загружаем состояние при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().refreshState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: controller.isLoading && controller.authState.isPinSetup
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(controller, theme),
      ),
    );
  }

  Widget _buildContent(AuthController controller, ThemeData theme) {
    // Если PIN не установлен - показываем режим установки
    if (!controller.authState.isPinSetup) {
      return _buildSetupScreen(controller, theme);
    }

    // Если заблокировано - показываем экран блокировки
    if (controller.authState.isLocked) {
      return _buildLockoutScreen(controller, theme);
    }

    // Обычный экран ввода PIN
    return _buildLoginScreen(controller, theme);
  }

  /// Экран установки PIN
  Widget _buildSetupScreen(AuthController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Заголовок
          Icon(
            Icons.lock_outline,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),

          Text(
            'Установка PIN-кода',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Придумайте PIN-код из 4-8 цифр',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Индикатор PIN
          PinInputWidget(
            pinLength: controller.pinLength,
            maxLength: 8,
            isError: controller.error != null,
          ),

          const SizedBox(height: 48),

          // Ошибка
          if (controller.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.error!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 24),

          // Цифровая клавиатура
          NumericKeypad(
            onDigitTap: (digit) => controller.addDigit(digit),
            onBackspace: () => controller.removeDigit(),
            isLoading: controller.isLoading,
          ),

          const SizedBox(height: 24),

          // Кнопка подтверждения
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isPinComplete && !controller.isLoading
                  ? () async {
                      final success = await controller.setupPin();
                      if (success && mounted) {
                        // PIN установлен успешно
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Установить PIN'),
            ),
          ),
        ],
      ),
    );
  }

  /// Экран ввода PIN
  Widget _buildLoginScreen(AuthController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Заголовок
          Icon(
            Icons.lock,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),

          Text(
            'Введите PIN-код',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Осталось попыток: ${controller.authState.remainingAttempts ?? 5}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 48),

          // Индикатор PIN
          PinInputWidget(
            pinLength: controller.pinLength,
            maxLength: 8,
            isError: controller.error != null,
          ),

          const SizedBox(height: 48),

          // Ошибка
          if (controller.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.error!,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => controller.clearError(),
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Цифровая клавиатура
          NumericKeypad(
            onDigitTap: (digit) async {
              controller.addDigit(digit);
              // Автопроверка при вводе 4+ цифр
              if (controller.pinLength >= 4) {
                await Future.delayed(const Duration(milliseconds: 200));
                final result = await controller.verifyPin();

                if (!mounted) return;

                switch (result) {
                  case AuthResult.success:
                    // Успешный вход - выходим из экрана
                    break;
                  case AuthResult.wrongPin:
                    controller.clearPin();
                    HapticFeedback.vibrate();
                    break;
                  case AuthResult.locked:
                    controller.clearPin();
                    HapticFeedback.vibrate();
                    break;
                  case AuthResult.notSetup:
                    break;
                }
              }
            },
            onBackspace: () => controller.removeDigit(),
            isLoading: controller.isLoading,
          ),
        ],
      ),
    );
  }

  /// Экран блокировки
  Widget _buildLockoutScreen(AuthController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Заголовок
          Icon(
            Icons.lock_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),

          Text(
            'Слишком много попыток',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'В целях безопасности ввод заблокирован',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Таймер обратного отсчёта
          _LockoutTimer(controller: controller, theme: theme),

          const SizedBox(height: 48),

          // Кнопка обновления
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.refreshState(),
              icon: const Icon(Icons.refresh),
              label: const Text('Проверить снова'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Виджет таймера обратного отсчёта для блокировки
class _LockoutTimer extends StatefulWidget {
  final AuthController controller;
  final ThemeData theme;

  const _LockoutTimer({
    required this.controller,
    required this.theme,
  });

  @override
  State<_LockoutTimer> createState() => _LockoutTimerState();
}

class _LockoutTimerState extends State<_LockoutTimer> {
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _updateTimer();
  }

  void _updateTimer() {
    setState(() {
      _secondsRemaining = widget.controller.authState.lockoutSecondsRemaining;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Обновляем таймер каждую секунду
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateTimer();
        // Проверяем, не истёк ли таймер
        if (_secondsRemaining <= 0) {
          widget.controller.refreshState();
        }
      }
    });

    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;

    return Column(
      children: [
        Text(
          'Разблокировка через',
          style: widget.theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: widget.theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.theme.colorScheme.error,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
