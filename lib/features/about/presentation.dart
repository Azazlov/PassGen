import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // App metadata
  static const String _appName = 'PassGen';
  static const String _version = 'v1.2.0';
  static const String _developer = '@Azazlov';
  static const String _githubUrl = 'https://github.com/azazlov/secure-pass';
  static const String _privacyUrl = 'https://example.com/privacy';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App icon placeholder (replace with actual icon asset)
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

              // App name & version
              Text(
                _appName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _version,
                style: textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 24),

              // Description with security focus
              Text(
                'Генератор надёжных паролей с контролем сложности и удобной визуализацией структуры.',
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Key features section
              _buildSectionTitle(context, 'Особенности'),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                Icons.password,
                'Гибкая настройка длины (12–20 символов)',
              ),
              _buildFeatureItem(
                context,
                Icons.segment,
                'Группировка символов для удобного копирования',
              ),
              _buildFeatureItem(
                context,
                Icons.brightness_auto,
                'Автоматическое переключение темы',
              ),
              _buildFeatureItem(
                context,
                Icons.shield,
                'Генерация без передачи данных в сеть',
              ),
              const SizedBox(height: 28),

              // Developer credit
              _buildSectionTitle(context, 'Разработчик'),
              const SizedBox(height: 12),
              Text(
                _developer,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Links section
              _buildSectionTitle(context, 'Ресурсы'),
              const SizedBox(height: 16),
              _buildLinkItem(
                context,
                Icons.code,
                'Исходный код',
                _githubUrl,
              ),
              _buildLinkItem(
                context,
                Icons.policy,
                'Политика конфиденциальности',
                _privacyUrl,
              ),
              const SizedBox(height: 32),

              // Footer with tech stack
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
                      style: textTheme.titleSmall?.copyWith(
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
                        _buildTechBadge(context, 'Flutter 3.24'),
                        _buildTechBadge(context, 'Dart 3.5'),
                        _buildTechBadge(context, 'null safety'),
                        _buildTechBadge(context, 'Material 3'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, IconData icon, String title, String url) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceVariant,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary,
            ),
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
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}