import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/modules/generate_password.dart';

void main() {
  group('PasswordGenerator', () {
    late Map<String, List<dynamic>> alphabet;

    setUp(() {
      String includeDigits = '0123456789';
      String includeLowercase = 'abcdefghijklmnopqrstuvwxyz';
      String includeUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      String includeSymbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

      alphabet = {
        'digits': [includeDigits.split(''), true],
        'lowercase': [includeLowercase.split(''), true],
        'uppercase': [includeUppercase.split(''), true],
        'symbols': [includeSymbols.split(''), false]
      };
    });

    test('generatePassword returns map with password and strength keys', () {
      final generator = PasswordGenerator(alphabet, [12, 16], false);
      final result = generator.generatePassword();

      expect(result.containsKey('password'), true);
      expect(result.containsKey('strength'), true);
    });

    test('generatePassword creates password within length range', () {
      final generator = PasswordGenerator(alphabet, [10, 20], false);
      final result = generator.generatePassword();
      final password = result['password']!;

      expect(password.length, greaterThanOrEqualTo(10));
      expect(password.length, lessThanOrEqualTo(20));
    });

    test('generatePassword returns valid strength value', () {
      final generator = PasswordGenerator(alphabet, [12, 16], false);
      final result = generator.generatePassword();
      final strength = double.parse(result['strength']!);

      expect(strength, greaterThanOrEqualTo(0));
      expect(strength, lessThanOrEqualTo(100));
    });

    test('shuffleList returns same length list', () {
      final generator = PasswordGenerator(alphabet, [12, 16], false);
      final original = ['a', 'b', 'c', 'd', 'e'];
      final shuffled = generator.shuffleList(original);

      expect(shuffled.length, equals(original.length));
    });

    test('shuffleList contains all original elements', () {
      final generator = PasswordGenerator(alphabet, [12, 16], false);
      final original = ['a', 'b', 'c', 'd', 'e'];
      final shuffled = generator.shuffleList(original);

      expect(shuffled.toSet(), equals(original.toSet()));
    });

    test('generatePassword with isUniq true handles unique characters', () {
      final generator = PasswordGenerator(alphabet, [5, 10], true);
      final result = generator.generatePassword();
      final password = result['password']!;

      expect(password.isNotEmpty, true);
      expect(password.length, greaterThan(0));
    });
  });
}