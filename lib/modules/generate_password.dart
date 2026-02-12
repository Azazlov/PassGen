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

class PasswordGenerator{
  late SymbolAlphabet alphabet;
  late List<int> lengthRange; // [min, max]
  late List<int> _rands; // Случайные числа для воспроизведения генерации
  late int _length; // Длина генерируемого пароля
  late int _flags; // Побитовые флаги: какие категории используются, какие обязательны, уникальность
  bool isRestored = false;

  PasswordGenerator({
    required SymbolAlphabet symbolAlphabet,
    required List<int> range,
    required int flags,
    this.isRestored = false,
  }) {
    alphabet = symbolAlphabet;
    lengthRange = range;
    _flags = flags;
    _rands = [];
    _length = 0;
  }

  // Проверить, включена ли категория
  bool isCategoryEnabled(int categoryFlag) {
    return (_flags & categoryFlag) != 0;
  }

  // Проверить, обязательна ли категория
  bool isCategoryRequired(int categoryFlag) {
    return (_flags & (categoryFlag << 1)) != 0;
  }

  // Проверить, должны ли все символы быть уникальны
  bool shouldBeUnique() {
    return (_flags & allIsUniq) != 0;
  }

  Map<String, String> generatePassword(){
    _length = isRestored ? _length : randomInt(min: lengthRange[0], max: lengthRange[1]+1);
    _rands = isRestored ? _rands : random(len: _length*2);
    String password = '';
    
    List<int> enabledCategories = [];
    List<int> categoryFlags = [digits, lowercase, uppercase, symbols];
    Map<int, List<String>> availableSymbols = {};
    String tempAlpha;
    // Определяем, какие категории включены
    for (int flag in categoryFlags) {
      if (isCategoryEnabled(flag)) {
        enabledCategories.add(flag);
        if (isCategoryRequired(flag)){
          tempAlpha = alphabet.getAlphabet(flag);
          if (tempAlpha.isNotEmpty){
            // Добавляем обязательный символ в пароль
            int randIndex = _rands[password.length] % tempAlpha.length;
            password += tempAlpha[randIndex];
            if (shouldBeUnique()){
              // Удаляем использованный символ из доступных
              availableSymbols[flag] = tempAlpha.split('')..removeAt(randIndex);
              if (availableSymbols[flag]!.isEmpty){
                enabledCategories.remove(flag);
              }
            }
          }
        }
      }
    }

    int uniqueChars = password.length;

    for (int i = 0; i < _length - uniqueChars; i++){
      if (enabledCategories.isEmpty){
        break;
      }
      int catIndex = _rands[password.length + i] % enabledCategories.length;
      int categoryFlag = enabledCategories[catIndex];
      String chars;
      if (shouldBeUnique() && availableSymbols.containsKey(categoryFlag)){
        chars = availableSymbols[categoryFlag]!.join('');
      } else {
        chars = alphabet.getAlphabet(categoryFlag);
      }
      if (chars.isEmpty){
        continue;
      }
      int charIndex = _rands[password.length + i] % chars.length;
      password += chars[charIndex];
      if (shouldBeUnique()){
        // Удаляем использованный символ из доступных
        availableSymbols[categoryFlag]!.removeAt(charIndex);
        if (availableSymbols[categoryFlag]!.isEmpty){
          enabledCategories.removeAt(catIndex);
        }
      }
    }
    double psswdStrength = getPasswdStrength(password);
    isRestored = false;
    return {
      'password': password, 
      'strength': psswdStrength.toString(), 
      'config': generateConfig()
    };
  }
  
  List<String> shuffleList(List<String> list){
    List<String> shuffled = [];
    List<String> tempList = List.from(list);
    while (tempList.isNotEmpty){
      int randIndex = randomInt(min: 0, max: tempList.length);
      shuffled.add(tempList[randIndex]);
      tempList.removeAt(randIndex);
    }
    return shuffled;
  }

  String generateConfig(){
    String config = '${encodeBase64(_length.toString())}.${encodeBase64(_flags.toString())}.${base64Encode(_rands)}';
    return config;
  }

  void restoreConfig(String config) {
    List<String> parts = config.split('.');
    if (parts.length >= 3) {
      _length = (int.parse(decodeBase64(parts[0])));
      _flags = int.parse(decodeBase64(parts[1]));
      _rands = List<int>.from(base64Decode(parts[2]));
      isRestored = true;
    }
  }
}