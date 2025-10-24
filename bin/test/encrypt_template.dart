import 'dart:ffi';
import 'package:cryptography/cryptography.dart';
// import 'shared.dart';
import 'dart:convert';


void testEncrypt(){

}

Future<void> getHash() async{
  final algorithm = Argon2id(
    parallelism: 1, 
    memory: 20000, 
    iterations: 3, 
    hashLength: 32
  );
  
  final newSecretKey = await algorithm.deriveKey(
    secretKey: SecretKey([1, 2, 3]), 
    nonce: [4, 5, 6]
  );

  final newSecretKeyBytes = await newSecretKey.extractBytes();

  print(base64Encode(newSecretKeyBytes));
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