import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pass_gen/modules/encryptobara.dart' as encryptobara;
import 'package:pass_gen/modules/psswd_gen_module.dart';

class PasswordGenerationInterface {
  String generatedPassword = '';
  String secret = '';
  String error = '';
  String lastQuery = '';

  Future<String> generatePsswd({
    required Uint64List seed,
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
      seed,
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
    String secret = base64Encode(secretBytes);
    return secret;
  }

  Future<String> generateMssg({
    required String secret,
    required String key
  }) async {
    secret = secret.trim();
    Uint8List mssgBytes = encryptobara.decrypt(
      base64Decode(secret),
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
    PasswordGenerator gen = PasswordGenerator();
    int randSeed = Random.secure().nextInt(1<<32);
    gen.seed = randSeed;
    // print(gen.lcg()^randSeed);
    return int.parse((gen.lcg()^randSeed).toString());
  }

  Future<List> generatePsswdSecret({
    required Uint64List master,
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
    String seed = '';
    for (int i=0; i<master.length; i++){
      seed += '${master[i].toRadixString(36)}.';
    }
    dynamic mssg = '$seed$length.${useUpper.toString()[0]}.${useLower.toString()[0]}.${useDigits.toString()[0]}.${useSpec1.toString()[0]}.${useSpec2.toString()[0]}.${useSpec3.toString()[0]}';
    // mssg += '.${mssg.hashCode}';
    final generatedPassword = await generatePsswd(seed: master, key: key, service: service, length: length, useUpper: useUpper, useLower: useLower, useDigits: useDigits, useSpec1: useSpec1, useSpec2: useSpec2, useSpec3: useSpec3);
    final secret = '$service.${await generateSecret(mssg: mssg, key: key)}';

    return [generatedPassword, secret];
  }
}
