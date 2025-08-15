import 'package:encrypt/encrypt.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:crypto/crypto.dart';

// class GenKey {
//   static String generateConfig() {
//     // Генерация ключевой пары
//     final key = RSAKeyParser();
//     final keyPair = RsaKeyHelper().generateKeyPair();
//     final publicKey = keyPair.publicKey;
//     final privateKey = keyPair.privateKey;

//     // Получение параметров
//     final d = privateKey.d;
//     final n = privateKey.n;
//     final e = publicKey.e;
//     final p = privateKey.p;
//     final q = privateKey.q;

//     return '${CustomRSA.conv(d, 36)}.${CustomRSA.conv(p, 36)}.${CustomRSA.conv(q, 36)}.${CustomRSA.conv(e, 36)}.${CustomRSA.conv(n, 36)}';
//   }
// }