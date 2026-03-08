import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';
import '../../../domain/entities/auth_result.dart';
import 'pin_input_widget.dart';
import '../../../core/utils/android_security_utils.dart';

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
  final FocusNode _keyboardFocusNode = FocusNode();

  // Маппинг клавиш для ввода цифр
  static final Map<LogicalKeyboardKey, String> _digitKeys = {
    LogicalKeyboardKey.digit0: '0',
    LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.digit1: '1',
    LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.digit2: '2',
    LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.digit3: '3',
    LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.digit4: '4',
    LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.digit5: '5',
    LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.digit6: '6',
    LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.digit7: '7',
    LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.digit8: '8',
    LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.digit9: '9',
    LogicalKeyboardKey.numpad9: '9',
  };

  @override
  void initState() {
    super.initState();
    // Загружаем состояние при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().refreshState();
      // Запрашиваем фокус для захвата клавиатуры
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// Обработка нажатий клавиш физической клавиатуры
  void _handleKeyEvent(KeyEvent event) {
    // Обрабатываем только нажатия (не отпускания)
    if (event is! KeyDownEvent) return;

    final controller = context.read<AuthController>();

    // Игнорируем если контроллер загружается
    if (controller.isLoading) return;

    // Проверяем цифровые клавиши через маппинг
    final digit = _digitKeys[event.logicalKey];
    if (digit != null) {
      controller.addDigit(digit);
      return;
    }

    // Backspace / Delete
    if (event.logicalKey == LogicalKeyboardKey.backspace ||
        event.logicalKey == LogicalKeyboardKey.delete) {
      controller.removeDigit();
      return;
    }

    // Enter (только если PIN завершён)
    if (event.logicalKey == LogicalKeyboardKey.enter &&
        controller.isPinComplete) {
      _handleConfirm();
    }
  }

  /// Подтверждение ввода PIN
  void _handleConfirm() {
    final controller = context.read<AuthController>();
    if (controller.isPinComplete && !controller.isLoading) {
      // Для режима установки PIN
      if (!controller.authState.isPinSetup) {
        controller.setupPin();
      }
    }
  }

  /// Устанавливает флаг защиты от скриншотов для Android
  Future<void> _setSecureFlag() async {
    // FLAG_SECURE = 0x00002000
    // Запрещает скриншоты и запись экрана на Android
    await AndroidSecurityUtils.setSecureFlag(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AuthController>();

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: SafeArea(
          child: controller.isLoading && controller.authState.isPinSetup
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(controller, theme),
        ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 32,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Заголовок
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),

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

              const SizedBox(height: 32),

              // Индикатор PIN
              PinInputWidget(
                pinLength: controller.pinLength,
                maxLength: 8,
                isError: controller.error != null,
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 16),

              // Цифровая клавиатура
              NumericKeypad(
                onDigitTap: (digit) => controller.addDigit(digit),
                onBackspace: () => controller.removeDigit(),
                isLoading: controller.isLoading,
              ),

              const SizedBox(height: 16),

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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Экран ввода PIN
  Widget _buildLoginScreen(AuthController controller, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 32,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Заголовок
              Icon(
                Icons.lock,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),

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

              const SizedBox(height: 32),

              // Индикатор PIN
              PinInputWidget(
                pinLength: controller.pinLength,
                maxLength: 8,
                isError: controller.error != null,
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 16),

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
              const SizedBox(height: 16),
            ],
          ),
        ),
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
