import '../../entities/security_log.dart';
import '../../repositories/security_log_repository.dart';

/// Использование: Получение логов безопасности
class GetLogsUseCase {
  final SecurityLogRepository repository;

  const GetLogsUseCase(this.repository);

  Future<List<SecurityLog>> execute({int limit = 1000}) async {
    return await repository.getLogs(limit: limit);
  }
}
