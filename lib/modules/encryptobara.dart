import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';

Uint8List random({int len = 0x10}){
  final random = Random.secure();
  final bytesList = Uint8List(len);

  for (int i=0; i<bytesList.length; i++){
    bytesList[i] = random.nextInt(0x100);
  }

  return bytesList;
}

Uint8List encrypt(Uint8List data, Uint8List key, {int byteLength = 0x10}){

  Uint8List hashKey = Uint8List.fromList(sha256.convert(key).bytes);
  // print(bytesToRad(hashKey, 16));
  
  int lenkey = hashKey.length;
  Uint8List salt = random(len: byteLength);
  Uint8List iv = random(len: byteLength);

  Uint8List newData = Uint8List(data.length);
  // ignore: non_constant_identifier_names
  int ASCII = 256;

  for (int i=0; i<data.length; i++){
    // print('---$i---\n${data[i]}\n${hashKey[i%lenkey]}\n${salt[i%byteLength]}\n${iv[i%byteLength]}\n$ASCII\n---$i---');
    newData[i] = (data[i]^(hashKey[i%lenkey]^salt[i%byteLength]^iv[i%byteLength])%ASCII);
  }
  
  final secret = BytesBuilder();
  secret.add(salt);
  secret.add(iv);
  secret.add(newData);
  // secret.add(hashKey);
  // print(secret.toBytes());
  final encr = BytesBuilder();
  encr.add(secret.toBytes());
  Uint8List hashSecret = Uint8List.fromList(sha256.convert(secret.toBytes()).bytes);
  encr.add(hashSecret);
  // print('==================SECRET==================');
  // print('salt: ${base64Encode(salt)}\niv: ${base64Encode(iv)}\nnewData: ${base64Encode(newData)}\nhashKey: ${base64Encode(hashKey)}\nhashSecret: ${base64Encode(hashSecret)}');
  if (base64Encode(decrypt(encr.toBytes(), key)) == base64Encode(data)){
    return encr.toBytes();
  }

 throw Exception('Ошибка кодирования');
}

Uint8List decrypt(Uint8List data, Uint8List key, {int byteLength = 0x10}){

  key = Uint8List.fromList(sha256.convert(key).bytes);
  int lenkey = key.length;
  // print('\n==================CRYPTO==================');
  // print('data: ${base64Encode(data)}');
  // print(data);
  Uint8List salt = Uint8List(byteLength);

  // print('$salt, $data');
  for (int i=0; i<salt.length; i++){
    salt[i] = data[i];
  }
  // print('salt: ${base64Encode(salt)}');
  
  Uint8List iv = Uint8List(16);
  for (int i=0; i<iv.length; i++){
    iv[i] = data[(i+byteLength)];
  }
  // print('iv: ${base64Encode(iv)}');

  Uint8List hashData = Uint8List(32);
  for (int i=0; i<32; i++){
    hashData[i] = data[data.length-32+i];
  }

  Uint8List newData = Uint8List(data.length-byteLength*2-32);
  for (int i=0; i<data.length-byteLength*2-32; i++){
    newData[i] = data[i+32];
  }
  // print('newData: ${base64Encode(newData)}');
  // print('hashKey: ${base64Encode(key)}');
  // print('hashData: ${base64Encode(hashData)}');
  // print(hashData);

  final secret = BytesBuilder();
  secret.add(salt);
  secret.add(iv);
  secret.add(newData);
  // print('secret: ${base64Encode(Uint8List.fromList(sha256.convert(secret.toBytes()).bytes))}');
  // print(Uint8List.fromList(sha256.convert(secret.toBytes()).bytes));

  if (base64Encode(Uint8List.fromList(sha256.convert(secret.toBytes()).bytes))!=base64Encode(hashData)){
    throw Exception('Ошибка целостности');
  }

  // ignore: non_constant_identifier_names
  int ASCII = 256;
  data = newData;
  for (int i=0; i<data.length; i++){
    newData[i] = (data[i]^(key[i%lenkey]^salt[i%byteLength]^iv[i%byteLength])%ASCII);
  }
  return newData;
}

// void main(){
//   String data = '1234';
//   String key = '1234';
//   String encryptData = base64Encode(encrypt(utf8.encode(data), utf8.encode(key))) ;
//   // print(encryptData);
// }