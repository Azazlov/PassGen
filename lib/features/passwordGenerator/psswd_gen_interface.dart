import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:secure_pass/modules/encryptobara.dart' as encryptobara;
import 'package:secure_pass/modules/psswd_gen_module.dart';

class PasswordGenerationInterface {
  String generatedPassword = '';
  String secret = '';
  String error = '';
  String lastQuery = '';

  Future<String> generatePsswd({
    required int master,
    required String key,
    required String service,
    required String length,
    required bool useUpper,
    required bool useLower,
    required bool useDigits,
    required bool useSpec1,
    required bool useSpec2,
    required bool useSpec3
  }) async {
    generatedPassword = PasswordGenerator().getPassword(
      master,
      service,
      int.parse(length),
      useUpper,
      useLower,
      useDigits,
      useSpec1,
      useSpec2,
      useSpec3,
    );
    return generatedPassword;
  }

  Future<String> generateSecret({
    required String mssg,
    required String key
  }) async {
    mssg = mssg.trim();
    Uint8List secretBytes = encryptobara.encrypt(
      utf8.encode(mssg),
      utf8.encode(key)
    );
    secret = encryptobara.bytesToRad(secretBytes, 36);
    return secret;
  }

  Future<String> generateMssg({
    required String secret,
    required String key
  }) async {
    secret = secret.trim();
    Uint8List mssgBytes = encryptobara.decrypt(
      encryptobara.radToBytes(secret, 36),
      utf8.encode(key)
    );
    String mssg = utf8.decode(mssgBytes);
    return mssg;
  }

  Future<String> getConfig({
    required String config,
    required String key,
  }) async {

    return await generateMssg(secret: config.split('.')[1], key: key);
  }

  Future<int> generateMaster() async{
    return Random.secure().nextInt(1<<32-2);
  }

  Future<List> generatePsswdSecret({
    required int master,
    required String key,
    required String service,
    required String length,
    required bool useUpper,
    required bool useLower,
    required bool useDigits,
    required bool useSpec1,
    required bool useSpec2,
    required bool useSpec3
  }) async {
    dynamic mssg = '$master.$length.${useUpper.toString()}.${useLower.toString()}.${useDigits.toString()}.${useSpec1.toString()}.${useSpec2.toString()}.${useSpec3.toString()}';
    // mssg += '.${mssg.hashCode}';
    final generatedPassword = await generatePsswd(master: master, key: key, service: service, length: length, useUpper: useUpper, useLower: useLower, useDigits: useDigits, useSpec1: useSpec1, useSpec2: useSpec2, useSpec3: useSpec3);
    final secret = '$service.${await generateSecret(mssg: mssg, key: key)}';

    return [generatedPassword, secret];
  }
}
