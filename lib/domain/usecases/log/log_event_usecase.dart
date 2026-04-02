import '../../repositories/security_log_repository.dart';

/// Use case для логирования событий
class LogEventUseCase {
  const LogEventUseCase(this.repository);
  final SecurityLogRepository repository;

  Future<void> execute(
    String actionType, {
    Map<String, dynamic>? details,
  } {
    await repository.logEvent(actionType, details: details);
  }
}
