// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:core';
import 'package:uuid/uuid.dart';
// import 'package:crypto/crypto.dart';
import 'dart:typed_data';

void main(){
  print(DateTime.now().millisecondsSinceEpoch);
  print(int64ToBytes(256));
  final template = 'версия.сервис.время_последнего_использования.uuid.категория.срок_действия.ШИФР';

  List<String> confTemp = [
    '1.0', 
    'apple', 
    minificateDate(DateTime.now()), 
    Uuid().v8(), 'category', 
    '50', 
    'мегашифр'
  ];

  String config = '';
  int fall = 0;

  for (int i = 0; i < template.split('.').length; i++){
    print('-----\n${template.split('.')[i]}: ${confTemp[i]}');
    if (i < template.split('.').length-1){
      config += confTemp[i];
    }
    fall = i;
  }
  config = '${encodeBase64(config)}.${confTemp[fall]}';

  print(config);
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

String generateUUID() {
  return Uuid().v4();
}