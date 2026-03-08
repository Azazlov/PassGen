// Widget-тесты для CharacterSetDisplay
// Согласно ТЗ (Раздел 12.1)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/presentation/widgets/character_set_display.dart';
import '../../lib/domain/entities/password_generation_settings.dart';

void main() {
  group('CharacterSetDisplay Widget Tests', () {
    testWidgets('shows all character categories when all enabled', (tester) async {
      final settings = const PasswordGenerationSettings(
        useCustomLowercase: true,
        useCustomUppercase: true,
        useCustomDigits: true,
        useCustomSymbols: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSetDisplay(settings: settings),
          ),
        ),
      );

      expect(find.text('Строчные'), findsOneWidget);
      expect(find.text('Заглавные'), findsOneWidget);
      expect(find.text('Цифры'), findsOneWidget);
      expect(find.text('Спецсимволы'), findsOneWidget);
      expect(find.text('Итого: 82 символов'), findsOneWidget);
    });

    testWidgets('hides disabled categories', (tester) async {
      final settings = const PasswordGenerationSettings(
        useCustomLowercase: true,
        useCustomUppercase: false,
        useCustomDigits: true,
        useCustomSymbols: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSetDisplay(settings: settings),
          ),
        ),
      );

      expect(find.text('Строчные'), findsOneWidget);
      expect(find.text('Цифры'), findsOneWidget);
      expect(find.text('Заглавные'), findsNothing);
      expect(find.text('Спецсимволы'), findsNothing);
      expect(find.text('Итого: 36 символов'), findsOneWidget);
    });

    testWidgets('shows excluded characters when enabled', (tester) async {
      final settings = const PasswordGenerationSettings(
        useCustomLowercase: true,
        useCustomUppercase: true,
        useCustomDigits: true,
        useCustomSymbols: true,
        excludeSimilar: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSetDisplay(settings: settings),
          ),
        ),
      );

      expect(find.text('Исключены'), findsOneWidget);
      expect(find.text('Похожие символы'), findsOneWidget);
      expect(find.text('1lI0Oo'), findsOneWidget);
    });

    testWidgets('hides excluded section when disabled', (tester) async {
      final settings = const PasswordGenerationSettings(
        useCustomLowercase: true,
        useCustomUppercase: true,
        useCustomDigits: true,
        useCustomSymbols: true,
        excludeSimilar: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSetDisplay(settings: settings),
          ),
        ),
      );

      expect(find.text('Исключены'), findsNothing);
    });

    testWidgets('shows correct count after excluding similar', (tester) async {
      final settings = const PasswordGenerationSettings(
        useCustomLowercase: true,
        useCustomUppercase: true,
        useCustomDigits: true,
        useCustomSymbols: true,
        excludeSimilar: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSetDisplay(settings: settings),
          ),
        ),
      );

      // 23 + 23 + 8 + 20 = 74 (после исключения 1lI0Oo)
      expect(find.text('Итого: 74 символов'), findsOneWidget);
    });

    testWidgets('hides widget when no categories enabled', (tester) async {
      final settings = const PasswordGenerationSettings(
        useCustomLowercase: false,
        useCustomUppercase: false,
        useCustomDigits: false,
        useCustomSymbols: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSetDisplay(settings: settings),
          ),
        ),
      );

      expect(find.byType(CharacterSetDisplay), findsOneWidget);
      expect(find.text('Используемые символы'), findsNothing);
    });

    testWidgets('displays monospace font for characters', (tester) async {
      final settings = const PasswordGenerationSettings(
        useCustomDigits: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CharacterSetDisplay(settings: settings),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('0123456789'),
      );
      expect(textWidget.style?.fontFamily, equals('monospace'));
    });
  });
}
