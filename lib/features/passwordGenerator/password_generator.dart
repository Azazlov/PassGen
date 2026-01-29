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
  bool uniqUpper = true;
  bool useLower = true;
  bool uniqLower = true;
  bool useDigits = true;
  bool uniqDigits = true;
  bool useSpec1 = false;
  bool uniqSpec1 = true;
  bool useSpec2 = false;
  bool uniqSpec2 = true;
  bool useSpec3 = false;
  bool uniqSpec3 = true;
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
            SizedBox(height: 36),
            buildInput(
              label: 'Сервис', 
              placeholder: 'Без точек', 
              textController: serviceController, 
              hidden: false, 
              symbols: TextInputType.text, 
              submFunction: generatePassword
            ),
            SizedBox(height: 18),
            Text(
              'Настройки длины пароля',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
            buildInput(
              label: 'Мин. длина', 
              placeholder: 'от 1 до 1024', 
              textController: minLengthController, 
              hidden: false, 
              symbols: TextInputType.number, 
              submFunction: generatePassword
            ),
            buildInput(
              label: 'Макс. длина', 
              placeholder: 'от 1 до 1024', 
              textController: maxLengthController, 
              hidden: false, 
              symbols: TextInputType.number, 
              submFunction: generatePassword
            ),
            Divider(height: 32,),
            ExpansionTile(
              title:  Text('Настройки символов'), children: [
              buildSwitch(
                label: 'Заглавные буквы', 
                value: useUpper, 
                isUsed: (v) => setState(() => useUpper = v),
                icon: Icons.text_fields
              ),
              buildSwitch(
                label: 'Строчные буквы', 
                value: useLower, 
                isUsed: (v) => setState(() => useLower = v),
                icon: Icons.text_fields
              ),
              buildSwitch(
                label: 'Цифры', 
                value: useDigits, 
                isUsed: (v) => setState(() => useDigits = v),
                icon: Icons.dialpad
              ),
              buildSwitch(
                label: 'Спец. символы', 
                value: useSpec1, 
                isUsed: (v) => setState(() => useSpec1 = v),
                icon: Icons.tag
              ),
              buildSwitch(
                label: "Доп. спец. символы", 
                value: useSpec2, 
                isUsed: (v) => setState(() => useSpec2 = v),
                icon: Icons.tag
              ),
              buildSwitch(
                label: 'Редкие спец. символы', 
                value: useSpec3, 
                isUsed: (v) => setState(() => useSpec3 = v),
                icon: Icons.tag
              ),
            ]), 
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