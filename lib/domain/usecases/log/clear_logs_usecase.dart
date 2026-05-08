import '../../repositories/security_log_repository.dart';

/// Использование: Очистка всех логов безопасности.
///
/// Полностью удаляет содержимое таблицы `security_logs`. Используется на
/// экране настроек по запросу владельца профиля.
class ClearLogsUseCase {
  const ClearLogsUseCase(this.repository);
  final SecurityLogRepository repository;

  Future<void> execute() {
    return repository.clearAll();
  }
}
