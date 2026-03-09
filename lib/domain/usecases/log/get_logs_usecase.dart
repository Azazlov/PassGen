import '../../entities/security_log.dart';
import '../../repositories/security_log_repository.dart';

/// Использование: Получение логов безопасности
class GetLogsUseCase {
  const GetLogsUseCase(this.repository);
  final SecurityLogRepository repository;

  Future<List<SecurityLog>> execute({int limit = 1000}) async {
    return repository.getLogs(limit: limit);
  }
}
