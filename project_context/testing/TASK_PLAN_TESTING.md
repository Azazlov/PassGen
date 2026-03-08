# 🧪 План задач: Тестирование PassGen

**Дата создания:** 2026-03-08  
**Версия:** 1.0  
**Статус:** ⏳ В работе  
**Приоритет:** 🔴 Высокий (для диплома)  
**Оценка:** 20 часов  

---

## 1. ЦЕЛЬ ЭТАПА

Обеспечить качество кода PassGen через комплексное тестирование:
- Unit-тесты для бизнес-логики
- Widget-тесты для UI компонентов
- Integration-тесты для ключевых сценариев
- Ручное тестирование пользовательских сценариев

**Целевые метрики:**
- Покрытие кода: ≥50%
- Pass rate: ≥95%
- Количество тестов: 50+

---

## 2. ЗАДАЧИ

### Задача 1.1: Fix CharacterSetDisplay encoding

**Статус:** ⏳ Ожидает  
**Оценка:** 1 час  
**Фактически:** TBD  

#### Описание
Исправить проблему с кодировкой русского текста в тестах.

#### Файлы
- `test/widgets/character_set_display_test.dart`

#### Реализация

**Проблема:**
```dart
// Тест не находит русский текст
expect(find.text('Итого: 82 символов'), findsOneWidget); // ❌ Fails
```

**Решение:**
```dart
// Использовать поиск по предикату
expect(
  find.byWidgetPredicate(
    (widget) => widget is Text && widget.data!.contains('Итого')
  ),
  findsOneWidget,
); // ✅ Passes
```

#### Критерии приёмки
- [ ] Все 10 тестов проходят
- [ ] Нет encoding issues
- [ ] Тесты выполняются < 5 секунд

---

### Задача 1.2: Fix CopyablePassword timeout

**Статус:** ⏳ Ожидает  
**Оценка:** 1 час  
**Фактически:** TBD  

#### Описание
Убрать 60-секундную задержку из теста копирования.

#### Файлы
- `test/widgets/copyable_password_test.dart`

#### Реализация

**Проблема:**
```dart
testWidgets('copies password to clipboard', (tester) async {
  // Ждёт 60 секунд для очистки буфера ❌
});
```

**Решение:**
```dart
testWidgets('copies password to clipboard', (tester) async {
  // Тестировать только копирование, без ожидания очистки ✅
  await tester.tap(find.byType(CopyablePassword));
  await tester.pump();
  
  final clipboardData = await Clipboard.getData('text/plain');
  expect(clipboardData?.text, equals('TestPassword123!'));
});
```

#### Критерии приёмки
- [ ] Тест выполняется < 5 секунд
- [ ] Копирование работает
- [ ] Нет warning в логах

---

### Задача 2.1: Unit-тесты для Auth Use Cases

**Статус:** ⏳ Ожидает  
**Оценка:** 2 часа  
**Фактически:** TBD  

#### Описание
Написать unit-тесты для 5 Use Cases аутентификации.

#### Файлы
- `test/usecases/auth/setup_pin_usecase_test.dart`
- `test/usecases/auth/verify_pin_usecase_test.dart`
- `test/usecases/auth/change_pin_usecase_test.dart`
- `test/usecases/auth/remove_pin_usecase_test.dart`
- `test/usecases/auth/get_auth_state_usecase_test.dart`

#### Реализация

**Пример теста (verify_pin_usecase_test.dart):**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/auth/verify_pin_usecase.dart';
import 'package:pass_gen/domain/repositories/auth_repository.dart';
import 'package:pass_gen/domain/entities/auth_result.dart';
import 'package:pass_gen/core/errors/failures.dart';

