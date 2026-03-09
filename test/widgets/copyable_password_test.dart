// Widget-тесты для копируемого пароля
// Согласно ТЗ (Раздел 12.3)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/presentation/widgets/copyable_password.dart';

void main() {
  group('CopyablePassword Widget Tests', () {
    testWidgets('displays label and password', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyablePassword(
              label: 'Пароль',
              text: 'TestPassword123!',
            ),
          ),
        ),
      );

      expect(find.text('Пароль'), findsOneWidget);
      expect(find.text('TestPassword123!'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('shows empty state when text is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyablePassword(
              label: 'Пароль',
              text: '',
            ),
          ),
        ),
      );

      expect(find.text('Нет данных'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsNothing);
    });

    testWidgets('copies password to clipboard on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyablePassword(
              label: 'Пароль',
              text: 'TestPassword123!',
            ),
          ),
        ),
      );

      // Находим виджет и нажимаем
      await tester.tap(find.byType(CopyablePassword).first);
      await tester.pump();

      // Проверяем буфер обмена (сразу, не ждём 60 сек)
      final clipboardData = await Clipboard.getData('text/plain');
      expect(clipboardData?.text, equals('TestPassword123!'));
    });

    testWidgets('shows copy icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyablePassword(
              label: 'Пароль',
              text: 'TestPassword123!',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('has semantics for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyablePassword(
              label: 'Пароль',
              text: 'TestPassword123!',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CopyablePassword));
      expect(semantics.label, contains('Пароль'));
      expect(semantics.label, contains('TestPassword123!'));
    });
  });
}
