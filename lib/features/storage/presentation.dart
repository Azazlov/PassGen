// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_gen/features/passwordGenerator/logic.dart';
import 'package:pass_gen/features/storage/database_service.dart';
import 'package:pass_gen/shared/dialogs.dart';
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
  int cfgsLen = 0;

  int id = 0;
  late PasswordGenerationInterface generator;

  final DatabaseService _dbService = DatabaseService.instance;
  List<Map<String, dynamic>> _configs = [];
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState(){
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() => _isLoading = true);
    try {
      _configs = await _dbService.getAllConfigs();
      _selectedIndex = 0;
      _updateSelectedConfig();
    } catch (e) {
      _configs = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateSelectedConfig() {
    if (_configs.isEmpty) {
      setState(() {
        encryptedConfig = 'Нет конфигов';
        service = 'Нет названия сервиса';
        thisConfig = '';
        cfgsLen = 0;
      });
      return;
    }

    if (_selectedIndex >= _configs.length) {
      _selectedIndex = _configs.length - 1;
    }

    final config = _configs[_selectedIndex];
    setState(() {
      cfgsLen = _configs.length;
      service = config['service'] ?? 'Нет названия сервиса';
      thisConfig = config['encr'] ?? '';
      encryptedConfig = '${service.substring(0, service.length > 25 ? 25 : service.length)}...';
      id = _selectedIndex;
    });
  }

  void nextConfig() {
    if (_selectedIndex < _configs.length - 1) {
      setState(() => _selectedIndex++);
      _updateSelectedConfig();
    }
  }

  void prevConfig() {
    if (_selectedIndex > 0) {
      setState(() => _selectedIndex--);
      _updateSelectedConfig();
    }
  }

  void trueConfig() {
    _updateSelectedConfig();
  }

  void selectConfig(int index) {
    setState(() => _selectedIndex = index);
    _updateSelectedConfig();
  }

  void copyPsswd() async{
    if (_configs.isEmpty) {
      showDialogWindow1('Ошибка', 'Хранилище пустое', context);
      return;
    }
    try{
      final config = _configs[_selectedIndex];
      final psswd = config['password'] ?? '';
      Clipboard.setData(ClipboardData(text:psswd));
      showDialogWindow1('Скопировано', 'Пароль скопирован в буфер обмена', context);
    }
    catch (e){
      showDialogWindow1('Ошибка!', 'Неверный пароль или же конфиг. Попробуйте поменять ключ на странице "Генератор"', context);
    }
  }
  void copySecret() async{
    if (_configs.isEmpty) {
      showDialogWindow1('Ошибка', 'Хранилище пустое', context);
      return;
    }
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
    if (_configs.isEmpty){
      showDialogWindow1('Ошибка', 'Хранилище пустое', context);
      return;
    }
    final configsToExport = _configs.map((config) => {
      'version': config['version'],
      'service': config['service'],
      'lastUsageDate': config['lastUsageDate'],
      'uuid': config['uuid'],
      'category': config['category'],
      'expireDays': config['expireDays'],
      'encr': config['encr'],
      'password': config['password'],
      'strength': config['strength'],
      'config': config['config'],
    }).toList();
    String json = jsonEncode(configsToExport);
    Clipboard.setData(ClipboardData(text: json));
    showDialogWindow1('Сохранено', 'Скопировано в буфер обмена', context);
  }

  void saveFile() async{
    try{
      if (_configs.isEmpty){
        showDialogWindow1('Ошибка', 'Хранилище пустое', context);
        return;
      }
      final configsToExport = _configs.map((config) => {
        'version': config['version'],
        'service': config['service'],
        'lastUsageDate': config['lastUsageDate'],
        'uuid': config['uuid'],
        'category': config['category'],
        'expireDays': config['expireDays'],
        'encr': config['encr'],
        'password': config['password'],
        'strength': config['strength'],
        'config': config['config'],
      }).toList();
      String json = jsonEncode(configsToExport);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/psswdConfigs.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)]);
    }
    catch (e){
      showDialogWindow1('Ошибка', '$e', context);
    }
  }

  String newMethod(Directory directory) => directory.path;

  Future<void> recoveryFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Выберите файл конфигураций',
        withData: true
      );

      if (result == null || result.files.isEmpty) {
        showDialogWindow1('Ошибка', 'Файл не выбран', context);
        return;
      }

      final file = result.files.first;
      final String jsonString = utf8.decode(file.bytes as List<int>);
      final List<dynamic> decoded = jsonDecode(jsonString);

      if (decoded.every((e) => e is Map)) {
        for (var configMap in decoded) {
          if (configMap is Map) {
            await _dbService.savePasswordConfig({
              'version': configMap['version'] ?? 0,
              'service': configMap['service'] ?? 'None',
              'lastUsageDate': configMap['lastUsageDate'] ?? '',
              'uuid': configMap['uuid'] ?? '',
              'category': configMap['category'] ?? 'None',
              'expireDays': configMap['expireDays'] ?? 30,
              'encr': configMap['encr'] ?? '',
              'password': configMap['password'] ?? '',
              'strength': configMap['strength'] ?? '',
              'config': configMap['config'] ?? '',
              'createdAt': DateTime.now().toIso8601String(),
            });
          }
        }
        await _loadConfigs();
        showDialogWindow1('Импортировано', 'Успешно импортировано ${decoded.length} конфигураций', context);
      } else {
        showDialogWindow1('Ошибка', 'Файл содержит некорректные данные', context);
      }
    } catch (e) {
      showDialogWindow1('Ошибка', 'При импорте файла произошла ошибка: $e', context);
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

  Future<void> recoveryJSON() async{
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    try{
      if (clip == null || clip.text == null){
        showDialogWindow1('Буфер обмена пуст', 'ОК', context);
        return;
      }
      final clipText = clip.text;
      final List<dynamic> decoded = jsonDecode(clipText!);

      if (decoded.every((e) => e is Map)) {
        for (var configMap in decoded) {
          if (configMap is Map) {
            await _dbService.savePasswordConfig({
              'version': configMap['version'] ?? 0,
              'service': configMap['service'] ?? 'None',
              'lastUsageDate': configMap['lastUsageDate'] ?? '',
              'uuid': configMap['uuid'] ?? '',
              'category': configMap['category'] ?? 'None',
              'expireDays': configMap['expireDays'] ?? 30,
              'encr': configMap['encr'] ?? '',
              'password': configMap['password'] ?? '',
              'strength': configMap['strength'] ?? '',
              'config': configMap['config'] ?? '',
              'createdAt': DateTime.now().toIso8601String(),
            });
          }
        }
        await _loadConfigs();
        showDialogWindow1('Импортировано', 'Успешно импортировано ${decoded.length} конфигураций', context);
      } else {
        showDialogWindow1('Ошибка', 'Неправильный формат данных', context);
      }
    }
    on Exception{
      showDialogWindow1('Ошибка', 'Неправильный конфиг или не конфиг вовсе', context);
    }
  }

  Future<void> deleteConfig() async{
    if (_configs.isEmpty) {
      showDialogWindow1('Ошибка', 'Хранилище пустое', context);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить'),
        content: Text('Вы точно хотите удалить выбранный конфиг?'),
        actions: [
            TextButton(
            child: Text('Да'),
            onPressed: () async{
              Navigator.of(context, rootNavigator: true).pop();
              try{
                final config = _configs[_selectedIndex];
                final uuid = config['uuid'];
                await _dbService.deleteConfig(uuid);
                await _loadConfigs();
              }
              catch (exception){
                showDialogWindow1('Ошибка', 'Хранилище пустое', context);
              }
            },
          ),
            TextButton(
            child: Text('Нет'),
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
    return Scaffold (
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _configs.isEmpty
                ? ListView(
                    padding: setPadding(),
                    children: [
                      SizedBox(height: 48),
                      const Center(
                        child: Text(
                          'Хранилище пусто',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 32),
                      Center(
                        child: Text(
                          'Сгенерируйте пароль на странице "Генератор"\nи он автоматически сохранится в хранилище',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: setPadding(),
                    children: [
                      SizedBox(height: 48),

                      Center(
                        child: Text(
                          'Хранилище паролей',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _selectedIndex > 0 ? prevConfig : null,
                            iconSize: 32,
                          ),

                          const SizedBox(width: 16),

                          Text(
                            '${_selectedIndex + 1}/$cfgsLen',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(width: 16),

                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _selectedIndex < cfgsLen - 1 ? nextConfig : null,
                            iconSize: 32,
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      Card(
                        elevation: 4,
                        child: ListTile(
                          leading: const Icon(Icons.folder, size: 40),
                          title: Text(
                            service,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Пароль: ${_configs[_selectedIndex]['password'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: copyPsswd,
                        ),
                      ),

                      SizedBox(height: 24),

                      ExpansionTile(
                        title: const Text('Детали конфига'),
                        children: [
                          ListTile(
                            title: Text('UUID: ${_configs[_selectedIndex]['uuid'] ?? 'N/A'}'),
                            subtitle: const Text('Нажмите, чтобы скопировать', style: TextStyle(fontSize: 12)),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: _configs[_selectedIndex]['uuid'] ?? ''));
                              showDialogWindow1('Скопировано', 'UUID скопирован в буфер обмена', context);
                            },
                          ),
                          ListTile(
                            title: Text('Категория: ${_configs[_selectedIndex]['category'] ?? 'N/A'}'),
                          ),
                          ListTile(
                            title: Text('Срок действия: ${_configs[_selectedIndex]['expireDays'] ?? 'N/A'} дн.'),
                          ),
                          ListTile(
                            title: Text('Версия: ${_configs[_selectedIndex]['version'] ?? 'N/A'}'),
                          ),
                          ListTile(
                            title: Text('Сложность: ${_configs[_selectedIndex]['strength'] ?? 'N/A'}'),
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: copyPsswd,
                            icon: const Icon(Icons.copy),
                            label: const Text('Копировать пароль'),
                          ),
                          ElevatedButton.icon(
                            onPressed: copySecret,
                            icon: const Icon(Icons.lock),
                            label: const Text('Копировать шифр'),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: saveConfigs,
                            icon: const Icon(Icons.save),
                            label: const Text('Сохранить'),
                          ),
                          ElevatedButton.icon(
                            onPressed: recoveryConfigs,
                            icon: const Icon(Icons.restore),
                            label: const Text('Восстановить'),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: deleteConfig,
                        icon: const Icon(Icons.delete, color: Colors.white),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        label: const Text('Удалить конфиг', style: TextStyle(color: Colors.white)),
                      ),

                      SizedBox(height: 48),
                    ],
                  ),
      ),
    );
  }

}


