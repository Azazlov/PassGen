import 'package:flutter/material.dart';
import 'package:pass_gen/modules/password_generation_config.dart';
import 'package:pass_gen/modules/generate_password.dart';
import 'package:pass_gen/modules/encrypted.dart';
import 'package:pass_gen/shared/dialogs.dart';
import 'package:pass_gen/features/storage/database_service.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class PasswordGenerationInterface {
  int version = 1;
  late String password;
  late String service;
  late dynamic lastUsageDate;
  late String uuid;
  late String category;
  late int expireDays;
  late int flags;
  late List<int> passwordLength;
  late PasswordGenerator generator;
  String includeDigits = '0123456789';
  String includeLowercase = 'abcdefghijklmnopqrstuvwxyz';
  String includeUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String includeSpecSymbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  Encrypted encrypter = Encrypted();

  late String generatedPassword;
  late String strengthGeneratedPassword;
  late String encodedPasswordGenerationConfig = '';
  
  PasswordGenerationInterface({
    required this.password,
    required this.service,
    required this.lastUsageDate,
    required this.uuid,
    required this.category,
    required this.expireDays,
    required this.flags,
    required this.passwordLength
  });

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
    // Игнорирование ошибки
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

  String appPassword = '12';
  String serviceName = 'asdfas';
  String lastUsageDate = '';
  String uuid = Uuid().v8();
  String categoryName = 'Default';
  int expireDays = 30;

  late BuildContext context;
  late PasswordGenerationInterface passwordGenerator;
  late PasswordGenerationConfig passwordConfig = PasswordGenerationConfig(encr: '');

  final DatabaseService _dbService = DatabaseService.instance;

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
  late List<int> passwordLengthRange;
  late int flags;

  late String label;

  late Color color;

  String password = '';
  String config = '';
  String strength = '';

  bool reqUpper = false;
  bool reqLower = false;
  bool reqDigits = false;
  bool reqSymbols = false;

  AppData(){
    updateStrength(passwordStrength);
    updatePasswordGenerator();
  }

  void updateStrength(int passwordStrength){
    this.passwordStrength = passwordStrength;
    passwordLengthRange = strengthLabels[passwordStrength]!['length_range'];
    flags = strengthLabels[passwordStrength]!['flags'];

    label = '${strengthLabels[passwordStrength]?['label'] ?? "Неизвестная сложность $passwordStrength"}';
    color = strengthLabels[passwordStrength]!['color'];

    minLengthController.text = passwordLengthRange.first.toString();
    maxLengthController.text = passwordLengthRange.last.toString();
  }

  void toggleFlag(int flag) {
    if (flag > 0) {
      // Установить флаг (включить обязательность)
      flags |= flag;
    } else {
      // Снять флаг (выключить обязательность)
      flags &= ~(-flag);
    }
  }

  void updatePasswordGenerator(){
    passwordGenerator = 
    PasswordGenerationInterface(
      password: appPassword, 
      service: serviceName, 
      lastUsageDate: lastUsageDate, 
      uuid: uuid, 
      category: categoryName, 
      expireDays: expireDays, 
      flags: flags, 
      passwordLength: passwordLengthRange
    );
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
    // Пустая реализация
  }

  Future<void> saveConfigToDatabase() async {
    final configMap = {
      'version': passwordConfig.version,
      'service': passwordConfig.service,
      'lastUsageDate': passwordConfig.lastUsageDate.toString(),
      'uuid': passwordConfig.uuid,
      'category': passwordConfig.category,
      'expireDays': passwordConfig.expireDays,
      'encr': passwordConfig.encr,
      'password': password,
      'strength': strength,
      'config': config,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await _dbService.savePasswordConfig(configMap);
  }

  Future<void> updateConfigInDatabase() async {
    final configMap = {
      'version': passwordConfig.version,
      'service': passwordConfig.service,
      'lastUsageDate': passwordConfig.lastUsageDate.toString(),
      'uuid': passwordConfig.uuid,
      'category': passwordConfig.category,
      'expireDays': passwordConfig.expireDays,
      'encr': passwordConfig.encr,
      'password': password,
      'strength': strength,
      'config': config,
    };
    
    await _dbService.updateConfig(configMap);
  }

  Future<List<Map<String, dynamic>>> getAllConfigsFromDatabase() async {
    return await _dbService.getAllConfigs();
  }

  Future<Map<String, dynamic>?> getConfigByUuidFromDatabase(String uuid) async {
    return await _dbService.getConfigByUuid(uuid);
  }

  Future<void> deleteConfigFromDatabase(String uuid) async {
    await _dbService.deleteConfig(uuid);
  }

  void unChangeConfig(){
    changeConfig = false;
  }

  Future<void> saveEncrypt() async {
    await saveConfigToDatabase();
  }

  void copyPsswd() {
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

  Future<void> generatePassword() async{
    if (generating){return;}
    generating = true;
    parameters = checkInputs(
      minLength: minLengthController.text,
      maxLength: maxLengthController.text,
      reqSymbols: [
        reqUpper,
        reqLower,
        reqDigits,
        reqSymbols
      ],
    );

    passwordLengthRange = [
      int.tryParse(minLengthController.text) ?? 12,
      int.tryParse(maxLengthController.text) ?? 16
    ];

    minLengthController.text = passwordLengthRange.first.toString();
    maxLengthController.text = passwordLengthRange.last.toString();

    if (passwordLengthRange.first > passwordLengthRange.last || passwordLengthRange.first > 255 || passwordLengthRange.last > 255){
      throw Exception('Недопустимое значение');
    }

    updatePasswordGenerator();
    passwordConfig = await passwordGenerator.getConfig();
    password = passwordGenerator.generatedPassword;
    strength = passwordGenerator.strengthGeneratedPassword;
    config = passwordGenerator.encodedPasswordGenerationConfig;

    await saveConfigToDatabase();

    generating = false;
  }
}