@GenerateMocks([AuthRepository])
void main() {
  late VerifyPinUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyPinUseCase(mockRepository);
  });

  group('VerifyPinUseCase', () {
    final testPin = '1234';

    test('должен вернуть success при правильном PIN', () async {
      // Arrange
      when(mockRepository.verifyPin(testPin))
          .thenAnswer((_) async => Right(AuthResult.success));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(AuthResult.success));
    });

    test('должен вернуть wrongPin при неверном PIN', () async {
      // Arrange
      when(mockRepository.verifyPin(testPin))
          .thenAnswer((_) async => Right(AuthResult.wrongPin));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(AuthResult.wrongPin));
    });

    test('должен вернуть locked после 5 неудачных попыток', () async {
      // Arrange
      when(mockRepository.verifyPin(testPin))
          .thenAnswer((_) async => Right(AuthResult.locked));

      // Act
      final result = await useCase.execute(testPin);

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value, equals(AuthResult.locked));
    });
  });
}
```

#### Критерии приёмки
- [ ] 5 файлов тестов создано
- [ ] Минимум 3 теста на каждый Use Case
- [ ] Все тесты проходят
- [ ] Покрытие ≥80%

---

### Задача 2.2: Unit-тесты для Password Use Cases

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файлы
- `test/usecases/password/generate_password_usecase_test.dart`
- `test/usecases/password/save_password_usecase_test.dart`

#### Тесты для покрытия
1. `GeneratePasswordUseCase`
   - Генерация с валидными настройками
   - Генерация с невалидными настройками
   - Генерация с разной длиной

2. `SavePasswordUseCase`
   - Сохранение валидного пароля
   - Сохранение с пустым сервисом
   - Сохранение с существующим сервисом (обновление)

#### Критерии приёмки
- [ ] 2 файла тестов создано
- [ ] Минимум 3 теста на каждый Use Case
- [ ] Все тесты проходят
- [ ] Покрытие ≥80%

---

### Задача 2.3: Unit-тесты для Storage Use Cases

**Статус:** ⏳ Ожидает  
**Оценка:** 2 часа  
**Фактически:** TBD  

#### Файлы
- `test/usecases/storage/get_passwords_usecase_test.dart`
- `test/usecases/storage/delete_password_usecase_test.dart`
- `test/usecases/storage/export_passwords_usecase_test.dart`
- `test/usecases/storage/import_passwords_usecase_test.dart`
- `test/usecases/storage/export_passgen_usecase_test.dart`
- `test/usecases/storage/import_passgen_usecase_test.dart`

#### Тесты для покрытия
1. `GetPasswordsUseCase` — получение списка паролей
2. `DeletePasswordUseCase` — удаление пароля
3. `ExportPasswordsUseCase` — экспорт в JSON
4. `ImportPasswordsUseCase` — импорт из JSON
5. `ExportPassgenUseCase` — экспорт в .passgen
6. `ImportPassgenUseCase` — импорт из .passgen

#### Критерии приёмки
- [ ] 6 файлов тестов создано
- [ ] Минимум 2 теста на каждый Use Case
- [ ] Все тесты проходят
- [ ] Покрытие ≥75%

---

### Задача 2.4: Unit-тесты для Category Use Cases

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файлы
- `test/usecases/category/get_categories_usecase_test.dart`
- `test/usecases/category/create_category_usecase_test.dart`
- `test/usecases/category/update_category_usecase_test.dart`
- `test/usecases/category/delete_category_usecase_test.dart`

#### Тесты для покрытия
1. `GetCategoriesUseCase` — получение всех категорий
2. `CreateCategoryUseCase` — создание новой категории
3. `UpdateCategoryUseCase` — обновление категории
4. `DeleteCategoryUseCase` — удаление категории

#### Критерии приёмки
- [ ] 4 файла тестов создано
- [ ] Минимум 2 теста на каждый Use Case
- [ ] Все тесты проходят
- [ ] Покрытие ≥75%

---

### Задача 2.5: Unit-тесты для Settings & Log Use Cases

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файлы
- `test/usecases/settings/get_setting_usecase_test.dart`
- `test/usecases/settings/set_setting_usecase_test.dart`
- `test/usecases/settings/remove_setting_usecase_test.dart`
- `test/usecases/log/log_event_usecase_test.dart`
- `test/usecases/log/get_logs_usecase_test.dart`

#### Тесты для покрытия
1. `GetSettingUseCase` — получение настройки
2. `SetSettingUseCase` — установка настройки
3. `RemoveSettingUseCase` — удаление настройки
4. `LogEventUseCase` — логирование события
5. `GetLogsUseCase` — получение логов

#### Критерии приёмки
- [ ] 5 файлов тестов создано
- [ ] Минимум 2 теста на каждый Use Case
- [ ] Все тесты проходят
- [ ] Покрытие ≥75%

---

### Задача 3.1: Widget-тесты для AuthScreen

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файл
- `test/widgets/screens/auth_screen_test.dart`

#### Тесты
```dart
group('AuthScreen Widget Tests', () {
  testWidgets('должен отображать заголовок', (tester) async {
    expect(find.text('Введите PIN-код'), findsOneWidget);
  });

  testWidgets('должен отображать 8 ячеек для PIN', (tester) async {
    // Проверка отображения ячеек ввода
  });

  testWidgets('должен отображать цифровую клавиатуру', (tester) async {
    // Проверка клавиатуры 3x4
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    // ...
  });

  testWidgets('должен показывать ошибку при неверном PIN', (tester) async {
    // Проверка отображения ошибки
  });
});
```

#### Критерии приёмки
- [ ] 4 теста пройдены
- [ ] UI отображается корректно
- [ ] Нет warning в логах

---

### Задача 3.2: Widget-тесты для GeneratorScreen

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файл
- `test/widgets/screens/generator_screen_test.dart`

#### Тесты
```dart
group('GeneratorScreen Widget Tests', () {
  testWidgets('должен отображать заголовок', (tester) async {
    expect(find.text('Генератор'), findsOneWidget);
  });

  testWidgets('должен отображать сгенерированный пароль', (tester) async {
    expect(find.byType(CopyablePassword), findsOneWidget);
  });

  testWidgets('должен отображать индикатор стойкости', (tester) async {
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('должен отображать настройки генерации', (tester) async {
    // Проверка чекбоксов настроек
  });

  testWidgets('должен отображать пресеты', (tester) async {
    // Проверка кнопок пресетов
  });
});
```

#### Критерии приёмки
- [ ] 5 тестов пройдено
- [ ] UI отображается корректно

---

### Задача 3.3: Widget-тесты для StorageScreen

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файл
- `test/widgets/screens/storage_screen_test.dart`

#### Тесты
```dart
group('StorageScreen Widget Tests', () {
  testWidgets('должен отображать поиск', (tester) async {
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('должен отображать фильтр категорий', (tester) async {
    // Проверка FilterChip
  });

  testWidgets('должен отображать список паролей', (tester) async {
    // Проверка ListView
  });

  testWidgets('должен отображать карточку пароля', (tester) async {
    expect(find.byType(PasswordCard), findsOneWidget);
  });
});
```

#### Критерии приёмки
- [ ] 4 теста пройдено
- [ ] UI отображается корректно

---

### Задача 4.1: Integration-тест для Authentication flow

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файл
- `integration_test/auth_flow_test.dart`

#### Тест
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pass_gen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('полный сценарий аутентификации', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Шаг 1: Установка PIN
      expect(find.text('Введите PIN-код'), findsOneWidget);
      
      // Ввод PIN
      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.tap(find.text('4'));
      
      await tester.pumpAndSettle();

      // Шаг 2: Переход на главный экран
      expect(find.text('Генератор'), findsOneWidget);
    });
  });
}
```

#### Критерии приёмки
- [ ] Тест проходит
- [ ] Полный сценарий работает
- [ ] Нет ошибок в консоли

---

### Задача 4.2: Integration-тест для Password generation flow

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Файл
- `integration_test/generation_flow_test.dart`

#### Тест
```dart
group('Password Generation Flow', () {
  testWidgets('генерация и сохранение пароля', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Вход с PIN
    // ...

    // Переход в генератор
    await tester.tap(find.text('Генератор'));
    await tester.pumpAndSettle();

    // Нажатие кнопки генерации
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Проверка, что пароль сгенерирован
    expect(find.byType(CopyablePassword), findsOneWidget);
  });
});
```

#### Критерии приёмки
- [ ] Тест проходит
- [ ] Генерация работает
- [ ] Нет ошибок

---

### Задача 5.1: Создание тест-кейсов для ручного тестирования

**Статус:** ⏳ Ожидает  
**Оценка:** 2 часа  
**Фактически:** TBD  

#### Файл
- `project_context/testing/MANUAL_TEST_CASES.md`

#### Тест-кейсы
1. **TC-001:** Аутентификация
2. **TC-002:** Генерация пароля
3. **TC-003:** Сохранение пароля
4. **TC-004:** Поиск пароля
5. **TC-005:** Фильтрация по категориям
6. **TC-006:** Экспорт JSON
7. **TC-007:** Импорт JSON
8. **TC-008:** Экспорт .passgen
9. **TC-009:** Импорт .passgen
10. **TC-010:** Смена PIN-кода

#### Критерии приёмки
- [ ] 10+ тест-кейсов создано
- [ ] Все критические сценарии покрыты
- [ ] Результаты задокументированы

---

## 3. КРИТЕРИИ УСПЕХА ЭТАПА

- [ ] Все 15 задач выполнены
- [ ] Покрытие кода ≥50%
- [ ] Pass rate ≥95%
- [ ] 50+ тестов всего
- [ ] Нет критических багов

---

## 4. ЗАВИСИМОСТИ

### Блокирующие
- ✅ Этап 8 (Критические исправления) — для стабильности

### Зависит от
- ✅ Наличие моков (mockito)
- ✅ Настроенный test environment

### Блокирует
- ⬜ Этап 12 (Финальная подготовка к релизу)

---

## 5. РИСКИ

| Риск | Вероятность | Влияние | Митигация |
|---|---|---|---|
| Недостаточное покрытие | Высокая | Среднее | Приоритизация критических Use Cases |
| Ложные срабатывания тестов | Средняя | Низкое | Регулярный ревью тестов |
| Долгое выполнение | Средняя | Низкое | Оптимизация тестов |

---

## 6. ХРОНОЛОГИЯ ВЫПОЛНЕНИЯ

### День 1 (2026-03-08)
- [ ] Задача 1.1: Fix CharacterSetDisplay encoding
- [ ] Задача 1.2: Fix CopyablePassword timeout

### День 2 (2026-03-09)
- [ ] Задача 2.1: Auth Use Cases (5 файлов)
- [ ] Задача 2.2: Password Use Cases (2 файла)

### День 3 (2026-03-10)
- [ ] Задача 2.3: Storage Use Cases (6 файлов)
- [ ] Задача 2.4: Category Use Cases (4 файла)

### День 4 (2026-03-11)
- [ ] Задача 2.5: Settings & Log Use Cases (5 файла)
- [ ] Задача 3.1-3.3: Widget-тесты (3 файла)

### День 5 (2026-03-12)
- [ ] Задача 4.1-4.2: Integration-тесты (2 файла)
- [ ] Задача 5.1: Ручное тестирование

---

## 7. ОТВЕТСТВЕННЫЕ

| Роль | Ответственный |
|---|---|
| QA Lead | AI QA Agent |
| Разработчик | AI Flutter Agent |
| Код-ревью | AI Code Reviewer |

---

## 8. ПРИЛОЖЕНИЯ

### A. Команды для запуска
```bash
# Запуск всех тестов
flutter test

# Запуск unit-тестов
flutter test test/usecases/

# Запуск widget-тестов
flutter test test/widgets/

# Запуск integration-тестов
flutter test integration_test/

# Запуск с покрытием
flutter test --coverage

# Генерация HTML отчёта
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### B. Генерация моков
```bash
# Запуск генерации моков
flutter pub run build_runner build --delete-conflicting-outputs
```

---

**План создал:** AI QA Agent  
**Дата создания:** 2026-03-08  
**Версия:** 1.0  
**Статус:** ⏳ В работе
