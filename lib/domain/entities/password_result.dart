/// Результат генерации пароля
class PasswordResult {
  const PasswordResult({
    required this.password,
    required this.strength,
    required this.config,
    this.error,
  });
  final String password;
  final double strength;
  final String config;
  final String? error;

  bool get hasError => error != null;

  @override
  String toString() =>
      'PasswordResult(password: ${password.isEmpty ? 'empty' : '***'}, strength: $strength)';
}
