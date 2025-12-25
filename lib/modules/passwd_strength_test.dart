import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/modules/passwd_strength.dart';

void main() {
  group('getPasswdStrength', () {
    test('returns value between 0 and 1', () {
      final result = getPasswdStrength('TestPassword123!');
      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThanOrEqualTo(1));
    });

    test('weak password returns low strength', () {
      final result = getPasswdStrength('abc');
      expect(result, lessThan(0.5));
    });

    test('strong password returns high strength', () {
      final result = getPasswdStrength('SuperSecure@Password123!');
      expect(result, greaterThan(0.5));
    });

    test('empty password returns low strength', () {
      final result = getPasswdStrength('');
      expect(result, lessThan(0.3));
    });

    test('longer password with mixed characters returns higher strength', () {
      final weak = getPasswdStrength('password');
      final strong = getPasswdStrength('P@ssw0rd!Secure#123');
      expect(strong, greaterThan(weak));
    });
  });
}