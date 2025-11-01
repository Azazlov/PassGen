import 'dart:convert';
import 'dart:ffi';
import 'package:cryptography/cryptography.dart';

class HashGenerator{
  late List<int> algorithmConfig;
  HashGenerator({required HashStrength strength}){
    // Конфигурация на основании сложности генерации хэша
    // параллельность, память, итерации, длина хэша
    List<List<int>> algorithmConfigs = [
      [1, 4096, 1, 16],
      [2, 12000, 2, 32],
      [1, 32768, 3, 32]
    ];

    algorithmConfig = 
      strength == HashStrength.high? algorithmConfigs[0]: // Медленно
      strength == HashStrength.medium? algorithmConfigs[1]: // Средне
      strength == HashStrength.low? algorithmConfigs[2]: // Быстро
      [];
  }

  Future<String> getHash({required String hashedPassword, required String salt}) async{
    final algorithm = Argon2id(
      parallelism: algorithmConfig[0], 
      memory: algorithmConfig[1], 
      iterations: algorithmConfig[2], 
      hashLength: algorithmConfig[3]
    );
    
    final newSecretKey = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(hashedPassword)), 
      nonce: utf8.encode(salt)
    );

    final newSecretKeyBytes = await newSecretKey.extractBytes();

    return base64Encode(newSecretKeyBytes);
  }
}

enum HashStrength{
  low,
  medium,
  high
}

String getPsswd(
  Float version,
  Int8 preset,
  Int8 length,
  Map<String, Bool> alphabetFlags,
  Map<String, Int8> minCounts,
  Bool excludeSimilar,
  Bool mode,
  Map <String, dynamic> settings,
  Map <String, dynamic> advanced
){
    return 'psswd';
  }