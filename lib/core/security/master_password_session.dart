/// In-memory storage for the current "master password" (PIN) per active session.
///
/// This is intentionally non-persistent: it is set after successful auth and
/// cleared on app lock/logout to avoid storing secrets on disk.
class MasterPasswordSession {
  MasterPasswordSession._();

  static int? _profileId;
  static String? _pin;

  static void setForProfile({required int profileId, required String pin}) {
    _profileId = profileId;
    _pin = pin;
  }

  static String? getForProfile(int profileId) {
    if (_profileId != profileId) return null;
    return _pin;
  }

  /// Returns the currently cached PIN regardless of profile.
  ///
  /// Use this only in flows that don't yet have profile awareness wired in.
  static String? getAny() => _pin;

  static void clear() {
    _profileId = null;
    _pin = null;
  }
}

