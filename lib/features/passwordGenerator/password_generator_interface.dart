import 'package:pass_gen/modules/password_generation_config.dart';
import 'package:pass_gen/modules/generate_password.dart';

class PsswdGenInterface {
  late String password;
  late int version;
  late String service;
  late dynamic lastUsageDate;
  late String uuid;
  late String category;
  late int expireDays;
  late List<bool> includedSymbols; // [digits, lowercase, uppercase, symbols]
  late int flags;
  late List<int> passwordLength = [12, 16];
  late bool isUniq = false;
  String includeDigits = '0123456789';
  String includeLowercase = 'abcdefghijklmnopqrstuvwxyz';
  String includeUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String includeSpecSymbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  
  PsswdGenInterface(
    String password,
    int version,
    String service,
    dynamic lastUsageDate,
    String uuid,
    String category,
    int expireDays,
    List<bool> includedSymbols
  );
  Future<PasswordGenerationConfig> getConfig() async{
    SymbolAlphabet alphabet = SymbolAlphabet();
    PasswordGenerator generator = PasswordGenerator(
      symbolAlphabet:  alphabet,
      range: passwordLength,
      flags: flags);
    Map<String, String> passwordData = await generator.generatePassword();
    String password = passwordData['password']!;
    String passwordStrength = passwordData['strength']!;

    return PasswordGenerationConfig(
      version: version,
      service: service,
      lastUsageDate: lastUsageDate,
      uuid: uuid,
      category: category,
      expireDays: expireDays,
      encr: encr
    );
  }
}