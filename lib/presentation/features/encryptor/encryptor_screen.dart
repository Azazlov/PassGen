import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../presentation/widgets/app_button.dart';
import '../../../presentation/widgets/app_text_field.dart';
import '../../../presentation/widgets/copyable_password.dart';
import '../../../presentation/widgets/app_dialogs.dart';
import 'encryptor_controller.dart';
import '../../../domain/usecases/encryptor/encrypt_message_usecase.dart';
import '../../../domain/usecases/encryptor/decrypt_message_usecase.dart';

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
  State<_EncryptorScreenContent> createState() => _EncryptorScreenContentState();
}

class _EncryptorScreenContentState extends State<_EncryptorScreenContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<EncryptorController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Шифратор'),
        actions: [
          IconButton(
            icon: Icon(controller.isEncryptMode ? Icons.lock_open : Icons.lock),
            tooltip: controller.isEncryptMode ? 'Режим дешифрования' : 'Режим шифрования',
            onPressed: controller.toggleMode,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Режим работы
            Card(
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
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Результат
            CopyablePassword(
              label: controller.resultLabel,
              text: controller.result.substring(0, min(40, controller.result.length)),
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

            // Поле сообщения/шифра
            AppTextField(
              label: controller.isEncryptMode ? 'Сообщение' : 'Зашифрованные данные',
              hint: controller.isEncryptMode ? 'Введите текст для шифрования' : 'Вставьте зашифрованные данные',
              controller: controller.messageController,
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 16),

            // Поле пароля
            AppTextField(
              label: 'Пароль',
              hint: 'Введите надёжный пароль',
              controller: controller.passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),

            const SizedBox(height: 32),

            // Кнопка выполнения
            AppButton(
              label: controller.isEncryptMode ? 'Зашифровать' : 'Дешифровать',
              onPressed: controller.execute,
              isLoading: controller.isLoading,
              icon: controller.isEncryptMode ? Icons.lock : Icons.lock_open,
            ),

            const SizedBox(height: 16),

            // Отображение ошибки
            if (controller.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.error!,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
