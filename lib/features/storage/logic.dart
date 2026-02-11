// ignore_for_file: strict_top_level_inference

import 'package:shared_preferences/shared_preferences.dart';

// Сохранение данных
Future<void> saveConfig(String key, List<String> value) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList(key, value);
}

Future<String> getPsswd(int id) async{
  await Future.delayed(Duration(seconds: 0));
  return '';
}

// Чтение данных
Future<dynamic> getConfigs(String key) async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getStringList(key);  
}

// Удаление данных
Future<void> removeConfigs(key) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove(key);
}

Future<void> removeConfig(key, id) async{
  final configs = await getConfigs(key);
  final List<String> newConfigs = [];

  for (int i = 0; i < configs.length; i++){
    i==id?i:newConfigs.add(configs[i]);
  }
  await removeConfigs(key);
  saveConfig(key, newConfigs);
  return;
}
