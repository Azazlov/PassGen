/// Типы событий для логирования безопасности
class EventTypes {
  const EventTypes._();

  // События аутентификации
  static const String authSuccess = 'AUTH_SUCCESS';
  static const String authFailure = 'AUTH_FAILURE';
  static const String authLockout = 'AUTH_LOCKOUT';
  static const String pinSetup = 'PIN_SETUP';
  static const String pinChanged = 'PIN_CHANGED';
  static const String pinRemoved = 'PIN_REMOVED';

  // События паролей
  static const String pwdCreated = 'PWD_CREATED';
  static const String pwdAccessed = 'PWD_ACCESSED';
  static const String pwdUpdated = 'PWD_UPDATED';
  static const String pwdDeleted = 'PWD_DELETED';

  // События данных
  static const String dataExport = 'DATA_EXPORT';
  static const String dataImport = 'DATA_IMPORT';
  static const String dataImportFailure = 'DATA_IMPORT_FAILURE';

  // События настроек
  static const String settingsChanged = 'SETTINGS_CHG';

  // События сессии
  static const String sessionStarted = 'SESSION_STARTED';
  static const String sessionEnded = 'SESSION Ended';
  static const String sessionTimeout = 'SESSION_TIMEOUT';
}
