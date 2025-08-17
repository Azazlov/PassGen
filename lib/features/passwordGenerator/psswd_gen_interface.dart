import 'package:secure_pass/modules/encryptobara.dart' as encryptobara;
import 'package:secure_pass/modules/psswd_gen_module.dart';

class PasswordGenerationInterface {
  String generatedPassword = '';
  String secret = '';
  String error = '';
  String lastQuery = '';

  Future<String> generatePsswd({
    required String master,
    required String key,
    required String masterKey,
    required String service,
    required String length,
    required bool useUpper,
    required bool useLower,
    required bool useDigits,
    required bool useSpec1,
    required bool useSpec2,
    required bool useSpec3,
    required String secretPsswd
  }) async {
    generatedPassword = PasswordGenerator.getPassword(
      masterpsswd: master,
      service: service,
      psswdlen: int.parse(length),
      upper: useUpper,
      lower: useLower,
      dig: useDigits,
      spec1: useSpec1,
      spec2: useSpec2,
      spec3: useSpec3,
      secretPsswd: secretPsswd
    );
    return generatedPassword;
  }

  Future<String> generateSecret({
    required String mssg,
    required String key,
    required String masterKey
  }) async {
    secret = encryptobara.encrypt(
      mssg,
      master: masterKey,
      key: key,
      alphabet: String.fromCharCodes(List.generate(32768, (i) => i))
    );
    return secret;
  }

  Future<String> generateMssg({
    required String secret,
    required String key,
    required String masterKey
  }) async {
    var mssg = encryptobara.decrypt(
      secret,
      master: masterKey,
      key: key,
      alphabet: String.fromCharCodes(List.generate(32768, (i) => i))
    );
    return mssg;
  }

  Future<String> getConfig({
    required String config,
    required String key,
    required String masterKey
  }) async {
    final items = config.split('.');
    config = '${items[1]}.${items[2]}.${items[3]}';
    return await generateMssg(secret: config, key: key, masterKey: masterKey);
  }

  Future<String> generateMaster() async{
    return encryptobara.generateRandomMaster(alphabet: '!%&\$()*+,-/0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~');
  }

  Future<List> generatePsswdSecret({
    required String master,
    required String key,
    required String masterKey,
    required String service,
    required String length,
    required bool useUpper,
    required bool useLower,
    required bool useDigits,
    required bool useSpec1,
    required bool useSpec2,
    required bool useSpec3,
    required String secretPsswd
  }) async {
    dynamic mssg = '$master.$length.${useUpper.toString()}.${useLower.toString()}.${useDigits.toString()}.${useSpec1.toString()}.${useSpec2.toString()}.${useSpec3.toString()}';
    mssg += '.${mssg.hashCode}';
    final generatedPassword = await generatePsswd(master: master, key: key, masterKey: masterKey, service: service, length: length, useUpper: useUpper, useLower: useLower, useDigits: useDigits, useSpec1: useSpec1, useSpec2: useSpec2, useSpec3: useSpec3, secretPsswd: secretPsswd);
    final secret = '$service.${await generateSecret(mssg: mssg, key: key, masterKey: masterKey)}';

    return [generatedPassword, secret];
  }
}
