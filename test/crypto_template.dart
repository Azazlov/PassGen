// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:core';
import 'package:uuid/uuid.dart';
// import 'package:crypto/crypto.dart';
import 'dart:typed_data';

void main(){
  String newConfig = getConfig();
  print(newConfig);
  Map<String, String> decodedConfig = decodeConfig(newConfig);
  print(decodedConfig);
}

String getConfig(){
  Map<String, String> confTemp = {
    'Version': '1.0', 
    'Service':encodeBase64('apple'), 
    'Last time usage':minificateDate(DateTime.now()), 
    'UUID':Uuid().v8(), 
    'Category':'category', 
    'Ex':'50', 
    'Encr':'мегашифр'
  };
  String confString = '';
  confTemp.forEach((key, value) => key!='ШИФР'? confString += '$value ': confString += value);
  return encodeBase64(confString);
}

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

String encodeBase64(String text) {
  return base64Encode(utf8.encode(text));
} 

String decodeBase64(String encoded) {
  return utf8.decode(base64Decode(encoded));
}

String minificateDate(dynamic nowDate){
  return '${nowDate.year.toString()}${nowDate.month.toString().padLeft(2, '0')}${nowDate.day.toString().padLeft(2, '0')}${nowDate.hour.toString().padLeft(2, '0')}${nowDate.minute.toString().padLeft(2, '0')}${nowDate.second.toString().padLeft(2, '0')}';
}

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


Uint8List int64ToBytes(int value) {
  var byteData = ByteData(8);
  byteData.setInt64(0, value, Endian.little); 
  
  return byteData.buffer.asUint8List();
}


int isExpired(){
  return 0;
}