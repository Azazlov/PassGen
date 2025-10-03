import 'dart:typed_data';

class PasswordGenerator{
  int a= 1966696451771256657;
  int c= 2194867269497829361;
  int m= 1<<63;
  int seed = 0;

  int lcg(){
    seed = (a*seed+c)%m;
    seed = (seed*(seed))%m;
    seed = (seed^(seed>>16))%m;

    return seed+3;
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
    Uint64List seed,
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
    String psswd = '';
    // print(generatePassword(seed[0%seed.length], psswdlen, az));
    for (int i=0; i<psswdlen; i++){
      psswd += generatePassword(seed[i%seed.length], psswdlen, az)[(seed[i%seed.length]-i)%psswdlen];
    }
    return psswd;
  }
}

// void main(){
//   String a = PasswordGenerator().getPassword(Uint64List.fromList([2194867269497829361, 2194867269497829361, 2194867269497829361]), 32, true, true, true, true, true, true);
//   print(a);
// }