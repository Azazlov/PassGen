import 'dart:math';
import 'dart:convert';

class CustomRSA {
  static const String alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const List<int> smallPrimes = [
    3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
    73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149,
    151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199
  ];

  static Tuple<String, String> getEN(String key, [bool convert = false]) {
    var parts = key.split('.');
    var e = parts[parts.length - 2];
    var n = parts.last;
    if (!convert) return Tuple(e, n);
    return Tuple(conv(BigInt.parse(e), 36), conv(BigInt.parse(n), 36));
  }

  static Tuple3<String, String, String> getDPQ(String key, [bool convert = false]) {
    var parts = key.split('.');
    if (parts.length < 3) throw Exception('Неправильный конфиг!');
    var d = parts[0];
    var p = parts[1];
    var q = parts[2];
    if (!convert) return Tuple3(d, p, q);
    return Tuple3(
      conv(BigInt.parse(d), 36),
      conv(BigInt.parse(p), 36),
      conv(BigInt.parse(q), 36)
    );
  }

  static BigInt encryptRSA(BigInt message, Tuple<BigInt, BigInt> publicKey) {
    var e = publicKey.item1;
    var n = publicKey.item2;
    return message.modPow(e, n);
  }

  static BigInt decryptRSA(BigInt c, Tuple3<BigInt, BigInt, BigInt> privateKey) {
    var d = privateKey.item1;
    var p = privateKey.item2;
    var q = privateKey.item3;
    
    var dp = d % (p - BigInt.one);
    var dq = d % (q - BigInt.one);
    var qpInv = q.modInverse(p);
    
    var m1 = c.modPow(dp, p);
    var m2 = c.modPow(dq, q);
    var h = (qpInv * (m1 - m2)) % p;
    var m = m2 + h * q;
    
    return m;
  }

  static String genSecretRSA(String config, String mssg) {
    var en = getEN(config, true);
    var crint = BigInt.from(bytesToInt(utf8.encode(mssg)));
    var encrypted = encryptRSA(crint, Tuple(BigInt.parse(en.item1), BigInt.parse(en.item2)));
    
    return '${conv(BigInt.parse(en.item1), 36)}.${conv(BigInt.parse(en.item2), 36)}.${conv(encrypted, 36)}';
  }

  static String unGenSecretRSA(String config, String secret) {
    var dpq = getDPQ(config, true);
    var secretPart = secret.split('.').last;
    var crint = BigInt.parse(secretPart, radix: 36);
    
    var d = BigInt.parse(dpq.item1);
    var p = BigInt.parse(dpq.item2);
    var q = BigInt.parse(dpq.item3);
    
    var code = decryptRSA(crint, Tuple3(d, p, q));
    return utf8.decode(intToBytes(code));
  }

  static int getBitsNum(BigInt integer) {
    var bitLength = integer.bitLength;
    return bitLength ~/ 8 + (bitLength % 8 != 0 ? 1 : 0);
  }

  static String conv(BigInt value, int base, [String alphabet = alphabet]) {
    if (base < 2 || base > alphabet.length) {
      throw Exception('Base out of range');
    }
    
    var res = '';
    var sign = value.isNegative ? '-' : '';
    var val = value.abs();
    
    if (val == BigInt.zero) return '0';
    
    while (val > BigInt.zero) {
      var remainder = (val % BigInt.from(base)).toInt();
      res = alphabet[remainder] + res;
      val = val ~/ BigInt.from(base);
    }
    
    return sign + res;
  }

  static BigInt deconv(String value, int base, [String alphabet = alphabet]) {
    var res = BigInt.zero;
    var isNegative = value.startsWith('-');
    var val = isNegative ? value.substring(1) : value;
    
    for (var i = 0; i < val.length; i++) {
      var char = val[i];
      var index = alphabet.indexOf(char);
      if (index == -1) throw Exception('Invalid character in input');
      res = res * BigInt.from(base) + BigInt.from(index);
    }
    
    return isNegative ? -res : res;
  }

  static bool isProbablePrime(BigInt n, [int k = 10]) {
    if (n < BigInt.two) return false;
    
    for (var p in smallPrimes) {
      var pBig = BigInt.from(p);
      if (n % pBig == BigInt.zero) return n == pBig;
    }
    
    var r = 0;
    var s = n - BigInt.one;
    while (s % BigInt.two == BigInt.zero) {
      r++;
      s = s ~/ BigInt.two;
    }
    
    var rng = Random();
    for (var i = 0; i < k; i++) {
      var a = BigInt.from(2) + 
              BigInt.from(rng.nextInt(n.toInt() - 3));
      var x = a.modPow(s, n);
      if (x == BigInt.one || x == n - BigInt.one) continue;
      
      var continueLoop = false;
      for (var j = 0; j < r - 1; j++) {
        x = x.modPow(BigInt.two, n);
        if (x == n - BigInt.one) {
          continueLoop = true;
          break;
        }
      }
      if (continueLoop) continue;
      return false;
    }
    return true;
  }

  static BigInt generatePrime(int bits) {
    var rng = Random();
    while (true) {
      var num = BigInt.zero;
      for (var i = 0; i < bits; i++) {
        num = (num << 1) + (rng.nextBool() ? BigInt.one : BigInt.zero);
      }
      num |= BigInt.one; // Ensure odd
      num |= BigInt.one << (bits - 1); // Ensure top bit is set
      
      if (isProbablePrime(num)) {
        return num;
      }
    }
  }

  static String generateKeys() {
    var bits = 2048;
    var p = generatePrime(bits);
    var q = generatePrime(bits);
    
    var n = p * q;
    var phi = (p - BigInt.one) * (q - BigInt.one);
    
    var e = BigInt.from(65537);
    var d = e.modInverse(phi);
    
    var publicKey = Tuple(e, n);
    var privateKey = Tuple3(d, p, q);
    
    return '${conv(privateKey.item1, 36)}.${conv(privateKey.item2, 36)}.${conv(privateKey.item3, 36)}.${conv(publicKey.item1, 36)}.${conv(publicKey.item2, 36)}';
  }

  static int bytesToInt(List<int> bytes) {
    var result = 0;
    for (var byte in bytes) {
      result = (result << 8) + byte;
    }
    return result;
  }

  static List<int> intToBytes(BigInt integer) {
    var bytes = <int>[];
    var val = integer;
    
    while (val > BigInt.zero) {
      bytes.insert(0, (val & BigInt.from(0xff)).toInt());
      val = val >> 8;
    }
    
    return bytes;
  }
}

void main(){
  CustomRSA.generateKeys();
}

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;
  
  Tuple(this.item1, this.item2);
}

class Tuple3<T1, T2, T3> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  
  Tuple3(this.item1, this.item2, this.item3);
}