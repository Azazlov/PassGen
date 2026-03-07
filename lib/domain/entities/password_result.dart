/// Результат генерации пароля
class PasswordResult {
  final String password;
  final double strength;
  final String config;
  final String? error;

  const PasswordResult({
    required this.password,
    required this.strength,
    required this.config,
    this.error,
  });

  bool get hasError => error != null;

  @override
  String toString() => 'PasswordResult(password: ${password.isEmpty ? 'empty' : '***'}, strength: $strength)';
}
