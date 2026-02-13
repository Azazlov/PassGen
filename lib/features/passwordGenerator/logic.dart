import 'package:flutter/material.dart';
import 'package:pass_gen/modules/password_generation_config.dart';
import 'package:pass_gen/modules/generate_password.dart';
import 'package:pass_gen/modules/encrypted.dart';
import 'package:pass_gen/shared/dialogs.dart';
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
  late PasswordGenerator generator;
  String includeDigits = '0123456789';
  String includeLowercase = 'abcdefghijklmnopqrstuvwxyz';
  String includeUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String includeSpecSymbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  late String generatedPassword;
  late String strengthGeneratedPassword;
  late String encodedPasswordGenerationConfig;
  
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
    generator = PasswordGenerator(
      alphabet:  alphabet,
      lengthRange: passwordLength,
      flags: flags
    );
    Map<String, String> passwordData = generator.generatePassword();
    generatedPassword = passwordData['password']!;
    strengthGeneratedPassword = passwordData['strength']!;
    encodedPasswordGenerationConfig = passwordData['config']!;
    List<int> encr = await Encrypted().getEncr(
      message: utf8.encode(encodedPasswordGenerationConfig),
      password: utf8.encode(password)
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

Map<String, String> checkInputs({
  required String minLength,
  required String maxLength,
  required List<bool> reqSymbols,
  String title = 'undefined',
  String content = 'undefined',
  String isRender = 'false'
}){
  try{
    if (int.parse(minLength) > int.parse(maxLength)){
      throw Exception('Неправильный диапазон');
    }
  }
  catch (e){
    print(e);
  }
  return {
    'title': title,
    'content': content,
    'isRender': isRender
  };
}

class AppData{
  bool changeConfig = false;
  String lastConfig = '';
  late Map<String, String> parameters;
  late Map<String, String> passwordParameters;

  bool generating = false;

  TextEditingController keyController = TextEditingController();
  TextEditingController minLengthController = TextEditingController();
  TextEditingController maxLengthController = TextEditingController();
  TextEditingController serviceController = TextEditingController();

  Map<int, Map<String, dynamic>> strengthLabels = {
    0: {'label': 'Очень слабый', 'color': Colors.red, 'flags': digits, 'length_range': [4, 6]},
    1: {'label': 'Слабый', 'color': Colors.orange, 'flags': digits | lowercase, 'length_range': [6, 8]},
    2: {'label': 'Средний', 'color': const Color.fromARGB(255, 215, 223, 52), 'flags': digits | lowercase | uppercase, 'length_range': [8, 14]},
    3: {'label': 'Сильный', 'color': Colors.green, 'flags': digits | lowercase | uppercase | symbols, 'length_range': [14, 20]},
    4: {'label': 'Очень сильный', 'color': Colors.blue, 'flags': digits | lowercase | uppercase | symbols | 512, 'length_range': [20, 32]},
  };



  int passwordStrength = 2;
  late List<int> range;
  late int flags;
  late PasswordGenerator passwordGenerator;

  late String label;

  late Color color;

  String password = '';
  String config = '';
  String strength = '';

  bool reqUpper = false;
  bool reqLower = false;
  bool reqDigits = false;
  bool reqSpec1 = false;
  bool reqSpec2 = false;

  AppData(){
    updateStrength(passwordStrength);
  }

  void updateStrength(int passwordStrength){
    this.passwordStrength = passwordStrength;
    range = strengthLabels[passwordStrength]!['length_range'];
    flags = strengthLabels[passwordStrength]!['flags'];

    label = '${strengthLabels[passwordStrength]?['label'] ?? "Неизвестная сложность $passwordStrength"}';
    color = strengthLabels[passwordStrength]!['color'];

    minLengthController.text = range.first.toString();
    maxLengthController.text = range.last.toString();
  }

  Future<void> setupConfigs() async{
    // List<String> configs = await getConfigs('psswdGen');
  }

  void toChangeConfig(){
    changeConfig = true;
    lastConfig = '';
  }

  Map<String, List<String>> getConfigs(){
    return {'': ['', '']};
  }

  void saveConfig(){

  }

  void unChangeConfig(){
    changeConfig = false;
  }

  void saveEncrypt() async{
    // final encryptedconfigs = await getConfigs();
    saveConfig();
  }

  void copyPsswd(BuildContext context) {
    showDialogWindow2(
      'Скопировано',
      "Сохранить шифр в хранилище?",
      context, 
      "Да",
      saveEncrypt,
      "Нет",
      pass
    );
  }

  void generatePassword() {
    if (generating){return;}
    generating = true;
    parameters = checkInputs(
      minLength: minLengthController.text, 
      maxLength: maxLengthController.text, 
      reqSymbols: [
        reqUpper, 
        reqLower, 
        reqDigits, 
        reqSpec1, 
        reqSpec2, 
      ],
    );

    range = [
      int.tryParse(minLengthController.text) ?? 12, 
      int.tryParse(maxLengthController.text) ?? 16
    ];

    minLengthController.text = range.first.toString();
    maxLengthController.text = range.last.toString();

    if (range.first > range.last || range.first > 255 || range.last > 255){
      throw Exception('Недопустимое значение');
    }

    passwordGenerator = PasswordGenerator(
      alphabet: SymbolAlphabet(), 
      lengthRange: range, 
      flags: flags
    );

    passwordParameters = passwordGenerator.generatePassword();
    password = passwordParameters['password']!;
    strength = passwordParameters['strength']!;
    config = passwordParameters['config']!;
    print(
      '${passwordGenerator.restoreFromConfig(config)}'
    );
    generating = false;
  }
}