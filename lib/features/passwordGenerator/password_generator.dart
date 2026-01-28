// ignore_for_file: use_build_context_synchronously

import 'package:pass_gen/features/passwordGenerator/password_generator_business.dart';
import 'package:pass_gen/modules/generate_password.dart';
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
  final TextEditingController minLengthController = TextEditingController(text: '12');
  final TextEditingController maxLengthController = TextEditingController(text: '16');
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
    parameters = checkInputs(
      minLengthController.text, 
      maxLengthController.text, 
      [useLower, useUpper, useDigits, 
      useSpec1, 
      useSpec2, 
      useSpec3]
    );

    PasswordGenerator generator = PasswordGenerator(
      symbolAlphabet: const SymbolAlphabet(), 
      range: [
        int.parse(minLengthController.text), 
        int.parse(maxLengthController.text)
      ], 
      flags: 512
    );

    if (lastConfig == configController.text && configController.text.trim() != ''){
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

    lastConfig = configController.text;

    if (parameters['isRender'] == 'true'){
      showDialogWindow1(
        parameters['title']!, 
        parameters['content']!, 
        context
      );
    }

    setState(() {
      generatedPassword = 'Тут будет пароль';
      // secret = success[1];
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
          padding: EdgeInsets.all(16),
          children: [
            // buildInput(
            //   label: 'Шифр конфига', 
            //   placeholder: 'сервис.****', 
            //   textController: configController, 
            //   hidden: false, 
            //   symbols: TextInputType.text, 
            //   submFunction: generatePassword
            // ),
            // buildInput(
            //   label: 'Ключ шифрования', 
            //   placeholder: 'СОХРАНИТЕ ЕГО!', 
            //   textController: keyController, 
            //   hidden: true, 
            //   symbols: TextInputType.text, 
            //   submFunction: generatePassword
            // ),
            buildInput(
              label: 'Сервис', 
              placeholder: 'Без точек', 
              textController: serviceController, 
              hidden: false, 
              symbols: TextInputType.text, 
              submFunction: generatePassword
            ),
            buildInput(
              label: 'Длина пароля', 
              placeholder: 'от 1 до 1<<16', 
              textController: minLengthController, 
              hidden: false, 
              symbols: TextInputType.number, 
              submFunction: generatePassword
            ),
            buildInput(
              label: 'Длина пароля', 
              placeholder: 'от 1 до 1<<16', 
              textController: maxLengthController, 
              hidden: false, 
              symbols: TextInputType.number, 
              submFunction: generatePassword
            ),
            SizedBox(height: 40),
            buildSwitch(
              label: 'Заглавные буквы', 
              value: useUpper, 
              onChanged: (v) => setState(() => useUpper = v)
            ),
            buildSwitch(
              label: 'Строчные буквы', 
              value: useLower, 
              onChanged: (v) => setState(() => useLower = v)
            ),
            buildSwitch(
              label: 'Цифры', 
              value: useDigits, 
              onChanged: (v) => setState(() => useDigits = v)
            ),
            buildSwitch(
              label: 'Спец. символы', 
              value: useSpec1, 
              onChanged: (v) => setState(() => useSpec1 = v)
            ),
            buildSwitch(
              label: "Доп. спец. символы", 
              value: useSpec2, 
              onChanged: (v) => setState(() => useSpec2 = v)
            ),
            buildSwitch(
              label: 'Редкие спец. символы', 
              value: useSpec3, 
              onChanged: (v) => setState(() => useSpec3 = v)
            ),

            SizedBox(height: 48),
            buildButton(
              label: 'Сгенерировать', 
              function: generatePassword
            ),

            buildCopyOnTap(
              label: 'Пароль', 
              text1: generatedPassword, 
              function: copyPsswd
            )
          ],
        ),
      ));
    }
  }