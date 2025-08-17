import 'package:secure_pass/features/storage/storage_service.dart';
import 'package:secure_pass/features/passwordGenerator/psswd_gen_interface.dart';

Future<String> getPsswd(int id) async{
  final encryptedConfig = (await getConfigs('encryptedConfigs'))[id];
  // print(encryptedConfig);
  final key = (await getConfigs('psswdGen'))[0];
  // print(key);
  final config = ('${encryptedConfig.split('.')[0]}.${await PasswordGenerationInterface().getConfig(config: encryptedConfig, key: key, masterKey: '')}').split('.');
  // print(config);
  try{
    final psswd = await PasswordGenerationInterface().generatePsswd(
      master: config[1], 
      key: key, 
      masterKey: '', 
      service: config[0], 
      length: config[2], 
      useUpper: config[3]=='true'?true:false, 
      useLower: config[4]=='true'?true:false, 
      useDigits: config[5]=='true'?true:false, 
      useSpec1: config[6]=='true'?true:false, 
      useSpec2: config[7]=='true'?true:false, 
      useSpec3: config[8]=='true'?true:false, 
      secretPsswd: 'RH2RFC@u054+ERrWIao8dhJ4WB&THPhihXC()VYZY#SIX6^Y&DB1^b6WO)Y5#QlhG\$Y5U@DscggM(Crw!(CJ^Wl1YXR\$^Q&gg=gV^SUavI!Dr2XP&tCVaEiY1KE7Al30'
      );
    return psswd;
  }
  catch (exception){
    return 'Error';
  }
}