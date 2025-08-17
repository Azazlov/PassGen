// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:secure_pass/features/passwordGenerator/psswd_gen_interface.dart';
import 'package:flutter/services.dart';
import 'package:secure_pass/features/storage/storage_service.dart';
import 'package:secure_pass/shared/dialog.dart';
import 'package:secure_pass/shared/interface.dart';

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
  String randomMaster = '';
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

    randomMaster = await generator.generateMaster();
    final check = masterController.text.split('.');

    if (check.length == 4){
        final config = await generator.getConfig(
          config: masterController.text, 
          key: keyController.text, 
          masterKey: masterKeyController.text
        );
        final params = config.split('.');

        if (params.length == 9){          
          String checkConfig = '';
          for (int i = 0; i < 8; i++){
            i !=7 ? checkConfig+='${params[i]}.' : checkConfig+=params[i];
          }
          if (checkConfig.hashCode.toString() == params[8]){
            serviceController.text = check[0];
            randomMaster = params[0];
            lengthController.text = params[1];
            useUpper = params[2]=='true'?true:false;
            useLower = params[3]=='true'?true:false;
            useDigits = params[4]=='true'?true:false;
            useSpec1 = params[5]=='true'?true:false;
            useSpec2 = params[6]=='true'?true:false;
            useSpec3 = params[7]=='true'?true:false;

            lastConfig = masterController.text;
          }
        }
        else{
          showDialogWindow1('Ошибка!', 'Неправильный конфиг или пароль от конфига', context);
          return;
        }
    }

    final success = await generator.generatePsswdSecret(
      master: randomMaster, 
      key: keyController.text,
      masterKey: masterKeyController.text,
      service: serviceController.text, 
      length: lengthController.text, 
      useUpper: useUpper, 
      useLower: useLower, 
      useDigits: useDigits, 
      useSpec1: useSpec1, 
      useSpec2: useSpec2, 
      useSpec3: useSpec3,
      secretPsswd: 'RH2RFC@u054+ERrWIao8dhJ4WB&THPhihXC()VYZY#SIX6^Y&DB1^b6WO)Y5#QlhG\$Y5U@DscggM(Crw!(CJ^Wl1YXR\$^Q&gg=gV^SUavI!Dr2XP&tCVaEiY1KE7Al30' 
      // secretPsswd для личного секретного пароля для генерации пароля
      // ПРИ ИЗМЕНЕНИИ МЕНЯЕТ ЛОГИКУ ФОРМИРОВАНИЯ ПАРОЛЯ
      // ПРИЛОЖЕНИЯ С РАЗНЫМИ ПАРОЛЯМИ НЕСОВМЕСТИМЫ ДЛЯ ГЕНЕРАЦИИ ОДИНАКОВЫХ ПАРОЛЕЙ ПРИ ОДИНАКОВЫХ КОНФИГАХ
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
    CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Генератор паролей'),
      ),
      child: Center(
        child: ListView(
          padding: setPadding(),
          children: [
            buildInput('Шифр конфига', 'сервис.****.****.****', masterController, false, TextInputType.text, generatePassword),
            buildInput('Ключ шифрования', 'СОХРАНИТЕ ЕГО!', keyController, true, TextInputType.text, generatePassword),
            buildInput('Сервис', 'Без точек', serviceController, false, TextInputType.text, generatePassword),
            buildInput('Длина пароля', 'от 1', lengthController, false, TextInputType.number, generatePassword),

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