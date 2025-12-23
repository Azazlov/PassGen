import 'dart:convert';
import 'dart:typed_data';
import 'package:pass_gen/modules/encrypted.dart';
import 'package:pass_gen/modules/passwd_strength.dart';

// Bit masks for categories and flags
const int _DIGITS = 1 << 0;    // bit 0
const int _LOWER = 1 << 1;     // bit 1
const int _UPPER = 1 << 2;     // bit 2
const int _SYMBOL = 1 << 3;    // bit 3
const int _IS_UNIQ = 1 << 4;   // bit 4

class PasswordGenerator{
  late Map<String, List<dynamic>> includedSymbols; // {'digits': [...], 'lowercase': [...], ...}
  late List<int> lengthRange; // [min, max]
  late List<int> _rands; // Временный список рандомных чисел  
  late bool isUniq; // при этом параметре должна ограничиваться длина пароля размером алфавита
  PasswordGenerator(
    this.includedSymbols, 
    this.lengthRange,
    this.isUniq
  );

  Map<String, String> generatePassword(){
    int length = randomInt(min: lengthRange[0], max: lengthRange[1]+1);
    _rands = random(len: length);
    String password = '';
    includedSymbols.map((key, value) {
      for (int i = 0; i < _rands.length; i++){
        if (_rands[i] % includedSymbols.length == includedSymbols.keys.toList().indexOf(key)){
          num symbolIndex = _rands[i] % includedSymbols[key]![0].length;
          password += includedSymbols[key]![0][symbolIndex];
          if (isUniq){
            includedSymbols[key]![0].removeAt(symbolIndex);
            if (includedSymbols[key]!.isEmpty){
              includedSymbols.remove(key);
            }
          }
        }
      }
      return MapEntry(key, value);
    });
    password = shuffleList(List.from(password.split(''))).join('');

    double psswdStrength = getPasswdStrength(password);
    return {'password': password, 'strength': psswdStrength.toString()};
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

  // Encode categories and isUniq flag into bitmask
  int encodeCategoriesMask() {
    int mask = 0;
    if (includedSymbols.containsKey('digits')) mask |= _DIGITS;
    if (includedSymbols.containsKey('lowercase')) mask |= _LOWER;
    if (includedSymbols.containsKey('uppercase')) mask |= _UPPER;
    if (includedSymbols.containsKey('symbols')) mask |= _SYMBOL;
    if (isUniq) mask |= _IS_UNIQ;
    return mask;
  }

  // Convert mask to human-readable octal string
  static String maskToOctal(int mask) => mask.toRadixString(8);

  // Convert octal string back to mask
  static int octalToMask(String octal) => int.parse(octal, radix: 8);

  // Serialize generator state to compact binary format then base64
  String serializeToBase64() {
    int mask = encodeCategoriesMask();
    int minLen = lengthRange[0];
    int maxLen = lengthRange[1];
    print('mask: $mask\nminLen: $minLen\nmaxLen: $maxLen\nrands: $_rands');

    final bytes = Uint8List(3 + _rands.length);
    bytes[0] = mask & 255;
    bytes[1] = minLen & 255;
    bytes[2] = maxLen & 255;
    for (int i = 0; i < _rands.length; i++) {
      bytes[3 + i] = _rands[i] & 255;
    }
    return base64.encode(bytes);
  }

  // Deserialize from base64 to restore internal state
  void deserializeFromBase64(String b64) {
    final bytes = base64.decode(b64);
    int mask = bytes[0];
    lengthRange = [bytes[1], bytes[2]];
    _rands = bytes.sublist(3).toList();
    isUniq = (mask & _IS_UNIQ) != 0;
  }
  String privatePasswordGenerationConfig(){
    String config = base64Encode(_rands);
    return config;
  }
}

void main(){
  String includeDigits = '0123456789';
  String includeLowercase = 'abcdefghijklmnopqrstuvwxyz';
  String includeUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String includeSymbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  Map<String, List<dynamic>> alphabet = {
    // Пример алфавита для генерации пароля, где true - обязательные символы, false - не обязательные
    'digits': [includeDigits.split(''), true],
    'lowercase': [includeLowercase.split(''), true],
    'uppercase': [includeUppercase.split(''), true],
    'symbols': [includeSymbols.split(''), false]
  };

  PasswordGenerator generator = PasswordGenerator(alphabet, [12, 16], true);
  Map<String, String> passwordInfo = generator.generatePassword(); 
  String password = passwordInfo['password']!;
  double passwordStrength = double.parse(passwordInfo['strength']!);
  print('Пароль: $password');
  print('Надежность пароля: ${passwordStrength}');
  print('Сериализация в base64: ${generator.serializeToBase64()}');
  print('Приватный конфиг генерации: ${generator.privatePasswordGenerationConfig()}');
}
