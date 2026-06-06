import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../domain/usecases/encryptor/decrypt_message_usecase.dart';
import '../../../domain/usecases/encryptor/encrypt_message_usecase.dart';
import '../../../presentation/widgets/app_button.dart';
import '../../../presentation/widgets/app_dialogs.dart';
import '../../../presentation/widgets/app_text_field.dart';
import '../../../presentation/widgets/copyable_password.dart';
import 'encryptor_controller.dart';

/// Экран шифратора/дешифратора
class EncryptorScreen extends StatelessWidget {
  const EncryptorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EncryptorController(
        encryptUseCase: context.read<EncryptMessageUseCase>(),
        decryptUseCase: context.read<DecryptMessageUseCase>(),
      ),
      child: const _EncryptorScreenContent(),
    );
  }
}

class _EncryptorScreenContent extends StatefulWidget {
  const _EncryptorScreenContent();

  @override
  State<_EncryptorScreenContent> createState() =>
      _EncryptorScreenContentState();
}

class _EncryptorScreenContentState extends State<_EncryptorScreenContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<EncryptorController>();
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tabletMin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Шифратор'),
        actions: [
          IconButton(
            icon: Icon(controller.isEncryptMode ? Icons.lock_open : Icons.lock),
            tooltip: controller.isEncryptMode
                ? 'Режим дешифрования'
                : 'Режим шифрования',
            onPressed: controller.toggleMode,
          ),
        ],
      ),
      body: SafeArea(
        child: isMobile
            ? _buildMobileContent(theme, controller)
            : _buildDesktopContent(theme, controller),
      ),
    );
  }

  Widget _buildMobileContent(ThemeData theme, EncryptorController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildModeCard(theme, controller),
        const SizedBox(height: 24),
        CopyablePassword(
          label: controller.resultLabel,
          text: controller.result.substring(
            0,
            min(40, controller.result.length),
          ),
          isEmpty: controller.result.isEmpty,
          onTap: () {
            Clipboard.setData(ClipboardData(text: controller.result));
            showAppDialog(
              context: context,
              title: 'Скопировано',
              content: 'Скопировано в буфер обмена',
            );
          },
        ),
        const SizedBox(height: 24),
        _buildInputForm(theme, controller),
        const SizedBox(height: 16),
        if (controller.error != null) _buildErrorBox(controller, theme),
      ],
    );
  }

  Widget _buildDesktopContent(ThemeData theme, EncryptorController controller) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          children: [
            SizedBox(
              width: 360,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildModeCard(theme, controller),
                    const SizedBox(height: 24),
                    _buildInputForm(theme, controller),
                    const SizedBox(height: 16),
                    if (controller.error != null) _buildErrorBox(controller, theme),
                  ],
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: CopyablePassword(
                      label: controller.resultLabel,
                      text: controller.result.substring(
                        0,
                        min(40, controller.result.length),
                      ),
                      isEmpty: controller.result.isEmpty,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: controller.result));
                        showAppDialog(
                          context: context,
                          title: 'Скопировано',
                          content: 'Скопировано в буфер обмена',
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(ThemeData theme, EncryptorController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              controller.isEncryptMode ? Icons.lock : Icons.lock_open,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isEncryptMode ? 'Шифрование' : 'Дешифрование',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    controller.isEncryptMode
                        ? 'Зашифруйте сообщение паролем'
                        : 'Расшифруйте сообщение паролем',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(ThemeData theme, EncryptorController controller) {
    return Column(
      children: [
        AppTextField(
          label: controller.isEncryptMode
              ? 'Сообщение'
              : 'Зашифрованные данные',
          hint: controller.isEncryptMode
              ? 'Введите текст для шифрования'
              : 'Вставьте зашифрованные данные',
          controller: controller.messageController,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Пароль',
          hint: 'Введите надёжный пароль',
          controller: controller.passwordController,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: controller.isEncryptMode ? 'Зашифровать' : 'Дешифровать',
          onPressed: controller.execute,
          isLoading: controller.isLoading,
          icon: controller.isEncryptMode ? Icons.lock : Icons.lock_open,
        ),
      ],
    );
  }

  Widget _buildErrorBox(EncryptorController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        controller.error!,
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}
