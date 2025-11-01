import 'dart:convert';
import 'dart:core';
import 'package:uuid/uuid.dart';
import 'shared.dart';

class EncryptedConfig{
  late int version;
  late String service;
  late dynamic lastUsageDate;
  late String uuid;
  late String category;
  late int expireDays;
  late String encr;
  EncryptedConfig(
    {
      this.version = 0,
      this.service = 'None',
      this.lastUsageDate = false,
      this.uuid = '',
      this.category = 'None',
      this.expireDays = 30,
      this.encr = 'Test'
    }
  ){
    uuid = Uuid().v8();
  }

  String getConfigMini(){
    dynamic lud = lastUsageDate == false? 'Not used': _minificateDate(lastUsageDate);
    String splitedParams = '$version.${encodeBase64(service)}.$lud.$uuid.$category.$expireDays';
    // print(splitedParams);
    String miniConfig = '${encodeBase64(splitedParams)}.$encr';
    return miniConfig;
  }

  EncryptedConfig getConfigFromMini(String miniConfig){
    String splitedParams = decodeBase64(miniConfig.split('.')[0]);
    List<String> params = splitedParams.split('.');
    String encrypted = miniConfig.split('.')[1];
    EncryptedConfig config = EncryptedConfig(
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

  // минифицировать дату
  String _minificateDate(dynamic nowDate){
    return '${nowDate.year.toString()}${nowDate.month.toString().padLeft(2, '0')}${nowDate.day.toString().padLeft(2, '0')}${nowDate.hour.toString().padLeft(2, '0')}${nowDate.minute.toString().padLeft(2, '0')}${nowDate.second.toString().padLeft(2, '0')}';
  }
}

// // преобразовать большое число в массив байтов (8 байтов)
// Uint8List int64ToBytes(int value) {
//   var byteData = ByteData(8);
//   byteData.setInt64(0, value, Endian.little); 
  
//   return byteData.buffer.asUint8List();
// }