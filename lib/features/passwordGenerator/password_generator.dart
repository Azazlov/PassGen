// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:pass_gen/features/passwordGenerator/password_generator_business.dart';
import 'package:flutter/material.dart';
import 'package:pass_gen/features/passwordGenerator/password_generator_interface.dart';
import 'package:pass_gen/features/storage/storage_service.dart';
import 'package:pass_gen/shared/dialog.dart';
import 'package:pass_gen/shared/interface.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController configController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController masterKeyController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController lengthController = TextEditingController(text: '16');
  late PasswordGenerationInterface generator;

  bool useUpper = true;
  bool useLower = true;
  bool useDigits = true;
  bool useSpec1 = false;
  bool useSpec2 = false;
  bool useSpec3 = false;
  bool changeConfig = true; 

  String generatedPassword = '';
  String secret = '';
  String lastConfig = '';

  late Map<String, String> parameters;

  @override 
  void initState(){
    super.initState();
    setupConfigs();
  }

  Future<void> setupConfigs() async{
    List<String> configs = await getConfigs('psswdGen');

    keyController.text = configs[0];
    lengthController.text = configs[1];
    useUpper = configs[2]=='true'?true:false;
    useLower = configs[3]=='true'?true:false;
    useDigits = configs[4]=='true'?true:false;
    useSpec1 = configs[5]=='true'?true:false;
    useSpec2 = configs[6]=='true'?true:false;
    useSpec3 = configs[7]=='true'?true:false;
  }

  void toChangeConfig(){
    changeConfig = true;
    lastConfig = '';
  }

  void unChangeConfig(){
    changeConfig = false;
  }

  void saveEncrypt() async{
    final encryptedconfigs = await getConfigs('encryptedConfigs');
    await saveConfig(
      'encryptedConfigs',
      encryptedconfigs==null?[secret]:encryptedconfigs+[secret]
    );
  }

  void copyPsswd() {
    showDialogWindow2(
      'Скопировано',
      "Сохранить шифр в хранилище?",
      context, "Да",
      saveEncrypt,
      "Нет",
      pass
    );
  }

  Future<void> generatePassword() async {
    parameters = checkInputs();

    if (lastConfig == configController.text && configController.text != ''){
      showDialogWindow2(
        'Изменить', 
        'Хотите изменить конфигурацию генерации пароля?', 
        context, 
        'Да', 
        toChangeConfig, 
        'Нет', 
        unChangeConfig
      );
      return;
    }

    final check = configController.text.split('.');
    if (parameters['isRender'] == 'true'){
      showDialogWindow1(
        parameters['title']!, 
        parameters['content']!, 
        context
      );
    }

    setState(() {
      generatedPassword = success[0];
      secret = success[1];
      return;
    });
  }
    @override
    Widget build(BuildContext context) {
    return 
    Scaffold(
      // navigationBar: CupertinoNavigationBar(
      //   middle: Text('Генератор паролей'),
      // ),
      body: Center(
        child: ListView(
          padding: setPadding(),
          children: [
            buildInput('Шифр конфига', 'сервис.****', configController, false, TextInputType.text, generatePassword),
            buildInput('Ключ шифрования', 'СОХРАНИТЕ ЕГО!', keyController, true, TextInputType.text, generatePassword),
            buildInput('Сервис', 'Без точек', serviceController, false, TextInputType.text, generatePassword),
            buildInput('Длина пароля', 'от 1 до 1<<16', lengthController, false, TextInputType.number, generatePassword),

            SizedBox(height: 40),
            buildSwitch('Заглавные буквы', useUpper, (v) => setState(() => useUpper = v)),
            buildSwitch('Строчные буквы', useLower, (v) => setState(() => useLower = v)),
            buildSwitch('Цифры', useDigits, (v) => setState(() => useDigits = v)),
            buildSwitch('!@#\$%^&*()_+-=', useSpec1, (v) => setState(() => useSpec1 = v)),
            buildSwitch("\"'`,./;:[]}{<>\\|", useSpec2, (v) => setState(() => useSpec2 = v)),
            buildSwitch('~?', useSpec3, (v) => setState(() => useSpec3 = v)),

            SizedBox(height: 48),
            buildButton('Сгенерировать', generatePassword),

            buildCopyOnTap('Пароль', generatedPassword, copyPsswd)
          ],
        ),
      ));
    }
  }