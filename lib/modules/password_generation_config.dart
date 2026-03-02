import 'dart:convert';
import 'dart:core';
import 'package:uuid/uuid.dart';
import 'shared.dart';

// Объект зашифрованного конфига генерации пароля
class PasswordGenerationConfig{
  late int version;
  late String service;
  late dynamic lastUsageDate;
  late String uuid;
  late String category;
  late int expireDays;
  late String encr;

  // Генератор конфига с инициализацией UUID при создании объекта
  PasswordGenerationConfig(
    {
      this.version = 0,
      this.service = 'None',
      this.lastUsageDate = '',
      this.uuid = '',
      this.category = 'None',
      this.expireDays = 30,
      required this.encr
    }
  ){
    uuid = Uuid().v8();
  }

  // Минификация конфига
  String configToBase64Mini(){
    dynamic lud = lastUsageDate.isEmpty? 'Not used': _minificateDate(lastUsageDate);
    String splitedParams = '$version.${encodeBase64(service)}.$lud.$uuid.$category.$expireDays';
    String miniConfig = '${encodeBase64(splitedParams)}.$encr';
    return miniConfig;
  }

  // Восстановление объекта из минифицированного конфига
  PasswordGenerationConfig fromBase64MiniToConfig(String miniConfig){
    // параметры.зашифрованный_конфиг -> [параметры, зашифрованный_конфиг]
    String splitedParams = decodeBase64(miniConfig.split('.')[0]);
    List<String> params = splitedParams.split('.');
    String encrypted = miniConfig.split('.')[1];
    // генерация конфига по декодированными параметрам и зашифрованному конфигу
    PasswordGenerationConfig config = PasswordGenerationConfig(
      version: int.parse(params[0]),
      service: decodeBase64(params[1]),
      lastUsageDate: params[2],
      uuid: params[3],
      category: params[4],
      expireDays: int.parse(params[5]),  
      encr: encrypted
    );
    return config;
  }

  // Получить конфиг генерации в виде JSON
  String configToJSON(){
    // Создание словаря параметров
    Map<String, dynamic> configMap = {
      'version': version,
      'service': service,
      'lastUsageDate': lastUsageDate.toString(),
      'uuid': uuid,
      'category': category,
      'expireDays': expireDays,
      'encr': encr
    };
    // Кодирование словаря в JSON-строку
    String configJSON = jsonEncode(configMap);
    return configJSON;
  }

  // Вычисляет просрочен ли пароль
  bool isExpired(){
    bool isEx = getDateFromUUID().isAfter(
      DateTime.now().add(
        Duration(
          days: expireDays
        )
      )
    );
    return isEx;
  }

  // Обновляет время последнего использования пароля у объекта
  void upToDateLUD(){
    lastUsageDate = DateTime.timestamp();
  }

  // Обновляет информацию об UUID устройства
  void upToDateUUID(){
    uuid = Uuid().v8();
  }

  // Получение даты генерации из UUID
  DateTime getDateFromUUID(){
    DateTime date = DateTime(
      int.parse(uuid.substring(0, 4)),
      int.parse(uuid.substring(4, 6)),
      int.parse(uuid.substring(6, 8)),
      int.parse(uuid.substring(9, 11)),
      int.parse(uuid.substring(11, 13)),
      int.parse(uuid.substring(16, 18)),
      int.parse(uuid.substring(20, 23))
    );

    return date;
  }

  // минифицировать дату
  String _minificateDate(dynamic nowDate){
    return '${nowDate.year.toString()}${nowDate.month.toString().padLeft(2, '0')}${nowDate.day.toString().padLeft(2, '0')}${nowDate.hour.toString().padLeft(2, '0')}${nowDate.minute.toString().padLeft(2, '0')}${nowDate.second.toString().padLeft(2, '0')}';
  }
}

void main(){
  // Example usage of PasswordGenerationConfig
  PasswordGenerationConfig config = PasswordGenerationConfig(
    version: 1,
    service: "Example Service",
    lastUsageDate: DateTime.now(),
    category: "Personal",
    expireDays: 30,
    encr: "encrypted_data_here"
  );
  String miniConfig = config.configToBase64Mini();
  print("Mini Config: $miniConfig");
}