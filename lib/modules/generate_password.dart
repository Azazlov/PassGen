import 'package:pass_gen/modules/encrypted.dart';
import 'package:pass_gen/modules/passwd_strength.dart';

class PasswordGenerator{
  late String alphabet;
  late int length;
  late List<int> _rands;
  late bool isUniq;
  PasswordGenerator(
    this.alphabet, 
    this.length, 
    this.isUniq
  );

  List<dynamic> generatePassword(){
    _rands = random(len: length);
    String password = '';
    int alphaLen = alphabet.length;
    for (int i = 0; i < length; i++){
      password += alphabet[_rands[i]%alphaLen];
    }
    double psswdStrength = getPasswdStrength(password);
    return [password, psswdStrength];
  }
  
  List<int> getParameters(){
    return [];
  }
}

void main(){
  PasswordGenerator generator = PasswordGenerator('ABCDEFGHIJKLMNOPQRSTTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890', 6, false);
  List<dynamic> passwordInfo = generator.generatePassword(); 
  String password = passwordInfo[0];
  double passwordStrength = passwordInfo[1];
  print('Пароль: $password');
  print('Надежность пароля: ${passwordStrength}');
}