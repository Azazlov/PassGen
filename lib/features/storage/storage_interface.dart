import 'dart:typed_data';

import 'package:pass_gen/features/storage/storage_service.dart';
import 'package:pass_gen/features/passwordGenerator/psswd_gen_interface.dart';

Future<String> getPsswd(int id) async{
  final encryptedConfig = (await getConfigs('encryptedConfigs'))[id];
  // print(encryptedConfig);
  final key = (await getConfigs('psswdGen'))[0];
  // print(key);
  final config = ('${encryptedConfig.split('.')[0]}.${await PasswordGenerationInterface().getConfig(config: encryptedConfig, key: key)}').split('.');
  // print(config);
  try{
    int conflen = config.length;
    Uint64List seed = Uint64List(conflen-8);
    // print(config);
    for (int i=1; i<conflen-7; i++){
      seed[i-1] = int.parse(config[i], radix: 36);
    }
    // print(seed);
    final psswd = await PasswordGenerationInterface().generatePsswd(
      seed: seed, 
      key: key, 
      service: config[8], 
      length: config[conflen-7], 
      useUpper: config[conflen-6]=='t'?true:false, 
      useLower: config[conflen-5]=='t'?true:false, 
      useDigits: config[conflen-4]=='t'?true:false, 
      useSpec1: config[conflen-3]=='t'?true:false, 
      useSpec2: config[conflen-2]=='t'?true:false, 
      useSpec3: config[conflen-1]=='t'?true:false
      );
    return psswd;
  }
  catch (e){
    // print(e);
    return 'Error';
  }
}