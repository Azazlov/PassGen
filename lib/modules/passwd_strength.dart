import 'package:password_strength/password_strength.dart';
import 'package:zxcvbn/zxcvbn.dart';

// Вычисляет надежность пароля и выдает число от 0 до 1 (дробное)
// Чем ближе к 1, тем надежнее
double getPasswdStrength(String password) {
  double strength = estimatePasswordStrength(password);
  double? zxcvbnScore = Zxcvbn().evaluate(password).score! / 4; 

  return 0.8 * zxcvbnScore + 0.2 * strength;
}