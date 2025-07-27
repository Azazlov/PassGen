import 'package:secure_pass/modules/crypto.dart';
import 'package:secure_pass/modules/psswdGen.dart';
import 'package:flutter/foundation.dart';

class PasswordGeneratorService {
  static Future<String> generatePassword({
    required String master,
    required String service,
    required int length,
    required bool useUpper,
    required bool useLower,
    required bool useDigits,
    required bool useSpec1,
    required bool useSpec2,
    required bool useSpec3,
  }) async {
    return await compute(generateSync, {
      'master': master,
      'service': service,
      'length': length,
      'upper': useUpper,
      'lower': useLower,
      'digits': useDigits,
      'spec1': useSpec1,
      'spec2': useSpec2,
      'spec3': useSpec3,
    });
  }

  static String encryptDetails({
    required String master,
    required String service,
    required int length,
    required String key,
    required List<bool> options,
  }) {
    return encrypt(
      'master: $master, service: $service, length: $length, opts: $options',
      key,
    );
  }
}
