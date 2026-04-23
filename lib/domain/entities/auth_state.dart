/// Состояние аутентификации
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isPinSetup = false,
    this.isLocked = false,
    this.remainingAttempts,
    this.lockoutUntil,
    this.currentProfileId,
    this.isBiometricEnabled = false,
    this.isBiometricAvailable = false,
    this.lockoutSeriesIndex = 0,
  });

  final bool isAuthenticated;
  final bool isPinSetup;
  final bool isLocked;
  final int? remainingAttempts;
  final DateTime? lockoutUntil;

  // v0.6: per-profile fields
  final int? currentProfileId;
  final bool isBiometricEnabled;
  final bool isBiometricAvailable;
  final int lockoutSeriesIndex;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isPinSetup,
    bool? isLocked,
    int? remainingAttempts,
    DateTime? lockoutUntil,
    int? currentProfileId,
    bool? isBiometricEnabled,
    bool? isBiometricAvailable,
    int? lockoutSeriesIndex,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isPinSetup: isPinSetup ?? this.isPinSetup,
      isLocked: isLocked ?? this.isLocked,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
      currentProfileId: currentProfileId ?? this.currentProfileId,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      lockoutSeriesIndex: lockoutSeriesIndex ?? this.lockoutSeriesIndex,
    );
  }

  /// Время блокировки в секундах (если заблокировано)
  int get lockoutSecondsRemaining {
    if (!isLocked || lockoutUntil == null) return 0;
    final diff = lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  @override
  String toString() =>
      'AuthState(auth: $isAuthenticated, setup: $isPinSetup, locked: $isLocked, profile: $currentProfileId)';
}
