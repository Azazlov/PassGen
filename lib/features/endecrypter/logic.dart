import 'package:pass_gen/modules/encrypted.dart';
import 'dart:convert';

class EndecrypterInterface {
  Future<String> encryptMessage({
    required String message,
    required String password,
  }) async {
    Encrypted encrypted = Encrypted();
    await encrypted.getEncr(
      message: utf8.encode(message),
      password: utf8.encode(password),
    );
    return encrypted.getMiniEncr();
  }

  Future<String> decryptMessage({
    required String encrJSON,
    required String key,
  }) async {
    Encrypted encrypted = Encrypted(encrJSON: encrJSON);
    String message = utf8.decode(await encrypted.getDeEncr(
      passwd: utf8.encode(key),
    ));
    return message;
  }
}

void main(List<String> args) async {
  EndecrypterInterface encrypter = EndecrypterInterface();
  String mssg = 'Hello';
  print('Message: ${mssg}');
  String password = 'secret123';
  print('Password: ${password}');
  String encrypted = await encrypter.encryptMessage(message: mssg, password: password);
  print('Encrypted message: ${encrypted}');
  String decrypted = await encrypter.decryptMessage(encrJSON: encrypted, key: password);
  print('Decrypted message: ${decrypted}');
}