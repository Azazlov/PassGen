# 📋 План Этапа 8: Критические исправления ТЗ

**Дата создания:** 2026-03-08  
**Версия:** 1.0  
**Статус:** ⏳ В работе  
**Приоритет:** 🔴 Критический

---

## 1. ЦЕЛЬ ЭТАПА

Устранить критические пробелы в соответствии с ТЗ для повышения готовности проекта до ~95%.

---

## 2. ЗАДАЧИ

### 2.1 Критические (🔴)

| № | Задача | Оценка | Статус | ТЗ раздел |
|---|--------|--------|--------|-----------|
| 8.1 | Очистка буфера обмена (60 сек) | 2 часа | ✅ Выполнено | 6.6 |
| 8.2 | Логирование PWD_ACCESSED | 1 час | ⏳ В работе | 3.4 |
| 8.3 | Логирование SETTINGS_CHG | 1 час | ⏳ В работе | 3.4 |
| 8.4 | Опция «Без повторяющихся символов» | 4 часа | ⬜ Ожидает | 5.5 |
| 8.5 | Опция «Исключить похожие символы» | 4 часа | ⬜ Ожидает | 5.5 |

**Итого:** 12 часов

---

## 3. ДЕТАЛЬНОЕ ОПИСАНИЕ ЗАДАЧ

### 3.1 Задача 8.1: Очистка буфера обмена через 60 секунд ✅

**Файлы:**
- `lib/presentation/widgets/copyable_password.dart`

**Реализация:**
```dart
// Уже реализовано в CopyablePassword._copyToClipboard()
void _copyToClipboard() {
  Clipboard.setData(ClipboardData(text: _text));
  ScaffoldMessenger.of(context).showSnackBar(...);
  
  // Очистка через 60 секунд
  Future.delayed(Duration(seconds: 60), () {
    Clipboard.setData(ClipboardData(text: ''));
  });
}
```

**Проверка:**
- [x] Таймер запускается после копирования
- [x] Буфер очищается через 60 секунд
- [x] Пользователь получает уведомление

**Статус:** ✅ Выполнено

---

### 3.2 Задача 8.2: Логирование PWD_ACCESSED (просмотр пароля)

**Файлы для обновления:**
1. `lib/core/constants/event_types.dart`
2. `lib/presentation/features/storage/storage_controller.dart`
3. `lib/presentation/features/storage/storage_screen.dart`

**Реализация:**

#### Шаг 1: Добавить константу
```dart
// lib/core/constants/event_types.dart
class EventTypes {
  static const String AUTH_SUCCESS = 'AUTH_SUCCESS';
  static const String AUTH_FAIL = 'AUTH_FAIL';
  static const String LOGOUT = 'LOGOUT';
  static const String PWD_CREATED = 'PWD_CREATED';
  static const String PWD_DELETED = 'PWD_DELETED';
  static const String PWD_UPDATED = 'PWD_UPDATED';
  static const String PWD_ACCESSED = 'PWD_ACCESSED'; // ← Добавить
  static const String EXPORT = 'EXPORT';
  static const String IMPORT = 'IMPORT';
  static const String SETTINGS_CHG = 'SETTINGS_CHG'; // ← Также добавить
}
```

#### Шаг 2: Логирование в контроллере
```dart
// lib/presentation/features/storage/storage_controller.dart
Future<void> viewPassword(PasswordEntry entry) async {
  // ... логика просмотра ...
  
  // Логирование события
  await logEventUseCase.execute(
    actionType: EventTypes.PWD_ACCESSED,
    details: 'Просмотр пароля: ${entry.service}',
  );
}
```

**Проверка:**
- [ ] Константа добавлена
- [ ] Логирование вызывается при просмотре
- [ ] Событие отображается в журнале

**Статус:** ⏳ В работе

---

### 3.3 Задача 8.3: Логирование SETTINGS_CHG (изменение настроек)

**Файлы для обновления:**
1. `lib/core/constants/event_types.dart`
2. `lib/presentation/features/settings/settings_controller.dart`

**Реализация:**

#### Шаг 1: Добавить константу
```dart
// lib/core/constants/event_types.dart (см. выше)
static const String SETTINGS_CHG = 'SETTINGS_CHG';
```

#### Шаг 2: Логирование в контроллере
```dart
// lib/presentation/features/settings/settings_controller.dart
Future<void> setSetting(String key, String value, {bool encrypted = false}) async {
  await setSettingUseCase.execute(key, value, encrypted);
  
  // Логирование изменения
  await logEventUseCase.execute(
    actionType: EventTypes.SETTINGS_CHG,
    details: 'Изменение настройки: $key = $value',
  );
  
  notifyListeners();
}
```

**Проверка:**
- [ ] Константа добавлена
- [ ] Логирование вызывается при изменении настроек
- [ ] Событие отображается в журнале

**Статус:** ⏳ В работе

---

### 3.4 Задача 8.4: Опция «Без повторяющихся символов»

**Файлы для обновления:**
1. `lib/data/datasources/password_generator_local_datasource.dart`
2. `lib/presentation/features/generator/generator_screen.dart`
3. `lib/domain/entities/password_generation_settings.dart`

**Реализация:**

#### Шаг 1: Добавить флаг в настройки
```dart
// lib/domain/entities/password_generation_settings.dart
class PasswordGenerationSettings {
  final int strength;
  final (int, int) lengthRange;
  final int flags;
  final bool requireUnique; // ← Уже существует
  final bool excludeSimilar; // ← Добавить
  
  PasswordGenerationSettings copyWith({...});
}
```

