import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/modules/generate_password.dart' show SymbolAlphabet, PasswordGenerator, digits, lowercase, uppercase, allIsUniq, digitsIsReq, uppercaseIsReq, symbols;

void main() {
  group('PasswordGenerator', () {
    
test('isCategoryEnabled returns true for enabled categories', () {
  print('\u001b[1;36m=== Тест: isCategoryEnabled (возвращает true для включенных категорий) ===\u001b[0m');
  int flags = digits | lowercase | uppercase;
  print('Входные значения: flags=$flags');
  
  final generator = PasswordGenerator(
  symbolAlphabet: SymbolAlphabet(),
  range: [12, 16],
  flags: flags,
  );

  print('Проверка категорий:');
  print('  digits включен: ${generator.isCategoryEnabled(digits)}');
  print('  lowercase включен: ${generator.isCategoryEnabled(lowercase)}');
  print('  uppercase включен: ${generator.isCategoryEnabled(uppercase)}');
  print('  symbols включен: ${generator.isCategoryEnabled(symbols)}');

  expect(generator.isCategoryEnabled(digits), true);
  expect(generator.isCategoryEnabled(lowercase), true);
  expect(generator.isCategoryEnabled(uppercase), true);
  expect(generator.isCategoryEnabled(symbols), false);
});

test('isCategoryRequired returns true for required categories', () {
  print('\u001b[1;33m=== Тест: isCategoryRequired (возвращает true для обязательных категорий) ===\u001b[0m');
  int flags = digits | digitsIsReq | lowercase | uppercase | uppercaseIsReq;
  print('Входные значения: flags=$flags');
  
  final generator = PasswordGenerator(
  symbolAlphabet: SymbolAlphabet(),
  range: [12, 16],
  flags: flags,
  );

  print('Проверка обязательности:');
  print('  digits обязателен: ${generator.isCategoryRequired(digits)}');
  print('  lowercase обязателен: ${generator.isCategoryRequired(lowercase)}');
  print('  uppercase обязателен: ${generator.isCategoryRequired(uppercase)}');

  expect(generator.isCategoryRequired(digits), true);
  expect(generator.isCategoryRequired(lowercase), false);
  expect(generator.isCategoryRequired(uppercase), true);
});

test('shouldBeUnique returns true when allIsUniq flag is set', () {
  print('\u001b[1;35m=== Тест: shouldBeUnique (возвращает true когда установлен флаг allIsUniq) ===\u001b[0m');
  int flagsWithUniq = digits | lowercase | allIsUniq;
  int flagsWithoutUniq = digits | lowercase;
  print('Входные значения: flagsWithUniq=$flagsWithUniq, flagsWithoutUniq=$flagsWithoutUniq');
  
  final generatorWithUniq = PasswordGenerator(
  symbolAlphabet: SymbolAlphabet(),
  range: [12, 16],
  flags: flagsWithUniq,
  );
  final generatorWithoutUniq = PasswordGenerator(
  symbolAlphabet: SymbolAlphabet(),
  range: [12, 16],
  flags: flagsWithoutUniq,
  );

  print('Результаты: с уникальностью=${generatorWithUniq.shouldBeUnique()}, без=${generatorWithoutUniq.shouldBeUnique()}');

  expect(generatorWithUniq.shouldBeUnique(), true);
  expect(generatorWithoutUniq.shouldBeUnique(), false);
});

test('generateConfig and restoreConfig preserve state', () {
  print('\u001b[1;32m=== Тест: generateConfig и restoreConfig (сохраняют состояние) ===\u001b[0m');
  int flags = digits | lowercase | uppercase;
  
  final generator1 = PasswordGenerator(
  symbolAlphabet: SymbolAlphabet(),
  range: [12, 16],
  flags: flags,
  );
  
  final result1 = generator1.generatePassword();
  final config = generator1.generateConfig();
  print('Сгенерированный конфиг: $config');
  
  final generator2 = PasswordGenerator(
  symbolAlphabet: SymbolAlphabet(),
  range: [12, 16],
  flags: flags,
  );
  generator2.restoreConfig(config);
  final result2 = generator2.generatePassword();
  
  print('Пароль 1: ${result1['password']}');
  print('Пароль 2: ${result2['password']}');
  print('Пароли совпадают: ${result1['password'] == result2['password']}');

  expect(result1['password'], equals(result2['password']));
  expect(result1['strength'], equals(result2['strength']));
});
  });
}
