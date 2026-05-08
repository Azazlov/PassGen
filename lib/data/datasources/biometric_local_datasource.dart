import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart' as la;

import '../../../domain/entities/biometric_type.dart' as app;
import '../../../core/errors/failures.dart';

/// Локальный источник биометрии
///
/// Обёртка над `local_auth` (сигнал да/нет) + `flutter_secure_storage`
/// (хранение PIN под биометрическим гейтом ОС).
/// На desktop (Windows/Linux/macOS) и web биометрия недоступна.
class BiometricLocalDataSource {
  BiometricLocalDataSource({
    la.LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? la.LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  final la.LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _pinKeyPrefix = 'biometric_pin_';

  /// Возвращает true только на Android/iOS с доступной биометрией
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return false;
    }
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Выполняет биометрическую аутентификацию
  Future<bool> authenticate({required String localizedReason}) async {
    if (!await isAvailable()) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const la.AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      throw const AuthFailure(
        message: 'Ошибка биометрической аутентификации',
        type: AuthFailureType.general,
      );
    }
  }

  /// Сохраняет PIN профиля в secure storage
  Future<void> enableForProfile(int profileId, String pin) async {
    try {
      await _secureStorage.write(
        key: '$_pinKeyPrefix$profileId',
        value: pin,
      );
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка включения биометрии');
    }
  }

  /// Читает PIN профиля из secure storage
  Future<String?> retrievePinForProfile(int profileId) async {
    try {
      return await _secureStorage.read(
        key: '$_pinKeyPrefix$profileId',
      );
    } catch (e) {
      return null;
    }
  }

  /// Удаляет PIN профиля из secure storage
  Future<void> disableForProfile(int profileId) async {
    try {
      await _secureStorage.delete(
        key: '$_pinKeyPrefix$profileId',
      );
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка отключения биометрии');
    }
  }

  /// Проверяет, сохранён ли PIN для профиля
  Future<bool> isEnabledForProfile(int profileId) async {
    try {
      final pin = await _secureStorage.read(
        key: '$_pinKeyPrefix$profileId',
      );
      return pin != null;
    } catch (e) {
      return false;
    }
  }

  /// Возвращает тип доступной биометрии
  Future<app.BiometricType> getBiometricType() async {
    if (!await isAvailable()) return app.BiometricType.unknown;
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.contains(la.BiometricType.face)) {
        return app.BiometricType.face;
      }
      if (biometrics.contains(la.BiometricType.fingerprint)) {
        return app.BiometricType.fingerprint;
      }
      return app.BiometricType.unknown;
    } catch (e) {
      return app.BiometricType.unknown;
    }
  }
}
