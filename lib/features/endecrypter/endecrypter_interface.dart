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
      passwd: utf8.encode(password),
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