import 'dart:convert';
import 'package:pass_gen/modules/encrypted.dart';
import 'package:pass_gen/modules/password_strength.dart';
import 'package:pass_gen/modules/shared.dart';
export 'package:pass_gen/modules/encrypted.dart' show randomInt, random;
export 'package:pass_gen/modules/password_strength.dart' show getPasswdStrength;

// Побитовые флаги для категорий символов
const int digits = 1 << 0;
const int digitsIsReq = 1 << 1;
const int lowercase = 1 << 2;
const int lowercaseIsReq = 1 << 3;
const int uppercase = 1 << 4;
const int uppercaseIsReq = 1 << 5;
const int symbols = 1 << 6;
const int symbolsIsReq = 1 << 7;
const int allIsUniq = 1 << 8;

// Класс для хранения алфавитов
class SymbolAlphabet {
  final String digits;
  final String lowercase;
  final String uppercase;
  late String symbolsChars;
  final String appendChars;
  final bool appended;

  SymbolAlphabet({
    this.digits = '0123456789',
    this.lowercase = 'abcdefghijklmnopqrstuvwxyz',
    this.uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    this.symbolsChars = '!@#%^&*_+-=[]{};:,.?',
    this.appendChars = '\'"()/\\|`~<>\$€£¥¢•…·÷×±§©®™¶†‡°¤¿¡«»""\'\'—–\'',
    this.appended = false
  }){
    if (appended) {
      symbolsChars += appendChars;
    }
  }

  String getAlphabet(int flag) {
    switch (flag) {
      case 1: return digits; // digits
      case 4: return lowercase; // lowercase
      case 16: return uppercase; // uppercase
      case 64: return symbolsChars; // symbols
      default: return '';
    }
  }
}

class PasswordGenerator {
  final SymbolAlphabet alphabet;
  final List<int> lengthRange;
  int _flags;

  // Внутренние переменные для хранения данных ПОСЛЕДНЕГО сгенерированного пароля
  List<int> _lastRands = [];
  int _lastLength = 0;

  PasswordGenerator({
    required this.alphabet,
    required this.lengthRange,
    required int flags,
  }) : _flags = flags;

  // --- ГЕНЕРАЦИЯ ---

  /// Создает новый случайный пароль
  Map<String, String> generatePassword() {
    final length = randomInt(min: lengthRange[0], max: lengthRange[1] + 1);
    final rands = random(len: length * 2);
    
    return _coreEngine(length, _flags, rands);
  }

  /// Восстанавливает пароль из строки конфига без создания нового объекта
  Map<String, String> restoreFromConfig(String config) {
    try {
      List<String> parts = config.split('.');
      if (parts.length < 3) throw Exception("Invalid config");

      final length = int.parse(decodeBase64(parts[0]));
      final flags = int.parse(decodeBase64(parts[1]));
      final rands = List<int>.from(base64Decode(parts[2]));

      // Генерируем пароль на основе восстановленных данных
      return _coreEngine(length, flags, rands);
    } catch (e) {
      return {'password': '', 'strength': '0', 'config': '', 'error': 'Restore failed'};
    }
  }

  /// Ядро генерации (Pure logic)
  Map<String, String> _coreEngine(int length, int flags, List<int> rands) {
    if (rands.isEmpty) return {'password': '', 'strength': '0', 'config': ''};

    // Сохраняем состояние для метода generateConfig
    _lastLength = length;
    _lastRands = rands;
    // Мы не меняем this._flags, так как конфиг может иметь другие флаги

    int getSafeRand(int index) => rands[index % rands.length];

    List<String> passwordChars = [];
    String allAllowedChars = '';
    int randCursor = 0;

    // Категории: Digits(1), Lower(4), Upper(16), Symbols(64)
    for (int f in [1, 4, 16, 64]) {
      if ((flags & f) != 0) {
        String chars = alphabet.getAlphabet(f);
        if (chars.isNotEmpty) {
          allAllowedChars += chars;
          // Required проверка (флаг << 1)
          if ((flags & (f << 1)) != 0 && passwordChars.length < length) {
            passwordChars.add(chars[getSafeRand(randCursor) % chars.length]);
            randCursor++;
          }
        }
      }
    }

    if (allAllowedChars.isEmpty) return {'password': '', 'strength': '0'};

    // Заполнение
    while (passwordChars.length < length) {
      passwordChars.add(allAllowedChars[getSafeRand(randCursor) % allAllowedChars.length]);
      randCursor++;
    }

    // Перемешивание
    for (int i = passwordChars.length - 1; i > 0; i--) {
      int j = getSafeRand(length + i) % (i + 1);
      String temp = passwordChars[i];
      passwordChars[i] = passwordChars[j];
      passwordChars[j] = temp;
    }

    String password = passwordChars.join('');
    
    return {
      'password': password,
      'strength': getPasswdStrength(password).toString(),
      'config': _internalGenerateConfig(length, flags, rands)
    };
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ---

  String _internalGenerateConfig(int len, int flags, List<int> rnds) {
    return '${encodeBase64(len.toString())}.${encodeBase64(flags.toString())}.${base64Encode(rnds)}';
  }

  // Если нужно получить конфиг последнего сгенерированного пароля отдельно
  String lastConfig() => _internalGenerateConfig(_lastLength, _flags, _lastRands);
  
  void updateFlags(int newFlags) => _flags = newFlags;
}