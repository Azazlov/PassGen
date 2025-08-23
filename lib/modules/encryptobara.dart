import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

String bytesToRad(Uint8List bytes, int rad){
  return bytes.map((b) => b.toRadixString(rad).padLeft(2, '0')).join('');
}

Uint8List radToBytes(String str, int rad) {
  if (str.length % 2 != 0) {
    throw FormatException('Длина строки должна быть кратна 2, так как каждый байт кодируется 2 символами');
  }

  final List<int> bytes = [];
  for (int i = 0; i < str.length; i += 2) {
    final String byteStr = str.substring(i, i + 2);
    final int byte = int.parse(byteStr, radix: rad);
    if (byte < 0 || byte > 255) {
      throw FormatException('Некорректное значение байта: $byte из "$byteStr" при rad=$rad');
    }
    bytes.add(byte);
  }

  return Uint8List.fromList(bytes);
}

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
  secret.add(hashKey);
  // print(secret.toBytes());
  final encr = BytesBuilder();
  encr.add(secret.toBytes());
  Uint8List hashSecret = Uint8List.fromList(sha256.convert(secret.toBytes()).bytes);
  encr.add(hashSecret);
    // print('___ENCRYPT___\nsalt: ${bytesToRad(salt, 16)}\niv: ${bytesToRad(iv, 16)}\nnewData: ${bytesToRad(newData, 16)}\nhashKey: ${bytesToRad(hashKey, 16)}\n\n');
    // print('__ENCRDATA___\nencr: ${bytesToRad(encr.toBytes(), 16)}\n');
    // print('secret: ${bytesToRad(secret.toBytes(), 16)}\nhashSecret: ${bytesToRad(hashSecret, 16)}\n');
  // print('$data $key ${decrypt(encr.toBytes(), key)}');
  if (bytesToRad(decrypt(encr.toBytes(), key), 36) == bytesToRad(data, 36)){
    return encr.toBytes();
  }
  // print(bytesToRad(encr.toBytes(), 0x10));

  // print(lenkey);
  // print(key.toString());
  // print(BigInt.parse(key.toString(), radix: 16).toRadixString(36));
 throw Error();
}

Uint8List decrypt(Uint8List data, Uint8List key, {int byteLength = 0x10}){
  key = Uint8List.fromList(sha256.convert(key).bytes);
  int lenkey = key.length;
  Uint8List salt = Uint8List(16);
  for (int i=0; i<salt.length; i++){
    salt[i] = data[i];
  }
  Uint8List iv = Uint8List(16);
  for (int i=0; i<iv.length; i++){
    iv[i] = data[i+iv.length];
  }
  Uint8List hashData = Uint8List(32);
  for (int i=0; i<32; i++){
    hashData[i] = data[data.length-32+i];
  }
  Uint8List newData = Uint8List(data.length-16-16-64);
  for (int i=0; i<data.length-16-16-64; i++){
    newData[i] = data[i+32];
  }
  final secret = BytesBuilder();
  secret.add(salt);
  secret.add(iv);
  secret.add(newData);
  secret.add(key);
  // print('___DECRYPT___\nsalt: ${bytesToRad(salt, 16)}\niv: ${bytesToRad(iv, 16)}\nnewData: ${bytesToRad(newData, 16)}\nkey: ${bytesToRad(key, 16)}\n\n');
  // print(bytesToRad(secret.toBytes(), 16));

  // print('___DECRYPT___\nsalt: ${bytesToRad(salt, 16)}\niv: ${bytesToRad(iv, 16)}\nnewData: ${bytesToRad(newData, 16)}\nhashKey: ${bytesToRad(key, 16)}\n\n');
  // print('__hash__\n${bytesToRad((Uint8List.fromList(sha256.convert(secret.toBytes()).bytes)), 16)}\n');
  // print('__hashdata__\n${bytesToRad(hashData, 16)}\n');
  // print(bytesToRad((Uint8List.fromList(sha256.convert(secret.toBytes()).bytes)), 16)==bytesToRad(hashData, 16));
  if (bytesToRad((Uint8List.fromList(sha256.convert(secret.toBytes()).bytes)), 16)!=bytesToRad(hashData, 16)){
    throw Exception('Ошибка целостности');
  }

  // ignore: non_constant_identifier_names
  int ASCII = 256;
  data = newData;
  for (int i=0; i<data.length; i++){
    // print('---$i---\n${data[i]}\n${key[i%lenkey]}\n${salt[i%byteLength]}\n${iv[i%byteLength]}\n$ASCII\n---$i---');
    newData[i] = (data[i]^(key[i%lenkey]^salt[i%byteLength]^iv[i%byteLength])%ASCII);
  }
  return newData;
}