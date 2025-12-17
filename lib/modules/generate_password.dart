import 'package:pass_gen/modules/encrypted.dart';
import 'package:pass_gen/modules/passwd_strength.dart';

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

  List<dynamic> generatePassword(){
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
    return [password, psswdStrength];
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
  List<dynamic> passwordInfo = generator.generatePassword(); 
  String password = passwordInfo[0];
  double passwordStrength = passwordInfo[1];
  print('Пароль: $password');
  print('Надежность пароля: ${passwordStrength}');
}