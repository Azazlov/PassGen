import 'package:flutter/material.dart';
import '../../data/datasources/password_generator_local_datasource.dart';
import '../../domain/entities/password_generation_settings.dart';

/// Виджет для отображения используемых символов генерации
class CharacterSetDisplay extends StatelessWidget {
  final PasswordGenerationSettings settings;

  const CharacterSetDisplay({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = _getCharacterCategories();
    final total = categories.where((c) => c.isEnabled).fold<int>(
      0,
      (sum, c) => sum + c.count,
    );

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
            ...categories.map((category) => _CharacterCategoryWidget(category: category)),
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

  List<_CharacterCategory> _getCharacterCategories() {
    final categories = <_CharacterCategory>[];

    // Строчные
    if (settings.useCustomLowercase || settings.requireLowercase) {
      var chars = PasswordGeneratorLocalDataSource.lowercase;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      categories.add(_CharacterCategory(
        label: 'Строчные',
        subtitle: 'a-z',
        characters: chars,
        count: chars.length,
        isEnabled: true,
      ));
    }

    // Заглавные
    if (settings.useCustomUppercase || settings.requireUppercase) {
      var chars = PasswordGeneratorLocalDataSource.uppercase;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      categories.add(_CharacterCategory(
        label: 'Заглавные',
        subtitle: 'A-Z',
        characters: chars,
        count: chars.length,
        isEnabled: true,
      ));
    }

    // Цифры
    if (settings.useCustomDigits || settings.requireDigits) {
      var chars = PasswordGeneratorLocalDataSource.digits;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      categories.add(_CharacterCategory(
        label: 'Цифры',
        subtitle: '0-9',
        characters: chars,
        count: chars.length,
        isEnabled: true,
      ));
    }

    // Спецсимволы
    if (settings.useCustomSymbols || settings.requireSymbols) {
      var chars = PasswordGeneratorLocalDataSource.symbols;
      if (settings.excludeSimilar) {
        chars = _excludeSimilar(chars);
      }
      categories.add(_CharacterCategory(
        label: 'Спецсимволы',
        subtitle: '!@#...',
        characters: chars,
        count: chars.length,
        isEnabled: true,
      ));
    }

    // Исключённые
    if (settings.excludeSimilar) {
      categories.add(_CharacterCategory(
        label: 'Исключены',
        subtitle: 'Похожие символы',
        characters: PasswordGeneratorLocalDataSource.similarCharacters,
        count: PasswordGeneratorLocalDataSource.similarCharacters.length,
        isEnabled: false,
        isExcluded: true,
      ));
    }

    return categories;
  }

  String _excludeSimilar(String chars) {
    for (final char in PasswordGeneratorLocalDataSource.similarCharacters.split('')) {
      chars = chars.replaceAll(char, '');
    }
    return chars;
  }
}

class _CharacterCategory {
  final String label;
  final String subtitle;
  final String characters;
  final int count;
  final bool isEnabled;
  final bool isExcluded;

  const _CharacterCategory({
    required this.label,
    required this.subtitle,
    required this.characters,
    required this.count,
    this.isEnabled = true,
    this.isExcluded = false,
  });
}

class _CharacterCategoryWidget extends StatelessWidget {
  final _CharacterCategory category;

  const _CharacterCategoryWidget({required this.category});

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
                  color: category.isExcluded
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: category.isExcluded
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.count}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: category.isExcluded
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
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
              color: category.isExcluded
                  ? theme.colorScheme.errorContainer.withOpacity(0.1)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: category.isExcluded
                    ? theme.colorScheme.error.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              category.characters,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: category.isExcluded
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
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
