import 'dart:convert';

import '../../core/security/vault_key_session.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/encryptor_local_datasource.dart';
import '../../data/datasources/storage_local_datasource.dart';

/// Сервис, разблокирующий vault-ключ профиля после успешной аутентификации.
///
/// Точка склейки между auth-слоем и шифрованием полей. Шаги:
/// 1. читаем `pin_salt` профиля из `auth_data`;
/// 2. выводим vault-ключ (PBKDF2-HMAC-SHA256, 600 000 итераций) — то же,
///    что использует `AuthLocalDataSource` для хеширования PIN, но с
///    извлечением байтов ключа;
/// 3. кладём ключ в `VaultKeySession` (in-memory, очищается на lock);
/// 4. лениво дошифровываем оставшиеся plaintext-метаданные текущего профиля.
///
/// Сервис не персистит сам PIN и не хранит ключ дольше сессии.
class VaultUnlockService {
  VaultUnlockService({
    required AuthLocalDataSource authDataSource,
    required EncryptorLocalDataSource encryptor,
    required StorageLocalDataSource storage,
  })  : _auth = authDataSource,
        _encryptor = encryptor,
        _storage = storage;

  final AuthLocalDataSource _auth;
  final EncryptorLocalDataSource _encryptor;
  final StorageLocalDataSource _storage;

  /// Вызывать сразу после успешного `verifyPin`. Возвращает количество
  /// фоновых записей, которые удалось дошифровать (информативно, может быть
  /// `0`).
  Future<int> unlockWithPin({
    required int profileId,
    required String pin,
  }) async {
    final salt = await _auth.getProfileSalt(profileId);
    if (salt == null) return 0;

    final keyBytes = await _encryptor.deriveVaultKeyBytes(
      pin: utf8.encode(pin),
      salt: salt,
    );
    VaultKeySession.setForProfile(profileId: profileId, keyBytes: keyBytes);

    return _storage.runLazyFieldEncryption(profileId: profileId);
  }

  /// Очищает кеш ключа. Вызывается при lock/logout.
  void lock() {
    VaultKeySession.clear();
  }
}
