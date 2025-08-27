// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pass_gen/features/passwordGenerator/psswd_gen_interface.dart';
import 'package:pass_gen/features/storage/storage_service.dart';
import 'package:pass_gen/shared/dialog.dart';
import 'package:pass_gen/shared/interface.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController masterController = TextEditingController();
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
  Uint64List randomMaster = Uint64List(16);
  String lastConfig = '';

  @override 
  void initState(){
    super.initState();
    generator = PasswordGenerationInterface();
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
    masterController.text = '';
  }
  void unChangeConfig(){
    changeConfig = false;
  }
  void saveEncrypt() async{
    final encryptedconfigs = await getConfigs('encryptedConfigs');
    await saveConfig('encryptedConfigs', encryptedconfigs==null?[secret]:encryptedconfigs+[secret]);
  }
  void copyPsswd() {
    showDialogWindow2('Скопировано', "Сохранить шифр в хранилище?", context, "Да", saveEncrypt, "Нет", pass);
  }

  Future<void> generatePassword() async {
    try{
      if (int.parse(lengthController.text) < 1){
        showDialogWindow1('Ошибка!', "Длина должна быть любым положительным числом от 1", context);
        return;
      }
    }
    catch (exception){
      showDialogWindow1('Ошибка!', "Длина должна быть любым положительным числом от 1", context);
      return;
    }

    if (!(useUpper || useLower || useDigits || useSpec1 || useSpec2 || useSpec3)){
      showDialogWindow1('Ошибка!', 'Должен быть включен хоть 1 параметр допустимых символов', context);
      return;
    }

    if (serviceController.text.contains('.')){
      showDialogWindow1('Ошибка!', "Попробуйте заменить или убрать точку в названии сервиса", context);
      return;
    }

    changeConfig = true;

    if (lastConfig == masterController.text && masterController.text != ''){
      showDialogWindow2('Изменить', 'Хотите изменить конфигурацию генерации пароля?', context, 'Да', toChangeConfig, 'Нет', unChangeConfig);
      return;
    }

    for (int i=0; i<randomMaster.length; i++){
      randomMaster[i] = await generator.generateMaster();
    }

    final check = masterController.text.split('.');

    if (check.length == 2){
        try {
          await generator.getConfig(
          config: masterController.text, 
          key: keyController.text, 
        );
        }
        on Exception{
          showDialogWindow1('Ошибка!', 'Неправильный конфиг или пароль от конфига', context);
          return;
        }
        final config = await generator.getConfig(
        config: masterController.text, 
        key: keyController.text
        );
        final params = config.split('.');
        final paramlen = params.length;

        serviceController.text = check[0];
        for (int i=0; i<paramlen-8; i++){
          // print(i);
          randomMaster[i] = int.parse(params[i], radix: 36);
          // print(randomMaster[i]);
        }
        lengthController.text = params[paramlen-7];
        useUpper = params[paramlen-6]=='t'?true:false;
        useLower = params[paramlen-5]=='t'?true:false;
        useDigits = params[paramlen-4]=='t'?true:false;
        useSpec1 = params[paramlen-3]=='t'?true:false;
        useSpec2 = params[paramlen-2]=='t'?true:false;
        useSpec3 = params[paramlen-1]=='t'?true:false;

        lastConfig = masterController.text;
    }

    final success = await generator.generatePsswdSecret(
      master: randomMaster, 
      key: keyController.text,
      service: serviceController.text, 
      length: lengthController.text, 
      useUpper: useUpper, 
      useLower: useLower, 
      useDigits: useDigits, 
      useSpec1: useSpec1, 
      useSpec2: useSpec2, 
      useSpec3: useSpec3,
    );

    await saveConfig('psswdGen', [
      keyController.text,  
      lengthController.text,
      useUpper.toString(),
      useLower.toString(),
      useDigits.toString(),
      useSpec1.toString(),
      useSpec2.toString(),
      useSpec3.toString()
      ]);

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
            buildInput('Шифр конфига', 'сервис.****', masterController, false, TextInputType.text, generatePassword),
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