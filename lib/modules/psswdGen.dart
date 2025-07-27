import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';


String secureHash(String a, String b, String c, int stretch) {

  dynamic result = utf8.encode(a + b + c);
  for (int i = 0; i < stretch~/2; i++) {
    result = sha256.convert(result).bytes;

  }
  return base64.encode(result);
}

String encryptpsswd(List<int> psswdBytes, int charsIn, String alphabet) {
  return psswdBytes.map((b) => alphabet[b % charsIn]).join();
}

String getDeterministicAlphabet(String master, String service, String az) {
  List<String> chars = az.split('');
  var masterSeed = sha256.convert(utf8.encode(master)).bytes;
  var serviceSeed = sha256.convert(utf8.encode(service)).bytes;

  var rngMaster = Random(BigInt.parse(bytesToHex(masterSeed), radix: 16).toInt());
  chars.shuffle(rngMaster);

  var rngService = Random(BigInt.parse(bytesToHex(serviceSeed), radix: 16).toInt());
  chars.shuffle(rngService);

  return chars.join();
}

String choiceRandomChars(int psswdlen, List<int> psswdBytes, String securepsswd) {
  var bigIntPsswd = BigInt.parse(bytesToHex(psswdBytes), radix: 16).toInt();
  int seclen = securepsswd.length;
  String result = '';

  for (int i = 0; i < psswdlen; i++) {
    int index = bigIntPsswd % (seclen - i);
    result += securepsswd[index];
  }
  return result;
}

String bytesToHex(List<int> bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

String getPsswd(String masterpsswd, String service, int psswdlen, bool upper, bool lower, bool dig, bool spec1, bool spec2, bool spec3) {
  final upperLet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final lowerLet = "abcdefghijklmnopqrstuvwxyz";
  final digChar = "0123456789";
  final specChar1 = "!@#\$%^&*()_+-=";
  final specChar2 = "\"'`,./;:[]}{<>\\|";
  final specChar3 = "~?";

  final enMP = masterpsswd.codeUnits.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  final enS = service.codeUnits.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  final radius = utf8.encode(secureHash(enMP, enS, enS + enMP, psswdlen * 789)).length;

  // print('${enMP} ${enS} ${radius}');

  String az = '';
  if (upper) az += upperLet;
  if (lower) az += lowerLet;
  if (spec1) az += specChar1;
  if (spec2) az += specChar2;
  if (spec3) az += specChar3;
  if (dig) az += digChar;

  final salt = secureHash(enMP, service, masterpsswd + service, psswdlen * 1245);
  final salted = secureHash(masterpsswd, service, salt, psswdlen * 802);
  List<int> psswd = sha256.convert(utf8.encode(salted)).bytes;

  final iterations = radius*2;
  final alphabet = getDeterministicAlphabet(masterpsswd, service, az);
  final charsIn = alphabet.length;
  String securepsswd = '';

  for (int d = 0; d < 6; d++) {
    for (int i = d; i < iterations; i++) {
      String enMPtemp = '';
      if (dig && d == 6) enMPtemp = encryptpsswd(utf8.encode(secureHash(digChar, enS, salted, radius)), digChar.length, alphabet);
      else if (spec3 && d == 5) enMPtemp = encryptpsswd(utf8.encode(secureHash(specChar3, enS, salted, radius)), specChar3.length, alphabet);
      else if (spec2 && d == 4) enMPtemp = encryptpsswd(utf8.encode(secureHash(specChar2, enS, salted, radius)), specChar2.length, alphabet);
      else if (spec1 && d == 3) enMPtemp = encryptpsswd(utf8.encode(secureHash(specChar1, enS, salted, radius)), specChar1.length, alphabet);
      else if (lower && d == 2) enMPtemp = encryptpsswd(utf8.encode(secureHash(lowerLet, enS, salted, radius)), lowerLet.length, alphabet);
      else if (upper && d == 1) enMPtemp = encryptpsswd(utf8.encode(secureHash(upperLet, enS, salted, radius)), upperLet.length, alphabet);
      else enMPtemp = enMP;

      final hash = secureHash(BigInt.parse(bytesToHex(psswd), radix: 16).toString(), salt, enMPtemp, psswdlen * 130 + i * d);
      securepsswd += encryptpsswd(utf8.encode(hash), charsIn, alphabet);
      psswd = sha256.convert(utf8.encode(BigInt.parse(bytesToHex(psswd), radix: 16).toString())).bytes;
    }
  }

  return choiceRandomChars(psswdlen, psswd, securepsswd);
}

String generateSync(Map<String, dynamic> args) {
  return getPsswd(
    args['master'],
    args['service'],
    args['length'],
    args['upper'],
    args['lower'],
    args['digits'],
    args['spec1'],
    args['spec2'],
    args['spec3'],
  );
}