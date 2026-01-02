import 'package:pass_gen/modules/password_generation_config.dart';
import 'package:pass_gen/modules/generate_password.dart';
import 'package:pass_gen/modules/encrypted.dart';
import 'dart:convert';

class PasswordGenerationInterface {
  int version = 1;
  late String password;
  late String service;
  late dynamic lastUsageDate;
  late String uuid;
  late String category;
  late int expireDays;
  late int flags;
  late List<int> passwordLength = [12, 16];
  String includeDigits = '0123456789';
  String includeLowercase = 'abcdefghijklmnopqrstuvwxyz';
  String includeUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String includeSpecSymbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  
  PasswordGenerationInterface(
    String password,
    String service,
    dynamic lastUsageDate,
    String uuid,
    String category,
    int expireDays,
    int flags,
    List<int> passwordLength
  );
  Future<PasswordGenerationConfig> getConfig() async{
    SymbolAlphabet alphabet = SymbolAlphabet();
    PasswordGenerator generator = PasswordGenerator(
      symbolAlphabet:  alphabet,
      range: passwordLength,
      flags: flags);
    Map<String, String> passwordData = generator.generatePassword();
    String password = passwordData['password']!;
    String passwordStrength = passwordData['strength']!;
    String generationConfig = passwordData['config']!;
    List<int> encr = await Encrypted().getEncr(
      message: utf8.encode(generationConfig),
      password: utf8.encode(this.password)
    );

    return PasswordGenerationConfig(
      version: version,
      service: service,
      lastUsageDate: lastUsageDate,
      uuid: uuid,
      category: category,
      expireDays: expireDays,
      encr: base64Encode(encr)
    );
  }
}