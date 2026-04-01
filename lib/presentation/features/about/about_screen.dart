import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';

/// Экран "О приложении"
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('О приложении'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Иконка приложения
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Название и версия
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'v${AppConstants.appVersion}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Последнее обновление: 1 апреля 2026',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Описание
              Text(
                'Кроссплатформенный менеджер паролей с локальным шифрованием для генерации, хранения и управления паролями.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Новое в версии 0.5.2
              _buildVersionCard(context),
              const SizedBox(height: 28),

              // Особенности
              _buildSectionTitle(context, 'Возможности'),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                Icons.password,
                'Генератор паролей (8–64 символа, 5 уровней сложности)',
              ),
              _buildFeatureItem(
                context,
                Icons.folder,
                'Хранилище с категориями и поиском',
              ),
              _buildFeatureItem(
                context,
                Icons.history,
                'История изменений паролей',
              ),
              _buildFeatureItem(
                context,
                Icons.security,
                'Шифрование ChaCha20-Poly1305 (AEAD)',
              ),
              _buildFeatureItem(
                context,
                Icons.key,
                'PBKDF2 деривация ключа (100K итераций)',
              ),
              _buildFeatureItem(
                context,
                Icons.notifications,
                'Уведомления о слабых и старых паролях',
              ),
              _buildFeatureItem(
                context,
                Icons.brightness_auto,
                'Автоматическое переключение темы (Material 3)',
              ),
              _buildFeatureItem(
                context,
                Icons.cloud_off,
                'Локальное хранение без передачи в сеть',
              ),
              const SizedBox(height: 28),

              // Разработчик
              _buildSectionTitle(context, 'Разработчик'),
              const SizedBox(height: 12),
              Text(
                AppConstants.developer,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Ресурсы
              _buildSectionTitle(context, 'Ресурсы'),
              const SizedBox(height: 16),
              _buildLinkItem(
                context,
                Icons.code,
                'Исходный код',
                'https://github.com/azazlov/passgen',
              ),
              _buildLinkItem(
                context,
                Icons.description,
                'Документация',
                'https://github.com/azazlov/passgen/blob/main/DEVELOPER.MD',
              ),
              const SizedBox(height: 32),

              // Технологии
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.blueGrey[900] : Colors.blueGrey[50],
                ),
                child: Column(
                  children: [
                    Text(
                      'Технологии',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildTechBadge(context, 'Flutter'),
                        _buildTechBadge(context, 'Dart'),
                        _buildTechBadge(context, 'Material 3'),
                        _buildTechBadge(context, 'SQLite'),
                        _buildTechBadge(context, 'Provider'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Статистика
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.blueGrey[900] : Colors.blueGrey[50],
                ),
                child: Column(
                  children: [
                    Text(
                      'Статистика проекта',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(context, 'Файлов Dart', '130+'),
                    _buildStatRow(context, 'Строк кода', '~11 000+'),
                    _buildStatRow(context, 'Таблиц БД', '6'),
                    _buildStatRow(context, 'Use Cases', '29+'),
                    _buildStatRow(context, 'Безопасность', '98/100'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.new_releases,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Новое в версии 0.5.2',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVersionFeature(context, Icons.history, 'История паролей'),
          _buildVersionFeature(
            context,
            Icons.notifications,
            'Система уведомлений',
          ),
          _buildVersionFeature(
            context,
            Icons.refresh,
            'Автообновление списка',
          ),
          _buildVersionFeature(
            context,
            Icons.no_accounts,
            'Импорт без дубликатов',
          ),
          _buildVersionFeature(
            context,
            Icons.folder_zip,
            'Исправлен формат .passgen',
          ),
          _buildVersionFeature(
            context,
            Icons.folder_shared,
            'macOS entitlements',
          ),
        ],
      ),
    );
  }

  Widget _buildVersionFeature(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    IconData icon,
    String title,
    String url,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _launchUrl(url),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.primaryContainer,
            ),
            child: Text(
              value,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Не удалось открыть $url');
    }
  }
}
