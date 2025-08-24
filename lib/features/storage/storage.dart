// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pass_gen/features/storage/storage_service.dart';
import 'package:pass_gen/features/passwordGenerator/psswd_gen_interface.dart';
import 'package:pass_gen/features/storage/storage_interface.dart';
import 'package:pass_gen/shared/dialog.dart';
import 'package:pass_gen/shared/interface.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

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
    final listConfigs = await getConfigs(keyConfig);
    if (listConfigs == null){
      return 0;
    }
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

  void saveConfigs(){
    showDialogWindow2(
      'Сохранить', 
      'Скопировать в буфер или сохранить файлом?', 
      context, 
      'Буфер', 
      saveJSON, 
      'Файл', 
      saveFile
    );
  }
  void saveJSON() async{
    final configs = await getConfigs(keyConfig);
    if (configs == null){
      showDialogWindow1('Ошибка', 'Хранилище пустое', context);
      return;
    }
    String json = jsonEncode(configs);
    Clipboard.setData(ClipboardData(text: json));
    showDialogWindow1('Сохранено', 'Скопировано в буфер обмена', context);
  }
  void saveFile() async{
    try{
      List<String> configs = await getConfigs(keyConfig);
      String json = jsonEncode(configs);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/psswdConfigs.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile('${directory.path}/psswdConfigs.json')]
      );
    }
    catch (e){
      showDialogWindow1('Ошибка', '$e', context);
    }
  }
  void recoveryFile() async {
  try {
  // 1. Открываем диалог выбора файла
  final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['json'],
  dialogTitle: 'Выберите файл конфигураций',
  withData: true
  );

  // 2. Пользователь отменил выбор
  if (result == null || result.files.isEmpty) {
    showDialogWindow1('Ошибка', 'Файл не выбран', context);
  return;
  }

  // 3. Берём первый файл
  final file = result.files.first;

  // 4. Читаем содержимое как строку
  final String jsonString = utf8.decode(file.bytes as List<int>);

  // 5. Парсим JSON
  final List<dynamic> decoded = jsonDecode(jsonString);

    // 6. Проверяем, что это список строк
  if (decoded.every((e) => e is String)) {
    final List<String> configs = decoded.cast<String>();
    
    // ✅ Успешно импортировано!
    showDialogWindow1('Импортировано', 'Успешно импортировано ${configs.length} конфигураций', context);
    saveConfig(keyConfig, configs);
    nextConfig();
    prevConfig();
  } else {
    showDialogWindow1('Ошибка', 'Файл содержит не только строки', context);
  }
  } catch (e) {
    showDialogWindow1('Ошибка', 'При импорте файла произошла ошибка', context);
  }
  }

  void recoveryConfigs(){
    showDialogWindow2(
      'Восстановить', 
      'Взять из буфера обмена или файла?', 
      context, 
      'Буфер', 
      recoveryJSON, 
      'Файл', 
      recoveryFile
    );
  }
  void recoveryJSON() async{
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    try{
      if (clip == null || clip.text == null){
        showDialogWindow1('Буфер обмена пуст', 'ОК', context);
        return;
      }
      else{
        final clipText = clip.text;
        List<String> configs = (jsonDecode(clipText!) as List).cast<String>();
        saveConfig(keyConfig, configs);
        nextConfig();
        prevConfig();
        showDialogWindow1('Импортировано', 'Успешно импортировано ${configs.length} конфигураций', context);
      }
    }
    on Exception{
      showDialogWindow1('Ошибка', 'Неправильный конфиг или не конфиг вовсе', context);
    }
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
              try{
                await removeConfig(keyConfig, id);
                nextConfig();
                prevConfig();
              }
              catch (e){
                showDialogWindow1('Ошибка', 'Хранилище пустое', context);
              }
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

            SizedBox(height: 32),

            buildButton('Удалить', deleteConfig),

            SizedBox(height: 48),
            buildButton('Сохранить', saveConfigs),

            SizedBox(height: 48),
            buildButton('Восстановить', recoveryConfigs),

          ]
        ),
      ),
    );
  }

}


