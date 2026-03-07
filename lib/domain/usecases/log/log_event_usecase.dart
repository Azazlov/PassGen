import '../../repositories/security_log_repository.dart';

/// Use case для логирования событий
class LogEventUseCase {
  final SecurityLogRepository repository;

  LogEventUseCase(this.repository);

  Future<void> execute(String actionType, {Map<String, dynamic>? details}) async {
    await repository.logEvent(actionType, details: details);
  }
}
