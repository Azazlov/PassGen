import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/src/sha256.dart' as crypto;
import 'package:secure_pass/modules/psswdGen.dart';

String getDeterministicAlphabet(Uint8List basecode, key) {
  // Создание полного алфавита
  List<int> az = List<int>.generate(256, (i) => i);

  // "master" строка
  final master = utf8.encode(getPsswd(key, 'crypto-encrypto-service', 64, true, true, true, true, true, true));

  // Хешируем master
  final masterHash = sha256(master);
  final masterSeed = bytesToSeed(masterHash);

  // Хешируем basecode
  final baseHash = sha256(basecode);
  final baseSeed = bytesToSeed(baseHash);

  // Перемешиваем с master seed
  az.shuffle(Random(masterSeed));
  // Перемешиваем с basecode seed
  az.shuffle(Random(baseSeed));

  // Преобразуем в строку
  return String.fromCharCodes(az);
}

String encrypt(String msg, String key) {
  final basecodeBytes = utf8.encode(key);
  final alphabet = getDeterministicAlphabet(Uint8List.fromList(basecodeBytes), key);
  final msgBytes = utf8.encode(msg);

  final encrypted = msgBytes.map((b) => alphabet.codeUnitAt(b)).toList();
  final encryptedLatin1 = Uint8List.fromList(encrypted);

  return base64.encode(encryptedLatin1);
}

String decrypt(String encoded, String key) {
  final basecodeBytes = utf8.encode(key);
  final alphabet = getDeterministicAlphabet(Uint8List.fromList(basecodeBytes), key);

  final reverseMap = <int, int>{
    for (int i = 0; i < alphabet.length; i++) alphabet.codeUnitAt(i): i
  };

  final encryptedBytes = base64.decode(encoded);
  final decryptedBytes = encryptedBytes.map((c) => reverseMap[c]!).toList();

  return utf8.decode(decryptedBytes, allowMalformed: true);
}

// ======== Вспомогательные функции ========

/// Простой SHA-256 на bytes
Uint8List sha256(List<int> data) {
  // Можно использовать crypto из pub.dev: `crypto: ^3.0.3`
  return Uint8List.fromList(crypto.sha256.convert(data).bytes);
}

/// Преобразует 32 байта (SHA-256) в seed типа int
int bytesToSeed(Uint8List bytes) {
  int seed = 0;
  for (int i = 0; i < 8; i++) {
    seed = (seed << 8) | bytes[i];
  }
  return seed;
}
