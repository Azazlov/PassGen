import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/modules/generate_password.dart';

void main() {
  group('PasswordGenerator', () {
    late SymbolAlphabet symbolAlphabet;

    setUp(() {
      symbolAlphabet = SymbolAlphabet();
    });

    test('generatePassword returns map with password and strength keys', () {
      print('\u001b[1;36m=== Тест: generatePassword (возвращает карту с ключами password и strength) ===\u001b[0m');
      int flags = digits | lowercase | uppercase | symbols;
      print('Входные значения: lengthRange=[12, 16], flags=$flags');
      
      final generator = PasswordGenerator(
        symbolAlphabet: symbolAlphabet,
        range: [12, 16],
        flags: flags,
      );
      final result = generator.generatePassword();

      print('Выходные значения:');
      print('  password: ${result['password']}');
      print('  strength: ${result['strength']}');
      print('  length: ${result['password']!.length}');

      expect(result.containsKey('password'), true);
      expect(result.containsKey('strength'), true);
      expect(result['password']!.length, greaterThan(11));
      expect(result['password']!.length, lessThan(17));
    });

    test('generatePassword creates password within length range', () {
      print('\u001b[1;32m=== Тест: generatePassword (создает пароль в диапазоне длин) ===\u001b[0m');
      print('Входные значения: lengthRange=[10, 20], isUniq=false');
      
      final generator = PasswordGenerator(alphabet, [10, 20], false);
      final result = generator.generatePassword();
      final password = result['password']!;

      print('Выходные значения:');
      print('  password: $password');
      print('  length: ${password.length}');
      print('  в диапазоне [10, 20]: ${password.length >= 10 && password.length <= 20}');

      expect(password.length, greaterThanOrEqualTo(10));
      expect(password.length, lessThanOrEqualTo(20));
    });

    test('generatePassword returns valid strength value', () {
      print('\u001b[1;33m=== Тест: generatePassword (возвращает корректное значение надежности) ===\u001b[0m');
      print('Входные значения: lengthRange=[12, 16], isUniq=false');
      
      final generator = PasswordGenerator(alphabet, [12, 16], false);
      final result = generator.generatePassword();
      final strength = double.parse(result['strength']!);

      print('Выходные значения:');
      print('  password: ${result['password']}');
      print('  strength: $strength');
      print('  в диапазоне [0, 1]: ${strength >= 0 && strength <= 1}');

      expect(strength, greaterThanOrEqualTo(0));
      expect(strength, lessThanOrEqualTo(1));
    });

    test('shuffleList returns same length list', () {
      print('\u001b[1;35m=== Тест: shuffleList (возвращает список той же длины) ===\u001b[0m');
      final original = ['a', 'b', 'c', 'd', 'e'];
      print('Входные значения: $original');
      
      final generator = PasswordGenerator(alphabet, [12, 16], false);
      final shuffled = generator.shuffleList(original);

      print('Выходные значения: $shuffled');
      print('  исходная длина: ${original.length}');
      print('  новая длина: ${shuffled.length}');
      print('  длины совпадают: ${shuffled.length == original.length}');

      expect(shuffled.length, equals(original.length));
    });

    test('shuffleList contains all original elements', () {
      print('\u001b[1;36m=== Тест: shuffleList (содержит все исходные элементы) ===\u001b[0m');
      final original = ['a', 'b', 'c', 'd', 'e'];
      print('Входные значения: $original');
      
      final generator = PasswordGenerator(alphabet, [12, 16], false);
      final shuffled = generator.shuffleList(original);

      print('Выходные значения: $shuffled');
      print('  все элементы совпадают: ${shuffled.toSet().toString()} == ${original.toSet().toString()}');

      expect(shuffled.toSet(), equals(original.toSet()));
    });

    test('generatePassword with isUniq true handles unique characters', () {
      print('\u001b[1;32m=== Тест: generatePassword (с isUniq=true обрабатывает уникальные символы) ===\u001b[0m');
      print('Входные значения: lengthRange=[5, 10], isUniq=true');
      
      final generator = PasswordGenerator(alphabet, [5, 10], true);
      final result = generator.generatePassword();
      final password = result['password']!;

      print('Выходные значения:');
      print('  password: $password');
      print('  length: ${password.length}');
      print('  не пусто: ${password.isNotEmpty}');
      print('  количество уникальных символов: ${password.split('').toSet().length}');

      expect(password.isNotEmpty, true);
      expect(password.length, greaterThan(0));
    });
  });
}
