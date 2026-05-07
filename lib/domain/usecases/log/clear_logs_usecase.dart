import '../../repositories/security_log_repository.dart';

/// Use case для полной очистки журнала событий безопасности.
class ClearLogsUseCase {
  const ClearLogsUseCase(this.repository);

  final SecurityLogRepository repository;

  Future<void> execute() {
    return repository.clearAll();
  }
}
