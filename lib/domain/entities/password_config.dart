/// Конфигурация генерации пароля
class PasswordConfig {
  final int version;
  final String service;
  final DateTime? lastUsageDate;
  final String uuid;
  final String category;
  final int expireDays;
  final String encryptedConfig;

  const PasswordConfig({
    this.version = 0,
    this.service = 'None',
    this.lastUsageDate,
    required this.uuid,
    this.category = 'None',
    this.expireDays = 30,
    required this.encryptedConfig,
  });

  /// Проверяет, просрочен ли пароль
  bool get isExpired {
    if (lastUsageDate == null) return false;
    final expiryDate = lastUsageDate!.add(Duration(days: expireDays));
    return DateTime.now().isAfter(expiryDate);
  }

  /// Получение даты генерации из UUID
  DateTime get dateFromUuid {
    try {
      return DateTime(
        int.parse(uuid.substring(0, 4)),
        int.parse(uuid.substring(4, 6)),
        int.parse(uuid.substring(6, 8)),
        int.parse(uuid.substring(9, 11)),
        int.parse(uuid.substring(11, 13)),
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Копия с обновлённой датой последнего использования
  PasswordConfig copyWithUpdatedUsage() {
    return PasswordConfig(
      version: version,
      service: service,
      lastUsageDate: DateTime.now(),
      uuid: uuid,
      category: category,
      expireDays: expireDays,
      encryptedConfig: encryptedConfig,
    );
  }

  @override
  String toString() => 'PasswordConfig(service: $service, uuid: $uuid)';
}
