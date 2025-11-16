import 'package:password_strength/password_strength.dart';
import 'package:zxcvbn/zxcvbn.dart';

String getPasswdStrength(String password) {
  double strength = estimatePasswordStrength(password);
  double? zxcvbnScore = Zxcvbn().evaluate(password).score! / 4; 

  return "$password, ${0.8 * zxcvbnScore + 0.2 * strength}, $zxcvbnScore, $strength";
}

void main() {
  List<String> passwords = [
    "123456",
    "password",
    "qwerty",
    "abc123",
    "MyPass",
    "MyPass123",
    "MyPass123!",
    "MyP@ssw0rd!",
    "MyStr0ng!@#",
    "K8n~\$mP9zW!vR2x",
    "X7#vN2\$kL9@qZ3wE5",
    "T!m3l3ssR0ad&T3chn0l0gy",
    "R4nd0mP@ssw0rd!@#\$%^&*()",
    "B3l13v3_1n_Y0ur53lf#2025",
    "C0mpl3x_8yT3_P@ssphr4s3!",
  ];

  for (String password in passwords) {
    String result = getPasswdStrength(password);
    print(result);
  }
}