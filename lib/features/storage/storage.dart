// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:secure_pass/features/storage/storage_service.dart';
import 'package:secure_pass/features/passwordGenerator/psswd_gen_interface.dart';
import 'package:secure_pass/features/storage/storage_interface.dart';
import 'package:secure_pass/shared/dialog.dart';
import 'package:secure_pass/shared/interface.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>{

  String encryptedConfig = 'Ничего не выбрано';
  String service = 'Нет названия сервиса';
  String keyConfig = 'encryptedConfigs';
  String thisConfig = '';
  int configs = 0;

  int id = 0;
  late PasswordGenerationInterface generator;
  
  @override
  void initState(){
    super.initState();
    psswdConfigs(0);
  }

  Future<int> psswdConfigs(int i) async{
    List<String> listConfigs = await getConfigs(keyConfig);
    configs = listConfigs.length;
    if (i<0){
      return 0;
    }
    try{
      

      if (configs == 0){
        setState(() {
          encryptedConfig = 'Нет конфигов';
          service = 'Нет названия сервиса';
        });
        return 0;
      }
      if (i==configs){
        if (i != 1){
          return 0;
        }
      }
      setState(() {
        thisConfig = listConfigs[i];
        final servicename = thisConfig.split('.')[0];
        final shortname = thisConfig.substring(servicename.length+1, 25);
        encryptedConfig = '$shortname...';
        service = servicename==''?'Нет названия сервиса':servicename;
        id = i;
      });

      return 1;
    }
    catch (exception){
      return 0;
    }
  }

  void nextConfig() async{
    trueConfig();
    await psswdConfigs(id+1);
  }
  void prevConfig() async{
    trueConfig();
    await psswdConfigs(id-1);
  }
  void trueConfig() async{
    await psswdConfigs(id);
  }

  void copyPsswd() async{
    final psswd = await getPsswd(id);
    if (psswd == 'Error'){
      showDialogWindow1('Ошибка!', 'Неверный пароль или же конфиг. Попробуйте поменять ключ на странице "Генератор"', context);
    }
    else{
    Clipboard.setData(ClipboardData(text:psswd));
    showDialogWindow1('Скопировано', 'Пароль скопирован в буфер обмена', context);
    }
  }
  void copySecret() async{
    Clipboard.setData(ClipboardData(text:thisConfig));
    showDialogWindow1('Скопировано', 'Шифр скопирован в буфер обмена', context);
  }
  void copyEncryptedConfig(){
    showDialogWindow2(
      'Скопировать', 
      'Вы хотите скопировать шифр или пароль?', 
      context, 
      'Пароль', 
      copyPsswd, 
      'Шифр', 
      copySecret
    );
  }

  Future<void> deleteConfig() async{
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Удалить'),
        content: Text('Вы точно хотите удалить выбранный конфиг?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Да'),
            onPressed: () async{
              Navigator.of(context, rootNavigator: true).pop();
              await removeConfig(keyConfig, id);

              nextConfig();
              prevConfig();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Нет'),
            onPressed: () async{
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold (
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Хранилище ваших паролей'),
      ),
      child: Center(
        child: ListView(
          padding: setPadding(),
          children: [
            buildCopyOnTap('Конфиг генерации пароля', encryptedConfig, copyEncryptedConfig),
            SizedBox(height: 48),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: buildButton('<', prevConfig)
                ),

                const SizedBox(width: 64),

                Text('${id+1}/$configs'),

                const SizedBox(width: 64),
                Center(
                  child: buildButton('>', nextConfig)
                ),
              ]
            ),

            SizedBox(height: 48),
            Center(
              child: Text(service),
            ),

            SizedBox(height: 48),

            buildButton('Удалить', deleteConfig),
          ]
        ),
      ),
    );
  }

}


