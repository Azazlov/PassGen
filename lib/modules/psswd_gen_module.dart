import 'dart:typed_data';

class PasswordGenerator{
  int seed = 0;

  int lcg({int a=0x19660C, int c=0x3C6EF35F, int m=0x40000000}){
    // print('($a * $seed + $c ) % $m');
    seed = (a+seed+c)%m;
    seed = (0x41C64E71+seed+0x3039DA)%m;
    // seed = (seed+(seed+1))%m;

    return seed;
  }

  String generatePassword(int seed, int length, String alphabet){
    this.seed = seed+length;
    int lenAlphabet = alphabet.length;
    String psswd = '';
    int randIndex;
    for (int i=0; i<length; i++){
      randIndex = lcg()%lenAlphabet;
      psswd += alphabet[randIndex];
    }

    return psswd;
  }

  String getPassword(
    int masterpsswd, 
    String service, 
    int psswdlen, 
    bool upper, 
    bool lower, 
    bool dig, 
    bool spec1,
    bool spec2,
    bool spec3,
    ){
    String az = '';
    upper?az+='ABCDEFGHIJKLMNOPQRSTUVWXYZ':false;
    lower?az+='abcdefghijklmnopqrstuvwxyz':false;
    dig?az+='0123456789':false;
    spec1?az+='!@#\$%^&*()_+-=':false;
    spec2?az+='"\'`,./;:[]}{<>\\|':false;
    spec3?az+='~?':false;
    return generatePassword(masterpsswd, psswdlen, az);
  }

  String bytesToRad(Uint8List bytes, int rad){
  return bytes.map((b) => b.toRadixString(rad).padLeft(2, '0')).join('');
  }
}