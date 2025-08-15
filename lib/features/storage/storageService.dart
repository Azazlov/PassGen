import 'package:shared_preferences/shared_preferences.dart';

// Сохранение данных
Future<void> saveConfig(List<String> value) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('configs', value);
}

// Чтение данных
Future<dynamic> getConfig() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getStringList('configs');  
}

// Удаление данных
Future<void> removeConfigs() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('configs');
}

void lol() async {
  // await saveConfig(await getConfig()+['Hellor']);
  // await removeConfigs();

  print(await getConfig());
}