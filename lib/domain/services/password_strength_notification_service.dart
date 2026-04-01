import '../entities/notification.dart';
import '../entities/password_entry.dart';
import '../repositories/storage_repository.dart';

/// Сервис уведомлений о надёжности паролей
///
/// Анализирует пароли пользователя и создаёт уведомления:
/// - О слабых паролях
/// - О повторяющихся паролях
/// - О старых паролях
class PasswordStrengthNotificationService {
  PasswordStrengthNotificationService({
    required this.storageRepository,
    this.minStrengthThreshold = 0.4,
    this.maxPasswordAgeDays = 90,
  });

  final StorageRepository storageRepository;
  
  /// Минимальный порог надёжности (0.0 - 1.0)
  final double minStrengthThreshold;
  
  /// Максимальный возраст пароля в днях
  final int maxPasswordAgeDays;

  /// Анализирует все пароли и возвращает список уведомлений
  Future<List<Notification>> analyzeAllPasswords() async {
    final notifications = <Notification>[];

    try {
      final result = await storageRepository.getPasswords();
      final passwords = result.fold(
        (failure) => throw Exception('Ошибка получения паролей: ${failure.message}'),
        (passwords) => passwords,
      );

      // Анализ на слабые пароли
      notifications.addAll(_checkWeakPasswords(passwords));

      // Анализ на повторяющиеся пароли
      notifications.addAll(_checkDuplicatePasswords(passwords));

      // Анализ на старые пароли
      notifications.addAll(_checkOldPasswords(passwords));

      return notifications;
    } catch (e) {
      // Возвращаем уведомление об ошибке анализа
      return [
        Notification.error(
          title: 'Ошибка анализа',
          message: 'Не удалось выполнить анализ паролей: $e',
        ),
      ];
    }
  }

  /// Анализирует конкретный пароль и возвращает уведомления
  Future<List<Notification>> analyzePassword(PasswordEntry entry) async {
    final notifications = <Notification>[];

    try {
      // Проверка на слабый пароль (если есть конфигурация)
      if (entry.config.isNotEmpty) {
        final strengthNotification = _checkPasswordStrength(entry);
        if (strengthNotification != null) {
          notifications.add(strengthNotification);
        }
      }

      // Проверка на дубликаты
      final result = await storageRepository.getPasswords();
      final allPasswords = result.fold(
        (failure) => <PasswordEntry>[],
        (passwords) => passwords,
      );
      final duplicates = _findDuplicates(entry, allPasswords);
      for (final duplicate in duplicates) {
        notifications.add(
          Notification.duplicatePassword(
            service: entry.service,
            entryId: entry.id!,
            duplicateService: duplicate.service,
          ),
        );
      }

      return notifications;
    } catch (e) {
      return [
        Notification.error(
          title: 'Ошибка анализа',
          message: 'Не удалось проанализировать пароль: $e',
        ),
      ];
    }
  }

  /// Проверяет пароли на слабость
  List<Notification> _checkWeakPasswords(List<PasswordEntry> passwords) {
    final notifications = <Notification>[];

    for (final password in passwords) {
      final notification = _checkPasswordStrength(password);
      if (notification != null) {
        notifications.add(notification);
      }
    }

    return notifications;
  }

  /// Проверяет надёжность конкретного пароля
  Notification? _checkPasswordStrength(PasswordEntry entry) {
    // Извлекаем strength из config
    // Формат config: strength:length:min:max:flags
    final configParts = entry.config.split(':');
    if (configParts.isEmpty) return null;

    final strength = int.tryParse(configParts[0]);
    if (strength == null) return null;

    // Нормализуем strength (0-4) в диапазон 0.0-1.0
    final normalizedStrength = strength / 4.0;

    if (normalizedStrength < minStrengthThreshold) {
      return Notification.weakPassword(
        service: entry.service,
        entryId: entry.id!,
        details: 'Надёжность: ${(normalizedStrength * 100).toInt()}% '
            '(минимум: ${(minStrengthThreshold * 100).toInt()}%)',
      );
    }

    return null;
  }

  /// Проверяет пароли на дубликаты
  List<Notification> _checkDuplicatePasswords(List<PasswordEntry> passwords) {
    final notifications = <Notification>[];
    final seenPasswords = <String, List<PasswordEntry>>{};

    // Группируем пароли по зашифрованному значению
    for (final password in passwords) {
      final key = password.encryptedPassword ?? password.password ?? '';
      if (key.isEmpty) continue;

      if (!seenPasswords.containsKey(key)) {
        seenPasswords[key] = [];
      }
      seenPasswords[key]!.add(password);
    }

    // Находим дубликаты
    for (final entries in seenPasswords.values) {
      if (entries.length > 1) {
        // Создаём уведомление для каждой записи кроме первой
        for (int i = 1; i < entries.length; i++) {
          notifications.add(
            Notification.duplicatePassword(
              service: entries[i].service,
              entryId: entries[i].id!,
              duplicateService: entries[0].service,
            ),
          );
        }
      }
    }

    return notifications;
  }

  /// Находит дубликаты для конкретного пароля
  List<PasswordEntry> _findDuplicates(
    PasswordEntry entry,
    List<PasswordEntry> allPasswords,
  ) {
    final key = entry.encryptedPassword ?? entry.password ?? '';
    if (key.isEmpty) return [];

    return allPasswords
        .where((p) =>
            p.id != entry.id &&
            (p.encryptedPassword == key || p.password == key))
        .toList();
  }

  /// Проверяет пароли на возраст
  List<Notification> _checkOldPasswords(List<PasswordEntry> passwords) {
    final notifications = <Notification>[];
    final now = DateTime.now();

    for (final password in passwords) {
      final updatedAt = password.updatedAt ?? password.createdAt;
      final ageInDays = now.difference(updatedAt).inDays;

      if (ageInDays > maxPasswordAgeDays) {
        notifications.add(
          Notification.oldPassword(
            service: password.service,
            entryId: password.id!,
            daysOld: ageInDays,
          ),
        );
      }
    }

    return notifications;
  }

  /// Создаёт сводное уведомление с результатами анализа
  Notification createSummaryNotification(List<Notification> notifications) {
    final weakCount = notifications
        .where((n) => n.type == NotificationType.weakPassword)
        .length;
    final duplicateCount = notifications
        .where((n) => n.type == NotificationType.duplicatePassword)
        .length;
    final oldCount = notifications
        .where((n) => n.type == NotificationType.oldPassword)
        .length;

    final totalIssues = weakCount + duplicateCount + oldCount;

    if (totalIssues == 0) {
      return Notification.success(
        title: 'Все пароли в порядке',
        message: 'Критических проблем с паролями не обнаружено',
      );
    }

    final message = StringBuffer('Обнаружено проблем: $totalIssues. ');
    if (weakCount > 0) message.write('Слабых: $weakCount. ');
    if (duplicateCount > 0) message.write('Дубликатов: $duplicateCount. ');
    if (oldCount > 0) message.write('Старых: $oldCount.');

    return Notification.securityWarning(
      title: 'Требуется внимание',
      message: message.toString(),
    );
  }
}
