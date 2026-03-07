import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Утилиты для защиты от скриншотов на Android
class AndroidSecurityUtils {
  static const platform = MethodChannel('com.passgen.app/security');

  /// Устанавливает флаг FLAG_SECURE для защиты от скриншотов
  /// Работает только на Android
  static Future<void> setSecureFlag(bool secure) async {
    if (!Platform.isAndroid) return;

    try {
      await platform.invokeMethod('setSecureFlag', {'secure': secure});
    } on PlatformException catch (e) {
      debugPrint('Ошибка установки FLAG_SECURE: ${e.message}');
    }
  }
}
