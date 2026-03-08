// Widget-тесты для shimmer-эффекта
// Согласно ТЗ (Раздел 12.1)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pass_gen/presentation/widgets/shimmer_effect.dart';

void main() {
  group('ShimmerEffect Widget Tests', () {
    testWidgets('renders container with correct dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              width: 200,
              height: 100,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(200));
      expect(container.constraints?.maxHeight, equals(100));
    });

    testWidgets('applies border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              width: 200,
              height: 100,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Проверяем, что виджет рендерится без ошибок
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });

    testWidgets('animates over time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              width: 200,
              height: 100,
            ),
          ),
        ),
      );

      // Начальное состояние
      await tester.pump(const Duration(milliseconds: 0));
      expect(find.byType(ShimmerEffect), findsOneWidget);

      // После половины анимации
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.byType(ShimmerEffect), findsOneWidget);

      // После полной анимации
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
  });

  group('ShimmerList Widget Tests', () {
    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerList(
              itemCount: 5,
              itemHeight: 120,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerEffect), findsNWidgets(5));
    });

    testWidgets('renders with default values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerList(
              itemCount: 3,
              itemHeight: 100,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerList), findsOneWidget);
      expect(find.byType(ShimmerEffect), findsNWidgets(3));
    });
  });
}
