/// Состояние аутентификации
class AuthState {
  final bool isAuthenticated;
  final bool isPinSetup;
  final bool isLocked;
  final int? remainingAttempts;
  final DateTime? lockoutUntil;

  const AuthState({
    this.isAuthenticated = false,
    this.isPinSetup = false,
    this.isLocked = false,
    this.remainingAttempts,
    this.lockoutUntil,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isPinSetup,
    bool? isLocked,
    int? remainingAttempts,
    DateTime? lockoutUntil,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isPinSetup: isPinSetup ?? this.isPinSetup,
      isLocked: isLocked ?? this.isLocked,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    );
  }

  /// Время блокировки в секундах (если заблокировано)
  int get lockoutSecondsRemaining {
    if (!isLocked || lockoutUntil == null) return 0;
    final diff = lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  @override
  String toString() => 'AuthState(auth: $isAuthenticated, setup: $isPinSetup, locked: $isLocked)';
}
