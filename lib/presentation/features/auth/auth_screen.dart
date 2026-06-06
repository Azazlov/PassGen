import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/utils/android_security_utils.dart';
import '../../../data/database/database_helper.dart';
import '../../../domain/entities/auth_result.dart';
import '../../../domain/entities/profile.dart';
import 'auth_controller.dart';
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
      // Устанавливаем защиту от скриншотов
      _setSecureFlag();
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
  void _handleConfirm() async {
    final controller = context.read<AuthController>();
    if (controller.isPinComplete && !controller.isLoading) {
      // Для режима установки PIN
      if (!controller.authState.isPinSetup) {
        await controller.setupPin();
      } else {
        // Для режима входа
        final result = await controller.verifyPin();

        if (!mounted) return;

        // Обрабатываем результат
        switch (result) {
          case AuthResult.success:
            // Успешный вход - приложение само обновит UI
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
    }
  }

  /// Устанавливает флаг защиты от скриншотов для Android
  Future<void> _setSecureFlag() async {
    // FLAG_SECURE = 0x00002000
    // Запрещает скриншоты и запись экрана на Android
    await AndroidSecurityUtils.setSecureFlag(true);
  }

  Future<void> _resetDatabaseForDevelopment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить БД?'),
        content: const Text(
          'Будут удалены PIN, категории, настройки, логи и другие данные SQLite. '
          'Действие доступно только в debug-режиме.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final authController = context.read<AuthController>();
    final databaseHelper = context.read<DatabaseHelper>();

    try {
      await databaseHelper.resetAllDataForDevelopment();
      await authController.refreshState();
      authController.clearPin();

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('База данных сброшена')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Ошибка сброса БД: $e')));
    }
  }

  Future<bool> _isBiometricAvailable(AuthController controller) async {
    final biometricRepo = controller.biometricRepository;
    if (biometricRepo == null) return false;
    final isAvailable = await biometricRepo.isAvailable();
    if (!isAvailable) return false;
    final profileId = controller.authState.currentProfileId ?? 1;
    return biometricRepo.isEnabledForProfile(profileId);
  }

  void _showProfileSwitcher(AuthController controller) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _ProfileSwitcherSheet(
        profiles: controller.profiles,
        selectedId: controller.authState.currentProfileId ?? 1,
        onSelect: (id) {
          Navigator.of(ctx).pop();
          controller.setCurrentProfile(id);
        },
      ),
    );
  }

  Future<void> _authenticateWithBiometric(AuthController controller) async {
    final result = await controller.authenticateWithBiometric();
    if (!mounted) return;
    if (result != AuthResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Не удалось войти'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tabletMin;
    final content = !controller.authState.isPinSetup
        ? _buildSetupScreen(controller, theme)
        : controller.authState.isLocked
            ? _buildLockoutScreen(controller, theme)
            : _buildLoginScreen(controller, theme);

    if (isMobile) return content;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: content,
      ),
    );
  }

  Widget _buildAppLogo(ThemeData theme, {double size = 72}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/icons/app_icon_1024.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.lock_outline,
          size: size,
          color: theme.colorScheme.primary,
        ),
      ),
    );
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
              _buildAppLogo(theme),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                _DevDatabaseResetButton(
                  onPressed: controller.isLoading
                      ? null
                      : _resetDatabaseForDevelopment,
                ),
              ],
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.error != null
                    ? SizedBox(
                        width: 64,
                        height: 64,
                        child: Lottie.asset(
                          'project_context/design/animations/pin_error.json',
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      )
                    : _buildAppLogo(theme),
              ),
              const SizedBox(height: 16),

              Text(
                'Введите PIN-код',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (controller.error != null ||
                  (controller.authState.remainingAttempts != null &&
                      controller.authState.remainingAttempts! < 5))
                Text(
                  'Осталось попыток: ${controller.authState.remainingAttempts ?? 5}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),

              const SizedBox(height: 16),

              // Аватарка и имя текущего профиля (всегда)
              _ProfileBadge(
                profile: controller.profiles.firstWhere(
                  (p) => p.id == (controller.authState.currentProfileId ?? 1),
                  orElse: () => controller.profiles.isNotEmpty
                      ? controller.profiles.first
                      : Profile(name: 'Профиль', createdAt: DateTime(0)),
                ),
                hasMultiple: controller.profiles.length > 1,
                onTap: controller.profiles.length > 1
                    ? () => _showProfileSwitcher(controller)
                    : null,
              ),

              const SizedBox(height: 16),

              // Индикатор PIN
              PinInputWidget(
                pinLength: controller.pinLength,
                maxLength: 8,
                isError: controller.error != null,
              ),

              const SizedBox(height: 16),

              // Кнопка биометрической аутентификации
              FutureBuilder<bool>(
                future: _isBiometricAvailable(controller),
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox.shrink();
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : () => _authenticateWithBiometric(controller),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Войти по отпечатку'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  );
                },
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
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
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
                onDigitTap: (digit) {
                  controller.addDigit(digit);
                },
                onBackspace: () => controller.removeDigit(),
                isLoading: controller.isLoading,
              ),

              const SizedBox(height: 16),

              // Кнопка подтверждения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isPinComplete && !controller.isLoading
                      ? _handleConfirm
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
                      : const Text('Войти'),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                _DevDatabaseResetButton(
                  onPressed: controller.isLoading
                      ? null
                      : _resetDatabaseForDevelopment,
                ),
              ],
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
          Icon(Icons.lock_outline, size: 80, color: theme.colorScheme.error),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            _DevDatabaseResetButton(onPressed: _resetDatabaseForDevelopment),
          ],
        ],
      ),
    );
  }
}

class _DevDatabaseResetButton extends StatelessWidget {
  const _DevDatabaseResetButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.storage),
        label: const Text('Сбросить БД'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

/// Бейдж текущего профиля (аватарка + имя)
class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.profile,
    required this.hasMultiple,
    required this.onTap,
  });

  final Profile profile;
  final bool hasMultiple;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            profile.avatarEmoji ?? '👤',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 8),
          Text(
            profile.name,
            style: theme.textTheme.bodyLarge,
          ),
          if (hasMultiple) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.swap_vert,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet для переключения профиля
class _ProfileSwitcherSheet extends StatelessWidget {
  const _ProfileSwitcherSheet({
    required this.profiles,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Profile> profiles;
  final int selectedId;
  final void Function(int id) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Выберите профиль',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...profiles.map((profile) {
              final isSelected = profile.id == selectedId;
              return ListTile(
                leading: Text(
                  profile.avatarEmoji ?? '👤',
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(profile.name),
                trailing: isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                selected: isSelected,
                onTap: () => onSelect(profile.id!),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Виджет таймера обратного отсчёта для блокировки
class _LockoutTimer extends StatefulWidget {
  const _LockoutTimer({required this.controller, required this.theme});
  final AuthController controller;
  final ThemeData theme;

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
        Text('Разблокировка через', style: widget.theme.textTheme.bodyLarge),
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