#### Шаг 2: Реализовать проверку уникальности
```dart
// lib/data/datasources/password_generator_local_datasource.dart
String generatePassword({
  required int length,
  required bool requireUnique,
  required bool excludeSimilar,
  // ...
}) {
  final chars = _getCharacterSets(flags);
  
  if (excludeSimilar) {
    // Исключить похожие символы: l, 1, I, O, 0
    chars.removeWhere((c) => 'l1I0O'.contains(c));
  }
  
  if (requireUnique) {
    // Генерация без повторов
    return _generateUniquePassword(chars, length);
  }
  
  return _generatePassword(chars, length);
}

String _generateUniquePassword(List<String> chars, int length) {
  if (length > chars.length) {
    throw ArgumentError('Длина больше количества уникальных символов');
  }
  
  final shuffled = List<String>.from(chars)..shuffle(Random.secure());
  return shuffled.take(length).join();
}
```

#### Шаг 3: Добавить UI переключатель
```dart
// lib/presentation/features/generator/generator_screen.dart
SwitchListTile(
  title: Text('Без повторяющихся символов'),
  subtitle: Text('Каждый символ используется только один раз'),
  value: _settings.requireUnique,
  onChanged: (value) {
    controller.toggleRequireUnique(value);
  },
)
```

**Проверка:**
- [ ] Флаг добавлен в настройки
- [ ] Генерация без повторов работает
- [ ] UI переключатель добавлен
- [ ] Тесты пройдены

**Статус:** ⬜ Ожидает

---

### 3.5 Задача 8.5: Опция «Исключить похожие символы»

**Файлы для обновления:**
1. `lib/data/datasources/password_generator_local_datasource.dart`
2. `lib/presentation/features/generator/generator_screen.dart`

**Реализация:**

#### Шаг 1: Исключение символов
```dart
// lib/data/datasources/password_generator_local_datasource.dart
List<String> _getCharacterSets(int flags) {
  var chars = <String>[];
  
  if (flags & 0b0001 != 0) {
    chars.addAll('abcdefghijklmnopqrstuvwxyz'.split(''));
  }
  if (flags & 0b0010 != 0) {
    chars.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
  }
  if (flags & 0b0100 != 0) {
    chars.addAll('0123456789'.split(''));
  }
  if (flags & 0b1000 != 0) {
    chars.addAll('!@#$%^&*()_+-=[]{}|;:,.<>?'.split(''));
  }
  
  return chars;
}

List<String> _excludeSimilarCharacters(List<String> chars) {
  return chars.where((c) => !'l1I0O'.contains(c)).toList();
}
```

#### Шаг 2: Добавить UI переключатель
```dart
// lib/presentation/features/generator/generator_screen.dart
SwitchListTile(
  title: Text('Исключить похожие символы'),
  subtitle: Text('l, 1, I, O, 0 не будут использоваться'),
  value: _settings.excludeSimilar,
  onChanged: (value) {
    controller.toggleExcludeSimilar(value);
  },
)
```

**Проверка:**
- [ ] Исключение символов работает
- [ ] UI переключатель добавлен
- [ ] Комбинация с requireUnique работает
- [ ] Тесты пройдены

**Статус:** ⬜ Ожидает

---

## 4. СРОКИ

| Этап | Дата | Задачи |
|------|------|--------|
| **Начало** | 2026-03-08 | 8.1, 8.2, 8.3 |
| **Продолжение** | 2026-03-09 | 8.4, 8.5 |
| **Завершение** | 2026-03-09 | Тестирование, отчёт |

---

## 5. РЕСУРСЫ

### 5.1 Файлы для создания
```
test/usecases/log_event_usecase_test.dart (опционально)
```

### 5.2 Файлы для обновления
```
lib/core/constants/event_types.dart
lib/presentation/features/storage/storage_controller.dart
lib/presentation/features/settings/settings_controller.dart
lib/data/datasources/password_generator_local_datasource.dart
lib/presentation/features/generator/generator_screen.dart
lib/domain/entities/password_generation_settings.dart
```

---

## 6. КРИТЕРИИ УСПЕХА

- [ ] Все 5 задач выполнены
- [ ] Сборка без ошибок (`flutter build`)
- [ ] Тесты пройдены (`flutter test`)
- [ ] Соответствие ТЗ повышено до ~95%
- [ ] Создан отчёт STAGE_8_COMPLETE.md

---

## 7. РИСКИ

| Риск | Вероятность | Влияние | Митигация |
|------|-------------|---------|-----------|
| Конфликты слияния | Средняя | Среднее | Частые коммиты в main |
| Проблемы с генерацией | Низкая | Высокое | Тестирование на разных длинах |
| Нехватка времени | Средняя | Высокое | Приоритизация критических задач |

---

## 8. СВЯЗАННЫЕ ДОКУМЕНТЫ

- [WORK_PLAN.md](WORK_PLAN.md) — Общий план работ
- [passgen.tz.md](passgen.tz.md) — Техническое задание
- [CURRENT_PROGRESS.md](../current_progress/CURRENT_PROGRESS.md) — Текущий прогресс

---

## 9. ИСТОРИЯ ИЗМЕНЕНИЙ

| Версия | Дата | Автор | Изменения |
|--------|------|-------|-----------|
| 1.0 | 2026-03-08 | AI | Первая версия плана |

---

**План утверждён:** _________________ / _________________  
**Дата утверждения:** _________________

**Версия:** 1.0  
**Статус:** ⏳ В работе
