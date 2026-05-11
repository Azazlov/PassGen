/// In-memory cache of the derived per-profile «vault key».
///
/// Полезная нагрузка — 32 байта симметричного ключа, выведенного из
/// `(PIN, profile.pin_salt)` через PBKDF2-HMAC-SHA256 (600 000 итераций).
/// Один раз после успешной аутентификации ключ кладётся сюда; все операции
/// шифрования/дешифрования метаданных (service/login) работают с ним напрямую,
/// избегая повторного PBKDF2 на каждое поле/каждое чтение.
///
/// Хранилище принципиально не персистентное: чистится на app lock / logout.
class VaultKeySession {
  VaultKeySession._();

  static int? _profileId;
  static List<int>? _keyBytes;

  /// Сохраняет ключ для активного профиля.
  static void setForProfile({
    required int profileId,
    required List<int> keyBytes,
  }) {
    _profileId = profileId;
    _keyBytes = List<int>.unmodifiable(keyBytes);
  }

  /// Возвращает ключ, если он принадлежит запрошенному профилю.
  static List<int>? getForProfile(int profileId) {
    if (_profileId != profileId) return null;
    return _keyBytes;
  }

  /// Текущий активный профиль (если ключ загружен).
  static int? get activeProfileId => _profileId;

  /// Очищает кэш (вызывать на lock/logout).
  static void clear() {
    _profileId = null;
    if (_keyBytes != null) {
      // best-effort wipe (List<int>.unmodifiable не позволяет менять,
      // но GC всё равно отпустит ссылку).
      _keyBytes = null;
    }
  }
}
