import 'package:secure_pass/features/passwordGenerator/data/psswdGenServ.dart';

class PasswordGenerationInterface {
  String generatedPassword = '';
  String secret = '';
  String error = '';
  String lastQuery = '';

  Future<List> generate({
    required String master,
    required String key,
    required String service,
    required String length,
    required bool useUpper,
    required bool useLower,
    required bool useDigits,
    required bool useSpec1,
    required bool useSpec2,
    required bool useSpec3,
  }) async {

    if (lastQuery == master+key+service+length+useUpper.toString()+useLower.toString()+useDigits.toString()+useSpec1.toString()+useSpec2.toString()+useSpec3.toString()){
      error = 'Уже выполненный запрос';
      return [generatedPassword, secret];
    }

    lastQuery = master+key+service+length+useUpper.toString()+useLower.toString()+useDigits.toString()+useSpec1.toString()+useSpec2.toString()+useSpec3.toString();

    if (master.isEmpty || service.isEmpty) {
      error = 'Поля не могут быть пустыми';
      return [error, ''];
    }
    if (master.length < 8 || master.length > 64) {
      error = 'Мастер-пароль должен быть от 8 до 64 символов';
      return [error, ''];
    }
    if (!(useUpper || useLower || useDigits || useSpec1 || useSpec2 || useSpec3)) {
      error = 'Выберите хотя бы один тип символов';
      return [error, ''];
    }

    generatedPassword = await PasswordGeneratorService.generatePassword(
      master: master,
      service: service,
      length: int.parse(length),
      useUpper: useUpper,
      useLower: useLower,
      useDigits: useDigits,
      useSpec1: useSpec1,
      useSpec2: useSpec2,
      useSpec3: useSpec3,
    );

    secret = PasswordGeneratorService.encryptDetails(
      master: master,
      service: service,
      length: int.parse(length),
      key: key,
      options: [useUpper, useLower, useDigits, useSpec1, useSpec2, useSpec3],
    );

    return [generatedPassword, secret];
  }
}
