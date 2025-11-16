import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:password_strength/password_strength.dart';
import 'package:zxcvbn/zxcvbn.dart';

String passwd = '7[i{n9?)ZC}]';
double strength = estimatePasswordStrength(passwd);
double? score = Zxcvbn().evaluate(passwd).score;

List<int> random({int len = 32}){
  Random random = Random.secure();
  List<int> bytesList = [];

  for (int i = 0; i < len; i++){
    bytesList.add(random.nextInt(255));
  }

  return bytesList;
}

class HashGenerator{
  late List<int> algorithmConfig;
  HashGenerator({required HashStrength strength}){
    // Конфигурация на основании сложности генерации хэша

    List<List<int>> algorithmConfigs = [
      // Кол-во потоков, требуемая память, кол-во итераций, длина хэша
      [1, 4096, 1, 32],
      [2, 12000, 2, 32],
      [1, 32768, 3, 32]
    ];

    algorithmConfig = 
      strength == HashStrength.high? algorithmConfigs[2]: // Медленно, безопасно
      strength == HashStrength.medium? algorithmConfigs[1]: // Средне
      strength == HashStrength.low? algorithmConfigs[0]: // Быстро, ненадежно
      [];
  }

  Future<List<int>> getHash({required List<int> cipherText}) async{
    List<int> salt = random();

    Argon2id algorithm = Argon2id(
      parallelism: algorithmConfig[0], // потоки
      memory: algorithmConfig[1],  // память
      iterations: algorithmConfig[2], // итерации
      hashLength: algorithmConfig[3] // длина хэша
    );
    
    SecretKey newSecretKey = await algorithm.deriveKey(
      secretKey: SecretKey(cipherText), 
      nonce: salt
    );

    List<int> newSecretKeyBytes = await newSecretKey.extractBytes();

    return newSecretKeyBytes;
  }
}

enum HashStrength{
  low,
  medium,
  high
}

Future<String> getPsswd() async{
  print('strength: $strength\nscore: $score');
  List<int> message = utf8.encode('Hello, World!');
  List<int> passwd = utf8.encode('securePasswd');

  Chacha20 algorithm = Chacha20.poly1305Aead();

  List<int> bytes = await HashGenerator(strength: HashStrength.high).getHash(cipherText: passwd);

  SecretKey secretKey = await algorithm.newSecretKeyFromBytes(bytes);

  SecretBox secretBox = await algorithm.encrypt(
    message,
    secretKey: secretKey,
  );

  print('Nonce: ${base64Encode(secretBox.nonce)}');
  print('Ciphertext: ${base64Encode(secretBox.cipherText)}');
  print('MAC: ${base64Encode(secretBox.mac.bytes)}');
  // print('${await secretKey.extractBytes()}');
  // print('${await secretKey.extractBytes()}, ${await (await algorithm.newSecretKeyFromBytes(await secretKey.extractBytes())).extractBytes()}');

  // Decrypt
  List<int> clearText = await algorithm.decrypt(
    secretBox,
    secretKey: secretKey,
  );
  print('Cleartext: ${utf8.decode(clearText)}');

  return '';
}