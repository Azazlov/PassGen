import 'package:pass_gen/modules/password_generation_config.dart';
import 'package:pass_gen/modules/generate_password.dart';

class PsswdGenInterface {
  late String password;
  late int version;
  late String service;
  late dynamic lastUsageDate;
  late String uuid;
  late String category;
  late int expireDays;
  late List<bool> includedSymbols; // [digits, lowercase, uppercase, symbols]
  late Map<String, List<dynamic>> alphabet = {};
  late List<int> passwordLength = [12];
  late bool isUniq = false;
  String includeDigits = '0123456789';
  String includeLowercase = 'abcdefghijklmnopqrstuvwxyz';
  String includeUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String includeSpecSymbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  
  PsswdGenInterface(
    String password,
    int version,
    String service,
    dynamic lastUsageDate,
    String uuid,
    String category,
    int expireDays,
    List<bool> includedSymbols
  ){
    this.password = password;
    this.version = version;
    this.service = service;
    this.lastUsageDate = lastUsageDate;
    this.uuid = uuid;
    this.category = category;
    this.expireDays = expireDays;
    this.includedSymbols = includedSymbols;

    for (bool isIncluded in includedSymbols){
      if (isIncluded){
        switch (includedSymbols.indexOf(isIncluded)){
          case 0:
            alphabet['digits'] = [includeDigits.split(''), true];
            break;
          case 1:
            alphabet['lowercase'] = [includeLowercase.split(''), true];
            break;
          case 2:
            alphabet['uppercase'] = [includeUppercase.split(''), true];
            break;
          case 3:
            alphabet['symbols'] = [includeSpecSymbols.split(''), true];
            break;
        }
      }
    };
  }
  Future<PasswordGenerationConfig> getConfig() async{
    PasswordGenerator generator = PasswordGenerator(alphabet, passwordLength, isUniq);
    List<dynamic> passwordData = await generator.generatePassword();
    String password = passwordData[0];
    double passwordStrength = passwordData[1];
    
    return PasswordGenerationConfig(
      version: version,
      service: service,
      lastUsageDate: lastUsageDate,
      uuid: uuid,
      category: category,
      expireDays: expireDays,
      encr: encr
    );
  }
}