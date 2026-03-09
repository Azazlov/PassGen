import 'package:flutter/material.dart';
import '../../domain/entities/character_set.dart';
import '../../domain/entities/password_generation_settings.dart';

/// Виджет для отображения используемых символов генерации
class CharacterSetDisplay extends StatelessWidget {
  const CharacterSetDisplay({
    super.key,
    required this.settings,
    this.characterSets,
  });

  final PasswordGenerationSettings settings;
  final List<CharacterSet>? characterSets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = characterSets ?? _getCharacterCategoriesFromSettings();
    final total = categories
        .where((c) => c.isEnabled)
        .fold<int>(0, (sum, c) => sum + c.count);

    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Используемые символы',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.map(
              (category) => _CharacterCategoryWidget(category: category),
            ),
            const SizedBox(height: 12),
            // Итого
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Итого:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$total символов',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
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

  List<CharacterSet> _getCharacterCategoriesFromSettings() {
    final categories = <CharacterSet>[];

    // Строчные
    if (settings.useCustomLowercase || settings.requireLowercase) {
      var chars = _lowercase;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      if (chars.isNotEmpty) {
        categories.add(
          CharacterSet(
            label: 'Строчные',
            subtitle: 'a-z',
            characters: chars,
            count: chars.length,
            isEnabled: true,
          ),
        );
      }
    }

    // Заглавные
    if (settings.useCustomUppercase || settings.requireUppercase) {
      var chars = _uppercase;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      if (chars.isNotEmpty) {
        categories.add(
          CharacterSet(
            label: 'Заглавные',
            subtitle: 'A-Z',
            characters: chars,
            count: chars.length,
            isEnabled: true,
          ),
        );
      }
    }

    // Цифры
    if (settings.useCustomDigits || settings.requireDigits) {
      var chars = _digits;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      if (chars.isNotEmpty) {
        categories.add(
          CharacterSet(
            label: 'Цифры',
            subtitle: '0-9',
            characters: chars,
            count: chars.length,
            isEnabled: true,
          ),
        );
      }
    }

    // Спецсимволы
    if (settings.useCustomSymbols || settings.requireSymbols) {
      var chars = _symbols;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      if (chars.isNotEmpty) {
        categories.add(
          CharacterSet(
            label: 'Спецсимволы',
            subtitle: '!@#...',
            characters: chars,
            count: chars.length,
            isEnabled: true,
          ),
        );
      }
    }

    return categories;
  }

  String _excludeSimilar(String chars) {
    final similar = {'l', '1', 'I', 'O', '0'};
    return chars.split('').where((c) => !similar.contains(c)).join();
  }

  // Константы символов (локальные, без зависимости от Data)
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
}

class _CharacterCategoryWidget extends StatelessWidget {
  const _CharacterCategoryWidget({required this.category});
  final CharacterSet category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.count}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Символы
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              category.characters,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
