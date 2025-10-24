import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'shared.dart';

class EncryptConfig{
  late int version = 0;
  late String service = 'None';
  late dynamic lastUsageDate = false;
  late String uuid = Uuid().v8();
  late String category = 'None';
  late int expireDays = 30;
  late String encr;
  EncryptConfig(
    this.encr, 
    {
      this.service = 'None',
      this.category = 'None',
      this.expireDays = 30
    }
  );

  String getConfigMini(){
    dynamic lud = lastUsageDate == false? 'Not used': minificateDate(lastUsageDate);
    String splitedParams = '$version.${encodeBase64(service)}.$lud.$uuid.$category.$expireDays';
    // print(splitedParams);
    String config = '${encodeBase64(splitedParams)}.$encr';
    return config;
  }

  String getConfigJSON(){
    Map<String, dynamic> configMap = {
      'version': version,
      'service': service,
      'lastUsageDate': lastUsageDate.toString(),
      'uuid': uuid,
      'category': category,
      'expireDays': expireDays,
      'encr': encr
    };
    String configJSON = jsonEncode(configMap);
    return configJSON;
  }

  bool isExpired(){
    bool isEx = getDateFromUUID().isAfter(DateTime.now().add(Duration(days: expireDays)));
    return isEx;
  }

  dynamic upToDateLUD(){
    lastUsageDate = DateTime.timestamp();
    return lastUsageDate;
  }

  String upToDateUUID(){
    uuid = Uuid().v8();
    return uuid;
  }

  dynamic getDateFromUUID(){
    dynamic date = DateTime(
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
}

// void testCrypto(){
//   String newConfig = getConfig();
  
//   Map<String, String> decodedConfig = decodeConfig(newConfig);
  
//   print(newConfig);
//   print(decodedConfig);
// }

// // получить пример сида
// String getConfig(){
//   Map<String, String> confTemp = {
//     'Version': '1.0', 
//     'Service':encodeBase64('apple'), 
//     'Last time usage':minificateDate(DateTime.now()), 
//     'UUID':Uuid().v8(), 
//     'Category':'category', 
//     'Ex':'50', 
//     'Encr':'мегашифр'
//   };
//   String confString = '';
//   confTemp.forEach((key, value) => key!='ШИФР'? confString += '$value ': confString += value);
//   return encodeBase64(confString);
// }

// декодировать пример сида
Map<String, String> decodeConfig(String configB64){
  String config = decodeBase64(configB64);
  List<String> configElements = config.split(' ');

  print(configElements);
  
  Map<String, String> configMap = {
    'Vers':configElements[0], 
    'LUT':configElements[2], 
    'UUID':configElements[3], 
    'Cat':configElements[4], 
    'ET':configElements[5], 
    'Encr':configElements[6]
  };
  // String configDecoded = '';
  // configMap.forEach((key, value) => configDecoded += '$key: $value\n');

  return configMap;
}

// минифицировать дату
String minificateDate(dynamic nowDate){
  return '${nowDate.year.toString()}${nowDate.month.toString().padLeft(2, '0')}${nowDate.day.toString().padLeft(2, '0')}${nowDate.hour.toString().padLeft(2, '0')}${nowDate.minute.toString().padLeft(2, '0')}${nowDate.second.toString().padLeft(2, '0')}';
}

// восстановить минифицированную дату
dynamic deMinificateDate(String miniDate){
  Map date= {
  'year': miniDate.substring(0, 4), 
  'month': miniDate.substring(4, 6), 
  'day': miniDate.substring(6, 8), 
  'hour': miniDate.substring(8, 10),
  'minute': miniDate.substring(10, 12),
  'second': miniDate.substring(12, 14),
  };
  return DateTime(
      int.parse(date['year']), 
      int.parse(date['month']),
      int.parse(date['day']),
      int.parse(date['hour']),
      int.parse(date['minute']),
      int.parse(date['second'])
    );
}

// преобразовать большое число в массив байтов (8 байтов)
Uint8List int64ToBytes(int value) {
  var byteData = ByteData(8);
  byteData.setInt64(0, value, Endian.little); 
  
  return byteData.buffer.asUint8List();
}