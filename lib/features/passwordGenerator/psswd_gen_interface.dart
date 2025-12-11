import 'package:pass_gen/modules/configure_password.dart';

class PsswdGenInterface {
  late String psswd;
  late int version;
  late String service;
  late dynamic lastUsageDate;
  late String uuid;
  late String category;
  late int expireDays;
  
  PsswdGenInterface(
    String psswd,
    int version,
    String service,
    dynamic lastUsageDate,
    String uuid,
    String category,
    int expireDays,
  );
  Future<EncryptedConfig> getConfig() async{
    
    return EncryptedConfig(
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