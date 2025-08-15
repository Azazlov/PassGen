import 'package:shared_preferences/shared_preferences.dart';

// Сохранение данных
Future<void> saveConfig(String key, List<String> value) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList(key, value);
}

// Чтение данных
Future<List<String>> getConfig(String key) async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getStringList(key) ?? ['', '', ''];  
}

// Удаление данных
Future<void> removeConfigs() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('configs');
}