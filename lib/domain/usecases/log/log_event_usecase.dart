import '../../repositories/security_log_repository.dart';

/// Use case для логирования событий
class LogEventUseCase {
  LogEventUseCase(this.repository);
  final SecurityLogRepository repository;

  Future<void> execute(
    String actionType, {
    Map<String, dynamic>? details,
  }) async {
    await repository.logEvent(actionType, details: details);
  }
}
