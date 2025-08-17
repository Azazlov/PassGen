import 'dart:math';
import 'encryptobara.dart' as encryptobara;
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

class PasswordGenerator {

  static List<int> intToBytes(int number) {
    // Создаем ByteData с достаточным размером (8 байт для 64-битного int)
    var byteData = ByteData(8);
    byteData.setInt64(0, number); // или setInt32 для 32-битных чисел
    
    // Преобразуем в список байт
    return byteData.buffer.asUint8List().toList();
  }

  static String choiceRandomChars(int psswdlen, int salt, String securepsswd) {
    var seclen = securepsswd.length;
    var ultrasecpsswd = '';
    int ind;
    
    for (var index = 0; index < psswdlen; index++) {
      var randInt = Random(salt).nextInt(psswdlen - index) + index;
      ind = (Random(ultrasecpsswd.hashCode).nextInt(salt + psswdlen + randInt)) % (seclen);
      ind<0?-ind:ind;
      ultrasecpsswd += securepsswd[
          ind
      ];
    }
    
    return ultrasecpsswd;
  }

  static String getPassword({
    required String masterpsswd,
    required String service,
    required int psswdlen,
    bool upper = true,
    bool lower = true,
    bool dig = true,
    bool spec1 = true,
    bool spec2 = true,
    bool spec3 = true,
    required String secretPsswd
  }) {
    var rand = Random(sha256.convert(masterpsswd.codeUnits).bytes
    .fold(0, (prev, byte) => prev !+ byte));
    
    var upperLet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');
    upperLet.shuffle(rand);
    
    var lowerLet = "abcdefghijklmnopqrstuvwxyz".split('');
    lowerLet.shuffle(rand);
    
    var specChar1 = ("""!@#\$%^&*()_+-=""" * 3).split('');
    specChar1.shuffle(rand);
    
    var specChar2 = (""""'`,./;:[]}{<>\\|""" * 2).split('');
    specChar2.shuffle(rand);
    
    var specChar3 = ("""~?""" * 13).split('');
    specChar3.shuffle(rand);
    
    var digChar = ("0123456789" * 5).split('');
    digChar.shuffle(rand);
    
    var az = '';
    
    if (upper) {
      az += encryptobara.generateDeterministicAlphabet(
        key: masterpsswd,
        master: secretPsswd,
        alphabet: az + upperLet.join()
      );
    }
    
    if (lower) {
      az += encryptobara.generateDeterministicAlphabet(
        key: masterpsswd,
        master: secretPsswd,
        alphabet: az + lowerLet.join()
      );
    }
    
    if (spec1) {
      az += encryptobara.generateDeterministicAlphabet(
        key: masterpsswd,
        master: secretPsswd,
        alphabet: az + specChar1.join()
      );
    }
    
    if (spec2) {
      az += encryptobara.generateDeterministicAlphabet(
        key: masterpsswd,
        master: secretPsswd,
        alphabet: az + specChar2.join()
      );
    }
    
    if (spec3) {
      az += encryptobara.generateDeterministicAlphabet(
        key: masterpsswd,
        master: secretPsswd,
        alphabet: az + specChar3.join()
      );
    }
    
    if (dig) {
      az += encryptobara.generateDeterministicAlphabet(
        key: masterpsswd,
        master: secretPsswd,
        alphabet: az + digChar.join()
      );
    }
    
    az = encryptobara.generateDeterministicAlphabet(
      key: service,
      master: masterpsswd,
      alphabet: az
    );
    
    if (az.isEmpty) return '';
    
    var salt = Random(
      sha256.convert((masterpsswd + service).codeUnits).bytes
          .fold(0, (prev, byte) => prev !+ byte)
    ).nextInt(64);
    
    return choiceRandomChars(
      psswdlen,
      salt,
      encryptobara.generateDeterministicAlphabet(
        key: masterpsswd,
        master: service,
        alphabet: az
      )
    );
  }
}