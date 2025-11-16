import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class HashGenerator{
  late List<int> algorithmConfig;
  HashGenerator({required HashStrength strength}){
    // Конфигурация на основании сложности генерации хэша

    List<List<int>> algorithmConfigs = [
      // Кол-во потоков, требуемая память, кол-во итераций, длина хэша
      [1, 4096, 1, 16],
      [2, 12000, 2, 32],
      [1, 32768, 3, 32]
    ];

    algorithmConfig = 
      strength == HashStrength.high? algorithmConfigs[0]: // Медленно, безопасно
      strength == HashStrength.medium? algorithmConfigs[1]: // Средне
      strength == HashStrength.low? algorithmConfigs[2]: // Быстро, ненадежно
      [];
  }

  Future<String> getHash({required String hashedPassword, required String salt}) async{
    Argon2id algorithm = Argon2id(
      parallelism: algorithmConfig[0], // потоки
      memory: algorithmConfig[1],  // память
      iterations: algorithmConfig[2], // итерации
      hashLength: algorithmConfig[3] // длина хэша
    );
    
    SecretKey newSecretKey = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(hashedPassword)), 
      nonce: utf8.encode(salt)
    );

    List<int> newSecretKeyBytes = await newSecretKey.extractBytes();

    return base64Encode(newSecretKeyBytes);
  }
}

enum HashStrength{
  low,
  medium,
  high
}

Future<List<int>> getPsswd({
  required String masterPsswd
}) async{
  List<int> message = utf8.encode('Hello, World!');

  Chacha20 algorithm = Chacha20.poly1305Aead();
  SecretKey secretKey = await algorithm.newSecretKey();

  SecretBox secretBox = await algorithm.encrypt(
    message,
    secretKey: secretKey,
  );
  print('Nonce: ${base64Encode(secretBox.nonce)}');
  print('Ciphertext: ${base64Encode(secretBox.cipherText)}');
  print('MAC: ${base64Encode(secretBox.mac.bytes)}');

  // Decrypt
  List<int> clearText = await algorithm.decrypt(
    secretBox,
    secretKey: secretKey,
  );
  print('Cleartext: ${utf8.decode(clearText)}');

  return clearText;
}