import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/core/utils/lockout_calculator.dart';

void main() {
  group('LockoutCalculator.clampAttempts', () {
    test('возвращает min для слишком малого значения', () {
      expect(LockoutCalculator.clampAttempts(0),
          LockoutCalculator.minAttemptsPerSeries);
      expect(LockoutCalculator.clampAttempts(1),
          LockoutCalculator.minAttemptsPerSeries);
      expect(LockoutCalculator.clampAttempts(2),
          LockoutCalculator.minAttemptsPerSeries);
    });

    test('возвращает max для слишком большого значения', () {
      expect(LockoutCalculator.clampAttempts(11),
          LockoutCalculator.maxAttemptsPerSeries);
      expect(LockoutCalculator.clampAttempts(100),
          LockoutCalculator.maxAttemptsPerSeries);
    });

    test('возвращает значение из допустимого диапазона как есть', () {
      for (var v = LockoutCalculator.minAttemptsPerSeries;
          v <= LockoutCalculator.maxAttemptsPerSeries;
          v++) {
        expect(LockoutCalculator.clampAttempts(v), v);
      }
    });

    test('defaultAttemptsPerSeries попадает в допустимый диапазон', () {
      expect(
        LockoutCalculator.defaultAttemptsPerSeries,
        greaterThanOrEqualTo(LockoutCalculator.minAttemptsPerSeries),
      );
      expect(
        LockoutCalculator.defaultAttemptsPerSeries,
        lessThanOrEqualTo(LockoutCalculator.maxAttemptsPerSeries),
      );
    });
  });
}
