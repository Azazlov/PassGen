# План функционального тестирования PassGen
## Functional Testing Plan

**Версия:** 0.5.2  
**Дата составления:** 2 апреля 2026  
**Статус:** ✅ Готов к выполнению

---

## 📋 Содержание

1. [Обзор тестирования](#обзор-тестирования)
2. [Области тестирования](#области-тестирования)
3. [Тест-кейсы по модулям](#тест-кейсы-по-модулям)
4. [Интеграционное тестирование](#интеграционное-тестирование)
5. [Регрессионное тестирование](#регрессионное-тестирование)
6. [Автоматизация тестов](#автоматизация-тестов)
7. [Отчётность](#отчётность)

---

## 📊 Обзор тестирования

### Цели тестирования

1. **Проверка функциональности** — все функции работают согласно ТЗ
2. **Проверка надёжности** — приложение стабильно работает
3. **Проверка безопасности** — данные защищены корректно
4. **Проверка совместимости** — работает на всех платформах

### Стратегия тестирования

```
┌─────────────────────────────────────────────────────────┐
│                  Unit Tests (33 теста)                  │
│            Тестирование отдельных функций               │
├─────────────────────────────────────────────────────────┤
│               Widget Tests (82% покрытие)               │
│          Тестирование UI компонентов и виджетов         │
├─────────────────────────────────────────────────────────┤
│              Integration Tests (в разработке)           │
│       Тестирование взаимодействия между модулями        │
├─────────────────────────────────────────────────────────┤
│                  Manual Testing (ручное)                │
│        Тестирование пользовательских сценариев          │
└─────────────────────────────────────────────────────────┘
```

### Метрики качества

| Метрика | Целевое значение | Текущее значение |
|---------|------------------|------------------|
| **Unit тесты** | 100% критических путей | 33/33 ✅ |
| **Widget тесты** | >80% покрытие | 82% ✅ |
| **Integration тесты** | >50% сценариев | 🔄 В разработке |
| **Критические баги** | 0 | 0 ✅ |
| **Высокие баги** | <5 | 0 ✅ |

---

## 🎯 Области тестирования

### 1. Аутентификация (Auth)

**Файлы:**
- `lib/presentation/features/auth/auth_screen.dart`
- `lib/presentation/features/auth/auth_controller.dart`
- `lib/data/datasources/auth_local_datasource.dart`

**Функции:**
- Установка PIN-кода
- Проверка PIN-кода
- Смена PIN-кода
- Удаление PIN-кода
- Блокировка после неудачных попыток

### 2. Генератор паролей (Generator)

**Файлы:**
- `lib/presentation/features/generator/generator_screen.dart`
- `lib/presentation/features/generator/generator_controller.dart`
- `lib/data/datasources/password_generator_local_datasource.dart`

**Функции:**
- Генерация пароля
- Выбор сложности
- Выбор категории символов
- Оценка надёжности
- Сохранение пароля

### 3. Хранилище паролей (Storage)

**Файлы:**
- `lib/presentation/features/storage/storage_screen.dart`
- `lib/presentation/features/storage/storage_controller.dart`
- `lib/data/datasources/storage_local_datasource.dart`

**Функции:**
- Просмотр списка паролей
- Поиск по сервису
- Фильтрация по категории
- Создание пароля
- Редактирование пароля
- Удаление пароля
- Копирование пароля

### 4. Импорт/Экспорт (Import/Export)

**Файлы:**
- `lib/data/formats/passgen_format.dart`
- `lib/data/datasources/storage_local_datasource.dart`

**Функции:**
- Экспорт в JSON
- Экспорт в .passgen
- Импорт из JSON
- Импорт из .passgen
- Проверка на дубликаты

### 5. Шифратор сообщений (Encryptor)

**Файлы:**
- `lib/presentation/features/encryptor/encryptor_screen.dart`
- `lib/data/datasources/encryptor_local_datasource.dart`

**Функции:**
- Шифрование сообщения
- Расшифровка сообщения
- Копирование результата

### 6. Настройки (Settings)

**Файлы:**
- `lib/presentation/features/settings/settings_screen.dart`
- `lib/presentation/features/settings/settings_controller.dart`

**Функции:**
- Смена PIN
- Удаление PIN
- Просмотр логов
- О приложении

### 7. Категории (Categories)

**Файлы:**
- `lib/presentation/features/categories/categories_screen.dart`
- `lib/presentation/features/categories/categories_controller.dart`

**Функции:**
- Просмотр категорий
- Создание категории
- Редактирование категории
- Удаление категории

### 8. Логи безопасности (Logs)

**Файлы:**
- `lib/presentation/features/logs/logs_screen.dart`
- `lib/presentation/features/logs/logs_controller.dart`

**Функции:**
- Просмотр логов
- Фильтрация по типу
- Очистка старых логов

---

## 🧪 Тест-кейсы по модулям

### 1. Аутентификация (Auth)

#### TC-AUTH-001: Установка PIN-кода

**Предусловие:** PIN не установлен  
**Шаги:**
1. Запустить приложение
2. Ввести PIN из 4 цифр (например, "1234")
3. Нажать "Подтвердить"
4. Ввести PIN повторно
5. Нажать "Подтвердить"

**Ожидаемый результат:**
- ✅ PIN установлен
- ✅ Переход на главный экран
- ✅ В БД сохранены hash и salt

**Проверка:**
```dart
test('Установка PIN из 4 цифр', () async {
  final authDataSource = AuthLocalDataSource(database: db);
  final result = await authDataSource.setupPin('1234');
  expect(result, true);
  
  final isSetup = await authDataSource.isPinSetup();
  expect(isSetup, true);
});
```

---

#### TC-AUTH-002: Проверка PIN-кода (успешно)

**Предусловие:** PIN установлен  
**Шаги:**
1. Запустить приложение
2. Ввести правильный PIN
3. Нажать "Подтвердить"

**Ожидаемый результат:**
- ✅ Успешная аутентификация
- ✅ Переход на главный экран
- ✅ Сброс счётчика неудачных попыток

**Проверка:**
```dart
test('Проверка правильного PIN', () async {
  final authDataSource = AuthLocalDataSource(database: db);
  await authDataSource.setupPin('1234');
  
  final result = await authDataSource.verifyPin('1234');
  expect(result['result'], 'success');
  expect(result['isLocked'], false);
});
```

---

#### TC-AUTH-003: Проверка PIN-кода (неуспешно)

**Предусловие:** PIN установлен  
**Шаги:**
1. Запустить приложение
2. Ввести неправильный PIN
3. Нажать "Подтвердить"
4. Повторить 5 раз

**Ожидаемый результат:**
- ❌ Ошибка "Неверный PIN"
- 🔒 Блокировка после 5 попытки
- ⏱️ Таймер блокировки: 30 секунд

**Проверка:**
```dart
test('Блокировка после 5 неудачных попыток', () async {
  final authDataSource = AuthLocalDataSource(database: db);
  await authDataSource.setupPin('1234');
  
  // 5 неудачных попыток
  for (int i = 0; i < 5; i++) {
    await authDataSource.verifyPin('0000');
  }
  
  final state = await authDataSource.getAuthState();
  expect(state['isLocked'], true);
  expect(state['remainingAttempts'], 0);
});
```

---

#### TC-AUTH-004: Смена PIN-кода

**Предусловие:** PIN установлен  
**Шаги:**
1. Открыть настройки
2. Нажать "Сменить PIN"
3. Ввести старый PIN
4. Ввести новый PIN
5. Ввести новый PIN повторно
6. Нажать "Подтвердить"

**Ожидаемый результат:**
- ✅ PIN изменён
- ✅ Старый PIN не работает
- ✅ Новый PIN работает

**Проверка:**
```dart
test('Смена PIN-кода', () async {
  final authDataSource = AuthLocalDataSource(database: db);
  await authDataSource.setupPin('1234');
  
  final result = await authDataSource.changePin('1234', '5678');
  expect(result, true);
  
  final verifyOld = await authDataSource.verifyPin('1234');
  expect(verifyOld['result'], 'notSetup'); // или 'wrongPin'
  
  final verifyNew = await authDataSource.verifyPin('5678');
  expect(verifyNew['result'], 'success');
});
```

---

#### TC-AUTH-005: Удаление PIN-кода

**Предусловие:** PIN установлен  
**Шаги:**
1. Открыть настройки
2. Нажать "Удалить PIN"
3. Ввести текущий PIN
4. Нажать "Подтвердить"

**Ожидаемый результат:**
- ✅ PIN удалён
- ✅ При следующем запуске не требуется аутентификация

**Проверка:**
```dart
test('Удаление PIN-кода', () async {
  final authDataSource = AuthLocalDataSource(database: db);
  await authDataSource.setupPin('1234');
  
  final result = await authDataSource.removePin('1234');
  expect(result, true);
  
  final isSetup = await authDataSource.isPinSetup();
  expect(isSetup, false);
});
```

---

#### TC-AUTH-006: Неверный формат PIN

**Предусловие:** PIN не установлен или установлен  
**Шаги:**
1. Запустить приложение
2. Ввести PIN из 3 цифр ("123")
3. Нажать "Подтвердить"

**Ожидаемый результат:**
- ❌ Ошибка "PIN должен содержать 4-8 цифр"
- ✅ Кнопка "Подтвердить" неактивна

**Проверка:**
```dart
test('Неверный формат PIN (3 цифры)', () async {
  final authDataSource = AuthLocalDataSource(database: db);
  final isValid = authDataSource.isValidPinFormat('123');
  expect(isValid, false);
});

test('Неверный формат PIN (буквы)', () async {
  final authDataSource = AuthLocalDataSource(database: db);
  final isValid = authDataSource.isValidPinFormat('12ab');
  expect(isValid, false);
});
```

---

### 2. Генератор паролей (Generator)

#### TC-GEN-001: Генерация пароля (Стандартный)

**Предусловие:** Открыт экран генератора  
**Шаги:**
1. Выбрать сложность "Стандартный"
2. Нажать "Сгенерировать"

**Ожидаемый результат:**
- ✅ Пароль сгенерирован
- ✅ Длина: 12 символов
- ✅ Содержит a-z, A-Z, 0-9
- ✅ Надёжность: 2-3 из 4

**Проверка:**
```dart
test('Генерация пароля (Стандартный)', () async {
  final generator = PasswordGeneratorLocalDataSource();
  final settings = PasswordGenerationSettings(
    strength: 2,
    lengthRange: (12, 12),
    flags: 0b111, // a-z, A-Z, 0-9
  );
  
  final result = await generator.generate(settings);
  expect(result.password.length, 12);
  expect(result.strength, greaterThanOrEqualTo(2));
});
```

---

#### TC-GEN-002: Генерация пароля (Максимальный)

**Предусловие:** Открыт экран генератора  
**Шаги:**
1. Выбрать сложность "Максимальный"
2. Нажать "Сгенерировать"

**Ожидаемый результат:**
- ✅ Пароль сгенерирован
- ✅ Длина: 20 символов
- ✅ Содержит все категории
- ✅ Надёжность: 4 из 4

**Проверка:**
```dart
test('Генерация пароля (Максимальный)', () async {
  final generator = PasswordGeneratorLocalDataSource();
  final settings = PasswordGenerationSettings(
    strength: 4,
    lengthRange: (20, 20),
    flags: 0b1111, // все категории
  );
  
  final result = await generator.generate(settings);
  expect(result.password.length, 20);
  expect(result.strength, 4);
});
```

---

#### TC-GEN-003: Сохранение пароля

**Предусловие:** Пароль сгенерирован  
**Шаги:**
1. Нажать "Сохранить"
2. Выбрать категорию
3. Ввести название сервиса
4. Ввести логин (опционально)
5. Нажать "Сохранить"

**Ожидаемый результат:**
- ✅ Пароль сохранён в БД
- ✅ Пароль зашифрован
- ✅ Конфигурация сохранена

**Проверка:**
```dart
test('Сохранение пароля в БД', () async {
  final storage = StorageRepositoryImpl(dataSource);
  final entry = PasswordEntry(
    service: 'Test Service',
    login: 'test@example.com',
    password: 'GeneratedPassword123!',
    categoryId: 1,
  );
  
  final result = await storage.create(entry);
  expect(result, true);
  
  final passwords = await storage.getAll();
  expect(passwords.length, greaterThan(0));
  expect(passwords.first.service, 'Test Service');
});
```

---

### 3. Хранилище паролей (Storage)

#### TC-STOR-001: Просмотр списка паролей

**Предусловие:** В БД есть пароли  
**Шаги:**
1. Открыть вкладку "Хранилище"
2. Просмотреть список

**Ожидаемый результат:**
- ✅ Отображаются все пароли
- ✅ Показано название сервиса
- ✅ Показан логин
- ✅ Пароль скрыт (звёздочки)

**Проверка:**
```dart
test('Просмотр списка паролей', () async {
  final storage = StorageRepositoryImpl(dataSource);
  final passwords = await storage.getAll();
  
  expect(passwords, isA<List<PasswordEntry>>());
  expect(passwords.length, greaterThan(0));
});
```

---

#### TC-STOR-002: Поиск по сервису

**Предусловие:** В БД есть пароли  
**Шаги:**
1. Открыть вкладку "Хранилище"
2. Ввести название сервиса в поиск
3. Нажать Enter

**Ожидаемый результат:**
- ✅ Отображаются только совпадения
- ✅ Поиск регистронезависимый

**Проверка:**
```dart
test('Поиск по сервису', () async {
  final storage = StorageRepositoryImpl(dataSource);
  final passwords = await storage.searchByService('google');
  
  for (final p in passwords) {
    expect(p.service.toLowerCase(), contains('google'));
  }
});
```

---

#### TC-STOR-003: Фильтрация по категории

**Предусловие:** В БД есть пароли в разных категориях  
**Шаги:**
1. Открыть вкладку "Хранилище"
2. Выбрать категорию из фильтра
3. Просмотреть список

**Ожидаемый результат:**
- ✅ Отображаются пароли выбранной категории
- ✅ Счётчик показывает количество

**Проверка:**
```dart
test('Фильтрация по категории', () async {
  final storage = StorageRepositoryImpl(dataSource);
  final passwords = await storage.getByCategory(1);
  
  for (final p in passwords) {
    expect(p.categoryId, 1);
  }
});
```

---

#### TC-STOR-004: Копирование пароля

**Предусловие:** Открыт пароль в хранилище  
**Шаги:**
1. Нажать на иконку копирования
2. Подождать 1-2 секунды

**Ожидаемый результат:**
- ✅ Пароль скопирован в буфер обмена
- ✅ Уведомление "Скопировано"
- ✅ Таймер очистки: 60 секунд

**Проверка:**
```dart
test('Копирование пароля в буфер', () async {
  // Требуется mock Clipboard
  final password = 'TestPassword123';
  Clipboard.setData(ClipboardData(text: password));
  
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  expect(data?.text, password);
});
```

---

#### TC-STOR-005: Удаление пароля

**Предусловие:** Открыт пароль в хранилище  
**Шаги:**
1. Нажать на иконку удаления
2. Подтвердить в диалоге

**Ожидаемый результат:**
- ✅ Пароль удалён из БД
- ✅ Список обновился
- ✅ Лог добавлен

**Проверка:**
```dart
test('Удаление пароля', () async {
  final storage = StorageRepositoryImpl(dataSource);
  
  // Создать тестовый пароль
  final entry = PasswordEntry(
    service: 'Delete Test',
    password: 'Test123',
    categoryId: 1,
  );
  await storage.create(entry);
  
  // Найти и удалить
  final passwords = await storage.searchByService('Delete Test');
  expect(passwords.length, 1);
  
  // Удалить (через контроллер или напрямую)
  // ... код удаления
  
  // Проверить удаление
  final afterDelete = await storage.searchByService('Delete Test');
  expect(afterDelete.length, 0);
});
```

---

### 4. Импорт/Экспорт (Import/Export)

#### TC-IMP-001: Экспорт в JSON

**Предусловие:** В БД есть пароли  
**Шаги:**
1. Открыть настройки
2. Нажать "Экспорт в JSON"
3. Выбрать место сохранения

**Ожидаемый результат:**
- ✅ Файл сохранён
- ✅ Формат: JSON minified
- ✅ Все пароли экспортированы

**Проверка:**
```dart
test('Экспорт в JSON', () async {
  final exporter = PasswordExportRepositoryImpl(dataSource);
  final json = await exporter.exportJson();
  
  expect(json, isA<String>());
  expect(json, contains('passwords'));
  
  final decoded = jsonDecode(json);
  expect(decoded['passwords'], isA<List>());
});
```

---

#### TC-IMP-002: Импорт из JSON

**Предусловие:** Есть файл JSON с паролями  
**Шаги:**
1. Открыть настройки
2. Нажать "Импорт из JSON"
3. Выбрать файл
4. Подтвердить импорт

**Ожидаемый результат:**
- ✅ Пароли импортированы
- ✅ Дубликаты пропущены
- ✅ Лог добавлен

**Проверка:**
```dart
test('Импорт из JSON', () async {
  final importer = PasswordImportRepositoryImpl(dataSource);
  final json = '''
  {
    "passwords": [
      {"service": "Test", "password": "Test123", "category_id": 1}
    ]
  }
  ''';
  
  final result = await importer.importJson(json);
  expect(result, true);
});
```

---

#### TC-IMP-003: Экспорт в .passgen

**Предусловие:** В БД есть пароли  
**Шаги:**
1. Открыть настройки
2. Нажать "Экспорт в .passgen"
3. Ввести мастер-пароль
4. Выбрать место сохранения

**Ожидаемый результат:**
- ✅ Файл сохранён в формате .passgen
- ✅ Данные зашифрованы
- ✅ HEADER: "PASSGEN_V1"

**Проверка:**
```dart
test('Экспорт в .passgen', () async {
  final exporter = PasswordExportRepositoryImpl(dataSource);
  final data = await exporter.exportPassgen('MasterPassword123');
  
  expect(data, isA<String>());
  expect(data.length, greaterThan(0));
  
  // Проверка формата
  final bytes = base64Decode(data);
  final header = String.fromCharCodes(bytes.sublist(0, 10));
  expect(header, 'PASSGEN_V1');
});
```

---

#### TC-IMP-004: Импорт из .passgen

**Предусловие:** Есть файл .passgen  
**Шаги:**
1. Открыть настройки
2. Нажать "Импорт из .passgen"
3. Выбрать файл
4. Ввести мастер-пароль
5. Подтвердить импорт

**Ожидаемый результат:**
- ✅ Пароли импортированы
- ✅ Данные расшифрованы
- ✅ Дубликаты пропущены

**Проверка:**
```dart
test('Импорт из .passgen', () async {
  final importer = PasswordImportRepositoryImpl(dataSource);
  
  // Сначала экспортируем
  final exporter = PasswordExportRepositoryImpl(dataSource);
  final data = await exporter.exportPassgen('MasterPassword123');
  
  // Затем импортируем
  final result = await importer.importPassgen(data, 'MasterPassword123');
  expect(result, true);
});
```

---

#### TC-IMP-005: Импорт с дубликатами

**Предусловие:** Есть файл с паролями, некоторые существуют  
**Шаги:**
1. Открыть настройки
2. Нажать "Импорт из JSON"
3. Выбрать файл с дубликатами
4. Подтвердить импорт

**Ожидаемый результат:**
- ✅ Существующие пароли пропущены
- ✅ Новые пароли импортированы
- ✅ Уведомление о дубликатах

**Проверка:**
```dart
test('Импорт с проверкой на дубликаты', () async {
  final importer = PasswordImportRepositoryImpl(dataSource);
  
  // Создать существующий пароль
  await storage.create(PasswordEntry(
    service: 'Existing',
    login: 'test@example.com',
    password: 'Pass123',
    categoryId: 1,
  ));
  
  // Импортировать с дубликатом
  final json = '''
  {
    "passwords": [
      {"service": "Existing", "login": "test@example.com", "password": "NewPass", "category_id": 1},
      {"service": "New", "password": "NewPass2", "category_id": 1}
    ]
  }
  ''';
  
  final result = await importer.importJson(json);
  expect(result, true);
  
  // Проверить, что дубликат пропущен
  final existing = await storage.searchByService('Existing');
  expect(existing.first.password, 'Pass123'); // старый пароль
});
```

---

### 5. Шифратор сообщений (Encryptor)

#### TC-ENC-001: Шифрование сообщения

**Предусловие:** Открыт экран шифратора  
**Шаги:**
1. Ввести сообщение
2. Ввести пароль
3. Нажать "Зашифровать"

**Ожидаемый результат:**
- ✅ Сообщение зашифровано
- ✅ Результат отображается
- ✅ Можно скопировать

**Проверка:**
```dart
test('Шифрование сообщения', () async {
  final encryptor = EncryptorLocalDataSource();
  final message = 'Hello, World!';
  final password = 'SecretPassword123';
  
  final result = await encryptor.encrypt(
    message: message.codeUnits,
    password: password.codeUnits,
  );
  
  expect(result['cipherText'], isA<String>());
  expect(result['nonce'], isA<String>());
});
```

---

#### TC-ENC-002: Расшифровка сообщения

**Предусловие:** Есть зашифрованное сообщение  
**Шаги:**
1. Вставить зашифрованное сообщение
2. Ввести пароль
3. Нажать "Расшифровать"

**Ожидаемый результат:**
- ✅ Сообщение расшифровано
- ✅ Исходный текст отображается

**Проверка:**
```dart
test('Расшифровка сообщения', () async {
  final encryptor = EncryptorLocalDataSource();
  final message = 'Hello, World!';
  final password = 'SecretPassword123';
  
  // Зашифровать
  final encrypted = await encryptor.encrypt(
    message: message.codeUnits,
    password: password.codeUnits,
  );
  
  // Расшифровать
  final decrypted = await encryptor.decrypt(
    cipherText: encrypted['cipherText'] as String,
    nonce: encrypted['nonce'] as String,
    password: password.codeUnits,
  );
  
  expect(String.fromCharCodes(decrypted), message);
});
```

---

#### TC-ENC-003: Расшифровка с неверным паролем

**Предусловие:** Есть зашифрованное сообщение  
**Шаги:**
1. Вставить зашифрованное сообщение
2. Ввести неверный пароль
3. Нажать "Расшифровать"

**Ожидаемый результат:**
- ❌ Ошибка "Неверный пароль или повреждённые данные"
- ✅ Сообщение не расшифровано

**Проверка:**
```dart
test('Расшифровка с неверным паролем', () async {
  final encryptor = EncryptorLocalDataSource();
  final message = 'Hello, World!';
  final password = 'SecretPassword123';
  final wrongPassword = 'WrongPassword456';
  
  // Зашифровать
  final encrypted = await encryptor.encrypt(
    message: message.codeUnits,
    password: password.codeUnits,
  );
  
  // Попытаться расшифровать неверным паролем
  try {
    await encryptor.decrypt(
      cipherText: encrypted['cipherText'] as String,
      nonce: encrypted['nonce'] as String,
      password: wrongPassword.codeUnits,
    );
    fail('Должна быть ошибка');
  } catch (e) {
    expect(e, isA<Exception>());
  }
});
```

---

### 6. Настройки (Settings)

#### TC-SET-001: Просмотр логов безопасности

**Предусловие:** Есть логи в БД  
**Шаги:**
1. Открыть настройки
2. Нажать "Журнал событий"
3. Просмотреть логи

**Ожидаемый результат:**
- ✅ Логи отображаются
- ✅ Показано время события
- ✅ Показан тип события

**Проверка:**
```dart
test('Просмотр логов безопасности', () async {
  final logRepo = SecurityLogRepositoryImpl();
  final logs = await logRepo.getLogs();
  
  expect(logs, isA<List<SecurityLog>>());
  expect(logs.length, greaterThan(0));
});
```

---

### 7. Категории (Categories)

#### TC-CAT-001: Создание категории

**Предусловие:** Открыт экран категорий  
**Шаги:**
1. Нажать "Добавить категорию"
2. Ввести название
3. Выбрать иконку
4. Нажать "Сохранить"

**Ожидаемый результат:**
- ✅ Категория создана
- ✅ Отображается в списке
- ✅ Можно выбрать для пароля

**Проверка:**
```dart
test('Создание категории', () async {
  final categoryRepo = CategoryRepositoryImpl(dataSource);
  final category = Category(
    name: 'Test Category',
    icon: '📁',
    isSystem: false,
  );
  
  final result = await categoryRepo.create(category);
  expect(result, true);
  
  final categories = await categoryRepo.getAll();
  expect(categories.any((c) => c.name == 'Test Category'), true);
});
```

---

#### TC-CAT-002: Удаление категории

**Предусловие:** Есть пользовательская категория  
**Шаги:**
1. Открыть экран категорий
2. Нажать "Удалить" на категории
3. Подтвердить

**Ожидаемый результат:**
- ✅ Категория удалена
- ✅ Пароли перенесены в "Другое"
- ✅ Системные категории нельзя удалить

**Проверка:**
```dart
test('Удаление категории', () async {
  final categoryRepo = CategoryRepositoryImpl(dataSource);
  
  // Создать тестовую категорию
  final category = Category(name: 'Delete Me', icon: '🗑️', isSystem: false);
  await categoryRepo.create(category);
  
  // Найти и удалить
  final categories = await categoryRepo.getAll();
  final toDelete = categories.firstWhere((c) => c.name == 'Delete Me');
  
  final result = await categoryRepo.delete(toDelete.id!);
  expect(result, true);
  
  // Проверить удаление
  final afterDelete = await categoryRepo.getAll();
  expect(afterDelete.any((c) => c.name == 'Delete Me'), false);
});
```

---

## 🔗 Интеграционное тестирование

### Сценарий 1: Полный цикл работы с паролем

**Шаги:**
1. Установить PIN
2. Войти по PIN
3. Сгенерировать пароль
4. Сохранить пароль
5. Найти пароль в хранилище
6. Скопировать пароль
7. Удалить пароль
8. Выйти из приложения
9. Войти по PIN
10. Проверить, что пароль удалён

**Ожидаемый результат:**
- ✅ Все шаги выполнены успешно
- ✅ Данные сохраняются между сессиями
- ✅ Удаление работает корректно

---

### Сценарий 2: Импорт/Экспорт цикл

**Шаги:**
1. Создать 3 тестовых пароля
2. Экспортировать в JSON
3. Удалить все пароли
4. Импортировать из JSON
5. Проверить, что все 3 пароля восстановлены

**Ожидаемый результат:**
- ✅ Экспорт работает
- ✅ Импорт работает
- ✅ Данные восстановлены полностью

---

### Сценарий 3: Смена PIN с ротацией ключей

**Шаги:**
1. Установить PIN
2. Создать 2 пароля
3. Сменить PIN
4. Войти по новому PIN
5. Проверить, что старые пароли расшифровываются

**Ожидаемый результат:**
- ✅ Смена PIN работает
- ✅ Ключи ротированы
- ✅ Старые пароли доступны

---

## 🔄 Регрессионное тестирование

### Критические пути (обязательно перед каждым релизом)

- [ ] TC-AUTH-001: Установка PIN
- [ ] TC-AUTH-002: Проверка PIN
- [ ] TC-AUTH-003: Блокировка после 5 попыток
- [ ] TC-GEN-001: Генерация пароля
- [ ] TC-GEN-003: Сохранение пароля
- [ ] TC-STOR-001: Просмотр списка паролей
- [ ] TC-STOR-004: Копирование пароля
- [ ] TC-IMP-004: Импорт из .passgen
- [ ] TC-ENC-002: Расшифровка сообщения

### Платформы для регрессии

| Платформа | Версия | Статус |
|-----------|--------|--------|
| **Windows** | 10/11 | ✅ Тестировать |
| **Linux** | Ubuntu 20.04+ | ✅ Тестировать |
| **macOS** | 11+ | ✅ Тестировать |
| **Android** | 10+ | ✅ Тестировать |

---

## 🤖 Автоматизация тестов

### Существующие тесты

```
test/
├── unit/
│   ├── crypto_utils_test.dart        # ✅ 10 тестов
│   ├── integrity_and_versioning_test.dart # ✅ 23 теста
│   └── usecases/
│       └── auth/
│           └── auth_flow_test.dart   # ✅ В разработке
├── widgets/
│   ├── copyable_password_test.dart   # ✅ 82% покрытие
│   ├── character_set_display_test.dart # ✅
│   └── shimmer_effect_test.dart      # ✅
└── sqlite_test.dart                  # ✅
```

### План автоматизации

| Приоритет | Тесты | Статус |
|-----------|-------|--------|
| **High** | Аутентификация (5 тестов) | 🔄 В работе |
| **High** | Генерация паролей (4 теста) | ✅ Готово |
| **High** | Хранение паролей (6 тестов) | 🔄 В работе |
| **Medium** | Импорт/Экспорт (5 тестов) | ⏳ Ожидает |
| **Medium** | Шифрование (3 теста) | ✅ Готово |
| **Low** | Настройки (3 теста) | ⏳ Ожидает |
| **Low** | Категории (4 теста) | ⏳ Ожидает |

### Запуск тестов

```bash
# Все тесты
flutter test

# Конкретный тест
flutter test test/unit/crypto_utils_test.dart

# С покрытием
flutter test --coverage

# Генерация отчёта
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📊 Отчётность

### Шаблон отчёта о тестировании

```markdown
# Отчёт о тестировании PassGen v0.5.2

**Дата:** 2026-04-02  
**Тестировщик:** <имя>  
**Платформа:** <Windows/Linux/macOS/Android>

## Резюме

| Метрика | Значение |
|---------|----------|
| **Всего тестов** | 50 |
| **Пройдено** | 48 |
| **Провалено** | 2 |
| **Покрытие кода** | 82% |

## Найденные баги

| ID | Описание | Критичность | Статус |
|----|----------|-------------|--------|
| #001 | ... | High | ✅ Исправлено |
| #002 | ... | Medium | 🔄 В работе |

## Рекомендации

1. ...
2. ...
```

### Матрица тестирования

| Модуль | Unit | Widget | Integration | Manual | Статус |
|--------|------|--------|-------------|--------|--------|
| **Auth** | ✅ | ✅ | 🔄 | ✅ | 80% |
| **Generator** | ✅ | ✅ | ⏳ | ✅ | 90% |
| **Storage** | ✅ | ✅ | 🔄 | ✅ | 85% |
| **Import/Export** | ✅ | ⏳ | ⏳ | ✅ | 70% |
| **Encryptor** | ✅ | ⏳ | ⏳ | ✅ | 75% |
| **Settings** | ⏳ | ⏳ | ⏳ | ✅ | 60% |
| **Categories** | ✅ | ⏳ | ⏳ | ✅ | 70% |
| **Logs** | ⏳ | ⏳ | ⏳ | ✅ | 60% |

**Общее покрытие:** 75%

---

## 📅 Расписание тестирования

| Этап | Длительность | Ответственный | Дедлайн |
|------|--------------|---------------|---------|
| 1. Unit тесты | 4 часа | QA Engineer | День 1 |
| 2. Widget тесты | 4 часа | QA Engineer | День 2 |
| 3. Integration тесты | 8 часов | QA Engineer | День 3-4 |
| 4. Manual тесты | 8 часов | QA Engineer | День 5-6 |
| 5. Отчётность | 2 часа | QA Engineer | День 7 |

**Общая длительность:** 26 часов  
**Рекомендуемая частота:** Перед каждым релизом

---

## 📞 Контакты

При обнаружении багов:
- **GitHub Issues:** https://github.com/azazlov/passgen/issues
- **Jira:** (если используется)

---

## 📄 Лицензия

MIT License — см. файл [LICENSE](../LICENSE)
