// ignore_for_file: use_build_context_synchronously

import 'package:pass_gen/features/passwordGenerator/password_generator_business.dart';
import 'package:pass_gen/modules/generate_password.dart';
import 'package:flutter/material.dart';
import 'package:pass_gen/features/passwordGenerator/password_generator_interface.dart';
import 'package:pass_gen/features/storage/storage_service.dart';
import 'package:pass_gen/shared/dialogs.dart';
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

  bool uniqUpper = true;
  bool uniqLower = true;
  bool uniqDigits = true;
  bool uniqSpec1 = true;
  bool uniqSpec2 = true;
  bool changeConfig = true;

  int passwordStrength = 32; 

  Map<int, Map<String, dynamic>> strengthLabels = {
    1: {'label': 'Очень слабый', 'color': Colors.red, 'flags': digits, 'length_range': [4, 6]},
    16: {'label': 'Слабый', 'color': Colors.orange, 'flags': digits | lowercase, 'length_range': [6, 8]},
    32: {'label': 'Средний', 'color': const Color.fromARGB(255, 215, 223, 52), 'flags': digits | lowercase | uppercase, 'length_range': [8, 14]},
    48: {'label': 'Сильный', 'color': Colors.green, 'flags': digits | lowercase | uppercase | symbols, 'length_range': [14, 20]},
    64: {'label': 'Очень сильный', 'color': Colors.blue, 'flags': digits | lowercase | uppercase | symbols | 512, 'length_range': [20, 32]},
  };

  Map<String, String> success = {};
  String password = '';
  String config = '';
  String strength = '';

  String lastConfig = '';

  late Map<String, String> parameters;

  @override 
  void initState(){
    super.initState();
    setupConfigs();
  }

  Future<void> setupConfigs() async{
    // List<String> configs = await getConfigs('psswdGen');
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
      encryptedconfigs==null?[config]:encryptedconfigs+[config]
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
      [uniqUpper, uniqLower, uniqDigits, 
      uniqSpec1, 
      uniqSpec2, 
      ],
    );

    PasswordGenerator generator = PasswordGenerator(
      symbolAlphabet: SymbolAlphabet(
        appended: strengthLabels[passwordStrength]?['flags'] as int == 597
      ), 
      range: [
        int.parse(minLengthController.text), 
        int.parse(maxLengthController.text)
      ], 
      flags: strengthLabels[passwordStrength]?['flags'] as int
    );
    success = generator.generatePassword();
    password = success['password']!;
    strength = success['strength']!;
    config = success['config']!;

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
      password = success['password']!;
      strength = success['strength']!;
      config = success['config']!;
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
            SizedBox(height: 36),
            ListTile(
              title: Text(
                'Генератор паролей',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            buildInput(
              label: 'Сервис', 
              placeholder: 'Без точек', 
              textController: serviceController, 
              symbols: TextInputType.text, 
              submFunction: generatePassword
            ),
            Slider(
              value: passwordStrength.toDouble(),
              min: 1,
              max: 64,
              divisions: 4, 
              label: '${strengthLabels[passwordStrength]?['label'] ?? "Неизвестная сложность $passwordStrength"}',
              activeColor: strengthLabels[passwordStrength]?['color'] != null
                  ? strengthLabels[passwordStrength]!['color'] as Color
                  : null,
              onChanged: (value) {
                setState(() {
                  passwordStrength = value.toInt();
                  minLengthController.text = strengthLabels[passwordStrength]?['length_range'][0].toString() ?? '12';
                  maxLengthController.text = strengthLabels[passwordStrength]?['length_range'][1].toString() ?? '16';
                });
              },
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
              placeholder: 'от 1 до 32', 
              textController: minLengthController, 
              symbols: TextInputType.number, 
              submFunction: generatePassword
            ),
            buildInput(
              label: 'Макс. длина', 
              placeholder: 'от 1 до 64', 
              textController: maxLengthController,  
              symbols: TextInputType.number, 
              submFunction: generatePassword
            ),
            Divider(height: 32,),
            ExpansionTile(
              title:  Text('Настройки обязательности'), children: [
              buildSwitch(
                label: 'Заглавные буквы', 
                value: uniqUpper, 
                isUsed: (v) => setState(() => uniqUpper = v),
                icon: Icons.text_fields
              ),
              buildSwitch(
                label: 'Строчные буквы', 
                value: uniqLower, 
                isUsed: (v) => setState(() => uniqLower = v),
                icon: Icons.text_fields
              ),
              buildSwitch(
                label: 'Цифры', 
                value: uniqDigits, 
                isUsed: (v) => setState(() => uniqDigits = v),
                icon: Icons.dialpad
              ),
              buildSwitch(
                label: 'Спец. символы', 
                value: uniqSpec1, 
                isUsed: (v) => setState(() => uniqSpec1 = v),
                icon: Icons.tag
              ),
              buildSwitch(
                label: "Доп. спец. символы", 
                value: uniqSpec2, 
                isUsed: (v) => setState(() => uniqSpec2 = v),
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
              text1: password, 
              function: copyPsswd
            ),
          ],
        ),
      ));
    }
  }