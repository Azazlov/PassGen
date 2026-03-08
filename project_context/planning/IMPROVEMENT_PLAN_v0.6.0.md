# 📋 План улучшений PassGen v0.6.0

**Дата создания:** 8 марта 2026 г.  
**Целевая версия:** 0.6.0  
**На основе:** CODE_REVIEW_2026-03-08_COMPREHENSIVE.md  
**Статус:** ✅ Готов к реализации

---

## 🎯 ОБЗОР ПЛАНА

Этот план распределён по зонам ответственности согласно инструкциям:
- **UI/UX Дизайнер** — `UI_UX_DESIGNER.md`
- **Frontend-разработчик** — `frontend_developer_instructions.md`

---

## 📊 МАТРИЦА ОТВЕТСТВЕННОСТИ

| Задача | UI/UX | Frontend | Совместно |
|---|:---:|:---:|:---:|
| Доступность (A11y) | ✅ | ✅ | 🔹 |
| Адаптивность (двухпанельный макет) | ✅ | ✅ | 🔹 |
| Анимации и микро-интеракции | ✅ | ✅ | 🔹 |
| Дизайн-система (обновление) | ✅ | ⬜ | ⬜ |
| Тестирование (Widget/Unit/Integration) | ⬜ | ✅ | ⬜ |
| Рефакторинг архитектуры | ⬜ | ✅ | ⬜ |
| Производительность | ⬜ | ✅ | ⬜ |
| Безопасность | ⬜ | ✅ | ⬜ |

---

# 🎨 ЧАСТЬ 1: UI/UX ДИЗАЙНЕР

**Инструкция:** `project_context/instructions/UI_UX_DESIGNER.md`

**Область ответственности:**
- Дизайн-система (цвета, типографика, компоненты)
- Прототипирование экранов
- Гайдлайны для разработчиков
- Анимации и микро-интеракции
- Доступность (WCAG AA)
- Адаптивность (mobile/tablet/desktop)
- Ассеты (иконки, графика, Lottie)

---

## 🔴 ПРИОРИТЕТ 1: Критические улучшения UI/UX (2-3 дня)

### Задача 1.1: Обновление гайдлайнов доступности

**Файлы:**
- `project_context/design/guidelines/guidelines.md` (Раздел 10: Accessibility)
- `project_context/design/for_development/components.json`

**Что сделать:**
1. Добавить спецификации Semantics для всех интерактивных элементов
2. Описать требования к контрастности (WCAG AA 4.5:1)
3. Добавить гайдлайн по навигации с клавиатуры
4. Создать чек-лист доступности для разработчиков

**Результат:**
```markdown
# project_context/design/guidelines/guidelines.md (Раздел 10)

## 10. Accessibility Guidelines

### 10.1 Semantics Requirements

| Компонент | Semantics требования |
|-----------|---------------------|
| IconButton | label, hint, button: true |
| TextField | label, hint, textField: true |
| Card | label (описание содержимого) |

### 10.2 Keyboard Navigation

- Tab: переход между элементами
- Enter/Space: активация кнопки
- Escape: закрытие диалога
```

**Оценка:** 3 часа

---

### Задача 1.2: Прототип двухпанельного макета Storage

**Файлы:**
- `project_context/design/prototypes/storage_two_pane.fig` (новый)
- `project_context/design/final/storage_two_pane_mobile.png`
- `project_context/design/final/storage_two_pane_tablet.png`
- `project_context/design/final/storage_two_pane_desktop.png`
- `project_context/design/for_development/storage_two_pane.json` (новый)

**Что сделать:**
1. Создать макет для mobile (однопанельный, текущий)
2. Создать макет для tablet (двухпанельный: 40% список + 60% детали)
3. Создать макет для desktop (трёхпанельный: навигация + список + детали)
4. Добавить спецификации для разработчиков (размеры, отступы, поведение)

**Спецификация (пример):**
```json
{
  "storage_two_pane": {
    "mobile": {
      "breakpoint": "< 600dp",
      "layout": "single_pane",
      "navigation": "BottomNavigationBar"
    },
    "tablet": {
      "breakpoint": "600-899dp",
      "layout": "two_pane",
      "list_width": "40%",
      "detail_width": "60%",
      "navigation": "NavigationRail"
    },
    "desktop": {
      "breakpoint": "≥ 900dp",
      "layout": "three_pane",
      "navigation_width": "80dp",
      "list_width": "320px",
      "detail_width": "fill"
    }
  }
}
```

**Оценка:** 4 часа

---

### Задача 1.3: Обновление спецификации кнопок

**Файлы:**
- `project_context/design/for_development/components.json` (раздел Buttons)
- `project_context/design/guidelines/guidelines.md` (Раздел 6: Components)

**Что сделать:**
1. Указать высоту кнопок по ТЗ:
   - Мобильный: 48dp
   - Десктоп: 40dp
2. Добавить состояния: disabled, loading
3. Добавить визуальные спецификации для каждого состояния

**Спецификация:**
```json
{
  "buttons": {
    "mobile": {
      "height": 48,
      "min_width": "full_width",
      "font_size": 16,
      "padding_horizontal": 24
    },
    "desktop": {
      "height": 40,
      "min_width": 200,
      "font_size": 14,
      "padding_horizontal": 16
    },
    "states": {
      "default": {
        "background": "primary",
        "text": "onPrimary",
        "elevation": 2
      },
      "disabled": {
        "background": "outlineVariant",
        "text": "onDisabled",
        "elevation": 0
      },
      "loading": {
        "background": "primary",
        "content": "circular_progress_indicator",
        "text_color": "onPrimary"
      }
    }
  }
}
```

**Оценка:** 2 часа

---

### Задача 1.4: Спецификации адаптивной типографики

**Файлы:**
- `project_context/design/for_development/typography.json` (обновление)

**Что сделать:**
1. Добавить размеры шрифтов для всех брейкпоинтов
2. Добавить line-height для каждого стиля
3. Добавить Flutter implementation guide

**Таблица размеров:**
| Стиль | Mobile (<600dp) | Tablet (600-899dp) | Desktop (≥900dp) |
|---|---|---|---|
| displayLarge | 48px / 64px | 52px / 68px | 57px / 64px |
| headlineLarge | 28px / 36px | 30px / 40px | 32px / 40px |
| titleLarge | 18px / 24px | 20px / 28px | 22px / 28px |
| bodyLarge | 15px / 20px | 15px / 20px | 16px / 24px |

**Оценка:** 2 часа

---

## 🟡 ПРИОРИТЕТ 2: Улучшение дизайн-системы (3-4 дня)

### Задача 2.1: Анимации микро-интеракций

**Файлы:**
- `project_context/design/animations/` (новая папка)
- `project_context/design/guidelines/guidelines.md` (Раздел 8)

**Что создать:**
1. **Button Press Animation** — ripple effect спецификация
2. **Copy Success Animation** — checkmark animation (Lottie JSON)
3. **Password Strength Pulse** — индикатор стойкости (анимация цвета)
4. **List Item Swipe** — swipe-to-delete анимация

**Спецификация (пример):**
```json
{
  "copy_success_animation": {
    "duration_ms": 200,
    "type": "scale_fade",
    "stages": [
      {"time": 0, "scale": 0.8, "opacity": 0},
      {"time": 100, "scale": 1.2, "opacity": 1},
      {"time": 200, "scale": 1.0, "opacity": 1}
    ],
    "easing": "ease_out_cubic"
  }
}
```

**Оценка:** 4 часа

---

### Задача 2.2: Гайдлайн по обработке ошибок в UI

**Файлы:**
- `project_context/design/guidelines/guidelines.md` (новый Раздел 11)
- `project_context/design/prototypes/error_states.fig`

**Что сделать:**
1. Описать типы ошибок (validation, network, crypto, storage)
2. Создать макеты error states для каждого экрана
3. Добавить спецификации error banner/dialog/snackbar

**Типы уведомлений:**
| Тип | Компонент | Длительность | Пример |
|---|---|---|---|
| Validation Error | TextField helper text | Пока поле активно | "PIN должен быть 4-8 цифр" |
| Success | SnackBar | 2 секунды | "Пароль скопирован" |
| Warning | Banner | До закрытия | "Буфер будет очищен через 60 сек" |
| Critical Error | AlertDialog | До действия | "Ошибка шифрования" |

**Оценка:** 3 часа

---

### Задача 2.3: Иконки для категорий (обновление)

**Файлы:**
- `project_context/design/assets/icons/` (обновление)

**Что сделать:**
1. Проверить текущие 7 иконок категорий
2. Добавить иконки для новых категорий (если есть)
3. Экспортировать в SVG (24x24px)
4. Создать спецификацию использования

**Список иконок:**
- `social.svg` — Социальные сети
- `finance.svg` — Банки, финансы
- `shopping.svg` — Магазины
- `entertainment.svg` — Развлечения
- `work.svg` — Работа
- `health.svg` — Здоровье
- `other.svg` — Другое

**Оценка:** 2 часа

---

## 🟢 ПРИОРИТЕТ 3: Полировка дизайна (2-3 дня)

### Задача 3.1: Пустые состояния (Empty States)

**Файлы:**
- `project_context/design/prototypes/empty_states.fig`
- `project_context/design/final/empty_states_*.png`

**Что создать:**
1. Empty state для хранилища (нет паролей)
2. Empty state для поиска (ничего не найдено)
3. Empty state для логов (нет событий)
4. Empty state для категорий (только системные)

**Спецификация:**
```
┌─────────────────────────────────┐
│                                 │
│         [📦 Иконка]             │
│                                 │
│      Хранилище пустое           │
│                                 │
│  Нажмите + чтобы добавить       │
│  первый пароль                  │
│                                 │
│      [➕ Добавить пароль]       │
│                                 │
└─────────────────────────────────┘
```

**Оценка:** 3 часа

---

### Задача 3.2: Обновление changelog дизайна

**Файлы:**
- `project_context/design/changelog.md`

**Что добавить:**
- Версия 1.4.0 (улучшения доступности)
- Версия 1.5.0 (двухпанельный макет)
- Версия 1.6.0 (анимации микро-интеракций)

**Оценка:** 1 час

---

## 📊 ИТОГО ДЛЯ UI/UX ДИЗАЙНЕРА

| Приоритет | Задач | Оценка | Срок |
|---|---|---|---|
| 🔴 Приоритет 1 | 4 | 11 часов | 2-3 дня |
| 🟡 Приоритет 2 | 3 | 9 часов | 3-4 дня |
| 🟢 Приоритет 3 | 2 | 4 часа | 2-3 дня |
| **ВСЕГО** | **9** | **24 часа** | **1-2 недели** |

---

# 💻 ЧАСТЬ 2: FRONTEND-РАЗРАБОТЧИК

**Инструкция:** `project_context/instructions/frontend_developer_instructions.md`

**Область ответственности:**
- Data & Security (аутентификация, хранение, шифрование)
- Тестирование (Widget, Unit, Integration)
- Сборка и развёртывание
- Frontend Development (UI компоненты, виджеты)
- Архитектура (Clean Architecture)

---

## 🔴 ПРИОРИТЕТ 1: Критические исправления архитектуры (3-4 дня)

### Задача 1.1: Рефакторинг StorageRepository (нарушение SRP)

**Файлы:**
```
lib/domain/repositories/
  ├── storage_repository.dart (текущий, обновить)
  ├── password_export_repository.dart (новый)
  └── password_import_repository.dart (новый)

lib/data/repositories/
  ├── storage_repository_impl.dart (сократить)
  ├── password_export_repository_impl.dart (новый)
  └── password_import_repository_impl.dart (новый)

lib/domain/usecases/storage/
  ├── export_passwords_usecase.dart (переместить)
  ├── import_passwords_usecase.dart (переместить)
  ├── export_passgen_usecase.dart (переместить)
  └── import_passgen_usecase.dart (переместить)
```

**Что сделать:**
1. Создать новые интерфейсы `PasswordExportRepository` и `PasswordImportRepository`
2. Переместить методы экспорта/импорта из `StorageRepository`
3. Обновить Use Cases для использования новых репозиториев
4. Обновить DI в `app.dart`

**До:**
```dart
abstract class StorageRepository {
  Future<List<PasswordEntry>> getAll();
  Future<void> delete(int index);
  Future<String> exportToJson();  // ❌ Лишняя ответственность
  Future<bool> importFromJson(String json);  // ❌
}
```

**После:**
```dart
abstract class StorageRepository {
  Future<List<PasswordEntry>> getAll();
  Future<void> delete(int index);
  // Только CRUD
}

abstract class PasswordExportRepository {
  Future<String> exportToJson();
  Future<String> exportToPassgen(String password);
}

abstract class PasswordImportRepository {
  Future<bool> importFromJson(String json);
  Future<bool> importFromPassgen(String data, String password);
}
```

**Оценка:** 6 часов

---

### Задача 1.2: Переместить валидацию в Domain

**Файлы:**
```
lib/domain/usecases/generator/
  ├── validate_generator_settings_usecase.dart (новый)
  └── validate_pin_usecase.dart (новый)

lib/domain/validators/
  ├── pin_validator.dart (новый)
  └── password_settings_validator.dart (новый)
```

**Что сделать:**
1. Создать валидаторы в Domain слое
2. Обновить контроллеры для использования валидаторов
3. Удалить валидацию из контроллеров

**До (в Controller):**
```dart
// generator_controller.dart
void updateLengthRange(int min, int max) {
  if (min > max || min < 1 || max > 64) {
    _error = 'Недопустимый диапазон длин';  // ❌ Валидация в UI слое
    notifyListeners();
    return;
  }
}
```

**После (через Use Case):**
```dart
// generator_controller.dart
void updateLengthRange(int min, int max) {
  final result = validateGeneratorSettingsUseCase.execute(
    min: min,
    max: max,
  );
  
  result.fold(
    (failure) => _error = failure.message,  // ✅ Валидация в Domain
    (settings) => _settings = settings,
  );
  notifyListeners();
}
```

**Оценка:** 4 часа

---

### Задача 1.3: Исправление утечек памяти

**Файлы:**
- `lib/presentation/features/auth/auth_controller.dart`
- `lib/presentation/features/storage/storage_controller.dart`
- `lib/presentation/features/generator/generator_controller.dart`

**Что сделать:**
1. Проверить все `Timer` в контроллерах
2. Добавить отмену таймеров в `dispose()`
3. Проверить StreamController на закрытие
4. Добавить тесты на утечки памяти

**Пример исправления:**
```dart
// auth_controller.dart
class AuthController extends ChangeNotifier {
  Timer? _inactivityTimer;

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;  // ✅ Явная очистка
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }
}
```

**Оценка:** 2 часа

---

### Задача 1.4: Глобальный error handler

**Файлы:**
```
lib/presentation/widgets/
  └── global_error_banner.dart (новый)

lib/core/errors/
  └── error_handler.dart (новый)
```

**Что создать:**
1. Глобальный обработчик ошибок
2. Виджет error banner для отображения ошибок
3. Интеграция с контроллерами

**Пример:**
```dart
// lib/presentation/widgets/global_error_banner.dart
class GlobalErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback onDismiss;

  const GlobalErrorBanner({
    required this.error,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();

    return Banner(
      message: error!,
      location: BannerLocation.topStart,
      color: Theme.of(context).colorScheme.error,
      child: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onDismiss,
      ),
    );
  }
}
```

**Оценка:** 3 часа

---

## 🟡 ПРИОРИТЕТ 2: Тестирование (5-6 дней)

### Задача 2.1: Unit-тесты для Use Cases

**Файлы:**
```
test/usecases/
├── auth/
│   ├── setup_pin_usecase_test.dart
│   ├── verify_pin_usecase_test.dart
│   ├── change_pin_usecase_test.dart
│   ├── remove_pin_usecase_test.dart
│   └── get_auth_state_usecase_test.dart
├── generator/
│   ├── generate_password_usecase_test.dart
│   └── save_password_usecase_test.dart
├── storage/
│   ├── get_passwords_usecase_test.dart
│   ├── delete_password_usecase_test.dart
│   ├── export_passwords_usecase_test.dart
│   └── import_passwords_usecase_test.dart
└── ... (остальные Use Cases)
```

**Что сделать:**
1. Создать тесты для всех 26 Use Cases
2. Использовать mockito для моков репозиториев
3. Покрыть все сценарии (успех, ошибка, валидация)
4. Целевое покрытие: ≥90%

**Пример теста:**
```dart
// test/usecases/auth/verify_pin_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('VerifyPinUseCase Tests', () {
    late VerifyPinUseCase useCase;
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
      useCase = VerifyPinUseCase(repository);
    });

    test('возвращает AuthResult при успешной проверке PIN', () async {
      // Arrange
      const pin = '1234';
      final authResult = AuthResult(success: true);
      when(repository.verifyPin(pin))
        .thenAnswer((_) async => Right(authResult));

      // Act
      final result = await useCase.execute(pin);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), equals(authResult));
    });

    test('возвращает AuthFailure при неверном PIN', () async {
      // Arrange
      const pin = '0000';
      final failure = AuthFailure(message: 'Неверный PIN');
      when(repository.verifyPin(pin))
        .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(pin);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

**Оценка:** 12 часов

---

### Задача 2.2: Widget-тесты для экранов

**Файлы:**
```
test/widgets/screens/
├── auth_screen_test.dart
├── generator_screen_test.dart
├── storage_screen_test.dart
├── settings_screen_test.dart
└── encryptor_screen_test.dart
```

**Что сделать:**
1. Создать тесты для 9 экранов
2. Проверить рендеринг ключевых элементов
3. Проверить взаимодействие (нажатия, ввод)
4. Целевое покрытие: ≥70%

**Пример теста:**
```dart
// test/widgets/screens/generator_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('GeneratorScreen Widget Tests', () {
    testWidgets('отображает сгенерированный пароль', (tester) async {
      // Arrange
      final controller = MockGeneratorController();
      when(controller.password).thenReturn('TestPassword123!');
      when(controller.strengthValue).thenReturn(0.8);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: const MaterialApp(home: GeneratorScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('TestPassword123!'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('кнопка генерации вызывает generatePassword', (tester) async {
      // Arrange
      final controller = MockGeneratorController();
      when(controller.isLoading).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: const MaterialApp(home: GeneratorScreen()),
        ),
      );

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      verify(controller.generatePassword()).called(1);
    });
  });
}
```

**Оценка:** 10 часов

---

### Задача 2.3: Integration-тесты для ключевых сценариев

**Файлы:**
```
integration_test/
├── auth_flow_test.dart
├── password_generation_flow_test.dart
└── storage_crud_flow_test.dart
```

**Что сделать:**
1. Тест полного сценария аутентификации
2. Тест генерации и сохранения пароля
3. Тест CRUD операций хранилища
4. Запуск на реальном устройстве/эмуляторе

**Пример теста:**
```dart
// integration_test/password_generation_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Генерация и сохранение пароля', (tester) async {
    // Запуск приложения
    app.main();
    await tester.pumpAndSettle();

    // 1. Аутентификация
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    // 2. Переход в генератор
    await tester.tap(find.text('Генератор'));
    await tester.pumpAndSettle();

    // 3. Генерация пароля
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    // 4. Проверка наличия пароля
    expect(find.byType(CopyablePassword), findsOneWidget);

    // 5. Сохранение пароля
    await tester.enterText(find.byType(TextField), 'TestService');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // 6. Проверка сохранения
    expect(find.text('Пароль сохранён'), findsOneWidget);
  });
}
```

**Оценка:** 8 часов

---

## 🟢 ПРИОРИТЕТ 3: Производительность и оптимизация (2-3 дня)

### Задача 3.1: Debounce для поиска

**Файлы:**
- `lib/presentation/features/storage/storage_controller.dart`

**Что сделать:**
1. Добавить Timer для debounce
2. Отменять предыдущий таймер при новом вводе
3. Применять фильтр только после задержки

**Пример:**
```dart
// storage_controller.dart
class StorageController extends ChangeNotifier {
  Timer? _debounce;

  void setSearchQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

**Оценка:** 1 час

---

### Задача 3.2: RepaintBoundary для списков

**Файлы:**
- `lib/presentation/features/storage/storage_screen.dart`
- `lib/presentation/features/logs/logs_screen.dart`

**Что сделать:**
1. Обернуть ListView в RepaintBoundary
2. Добавить const конструкторы где возможно
3. Использовать ListView.builder для ленивой загрузки

**Пример:**
```dart
// storage_screen.dart
RepaintBoundary(
  child: ListView.builder(
    itemCount: passwords.length,
    itemBuilder: (context, index) {
      return PasswordCard(entry: passwords[index]);
    },
  ),
)
```

**Оценка:** 2 часа

---

### Задача 3.3: Lazy инициализация зависимостей

**Файлы:**
- `lib/app/app.dart`

**Что сделать:**
1. Использовать `Provider.lazy` для тяжёлых зависимостей
2. Проверить, что инициализация происходит при первом использовании

**Пример:**
```dart
// app.dart
MultiProvider(
  providers: [
    Provider.lazy(() => DatabaseHelper()),
    Provider.lazy(() => EncryptorLocalDataSource()),
    // ...
  ],
)
```

**Оценка:** 2 часа

---

### Задача 3.4: Кэширование часто используемых данных

**Файлы:**
```
lib/data/datasources/
  └── cache_datasource.dart (новый)
```

**Что сделать:**
1. Создать кэш для категорий
2. Создать кэш для настроек
3. Добавить инвалидацию кэша

**Пример:**
```dart
// lib/data/datasources/cache_datasource.dart
class CacheDataSource {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _expiry = {};

  Future<List<Category>> getCategories() async {
    if (_cache.containsKey('categories') &&
        !_isExpired('categories')) {
      return _cache['categories'] as List<Category>;
    }

    // Запрос к БД
    final categories = await _fetchCategoriesFromDb();
    _cache['categories'] = categories;
    _expiry['categories'] = DateTime.now().add(
      const Duration(minutes: 5),
    );

    return categories;
  }

  bool _isExpired(String key) {
    if (!_expiry.containsKey(key)) return true;
    return DateTime.now().isAfter(_expiry[key]!);
  }
}
```

**Оценка:** 4 часа

---

## 📊 ИТОГО ДЛЯ FRONTEND-РАЗРАБОТЧИКА

| Приоритет | Задач | Оценка | Срок |
|---|---|---|---|
| 🔴 Приоритет 1 | 4 | 15 часов | 3-4 дня |
| 🟡 Приоритет 2 | 3 | 30 часов | 5-6 дней |
| 🟢 Приоритет 3 | 4 | 9 часов | 2-3 дня |
| **ВСЕГО** | **11** | **54 часа** | **2-3 недели** |

---

# 🤝 ЧАСТЬ 3: СОВМЕСТНЫЕ ЗАДАЧИ

## Задача С-1: Реализация двухпанельного макета Storage

**UI/UX Дизайнер:**
- [ ] Создать макеты (mobile/tablet/desktop)
- [ ] Добавить спецификации в `storage_two_pane.json`
- [ ] Предоставить ASCII mockups

**Frontend-разработчик:**
- [ ] Обновить `storage_screen.dart` с LayoutBuilder
- [ ] Реализовать NavigationRail для tablet/desktop
- [ ] Добавить адаптивную вёрстку

**Файлы:**
```
lib/presentation/features/storage/storage_screen.dart
```

**Пример реализации:**
```dart
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      if (width < Breakpoints.mobileMax) {
        return _buildMobileLayout();  // Однопанельный
      } else if (width < Breakpoints.desktopMin) {
        return _buildTabletLayout();  // Двухпанельный
      } else {
        return _buildDesktopLayout();  // Трёхпанельный
      }
    },
  );
}
```

**Оценка:** 8 часов (совместно)

---

## Задача С-2: Улучшение доступности

**UI/UX Дизайнер:**
- [ ] Добавить Semantics спецификации в гайдлайны
- [ ] Создать чек-лист доступности
- [ ] Проверить контрастность цветов

**Frontend-разработчик:**
- [ ] Добавить Semantics виджеты
- [ ] Реализовать навигацию с клавиатуры
- [ ] Проверить скринридером

**Файлы:**
- `lib/presentation/widgets/*.dart`
- `lib/presentation/features/*/*.dart`

**Пример:**
```dart
Semantics(
  label: 'Копировать пароль для ${entry.service}',
  hint: 'Дважды нажмите для копирования',
  button: true,
  child: IconButton(
    icon: const Icon(Icons.copy),
    onPressed: () => _copyPassword(entry.password),
  ),
)
```

**Оценка:** 6 часов (совместно)

---

## Задача С-3: Анимации микро-интеракций

**UI/UX Дизайнер:**
- [ ] Создать Lottie JSON для анимаций
- [ ] Добавить спецификации длительности
- [ ] Описать easing функции

**Frontend-разработчик:**
- [ ] Интегрировать Lottie анимации
- [ ] Добавить AnimatedContainer
- [ ] Настроить длительности

**Файлы:**
- `project_context/design/animations/`
- `lib/presentation/widgets/`

**Оценка:** 4 часа (совместно)

---

# 📈 ОБЩИЙ ПЛАН-ГРАФИК

## Неделя 1 (8-14 марта)

| День | UI/UX Дизайнер | Frontend-разработчик |
|---|---|---|
| **Пн** | Задача 1.1 (A11y гайдлайны) | Задача 1.1 (StorageRepository SRP) |
| **Вт** | Задача 1.2 (Storage two-pane) | Задача 1.2 (Валидация в Domain) |
| **Ср** | Задача 1.3 (Спецификация кнопок) | Задача 1.3 (Утечки памяти) |
| **Чт** | Задача 1.4 (Адаптивная типографика) | Задача 1.4 (Global error handler) |
| **Пт** | Задача 2.1 (Анимации) | Задача 2.1 (Unit-тесты, часть 1) |

## Неделя 2 (15-21 марта)

| День | UI/UX Дизайнер | Frontend-разработчик |
|---|---|---|
| **Пн** | Задача 2.2 (Error states гайдлайн) | Задача 2.1 (Unit-тесты, часть 2) |
| **Вт** | Задача 2.3 (Иконки) | Задача 2.1 (Unit-тесты, часть 3) |
| **Ср** | Задача 3.1 (Empty states) | Задача 2.2 (Widget-тесты, часть 1) |
| **Чт** | Задача 3.2 (Changelog) | Задача 2.2 (Widget-тесты, часть 2) |
| **Пт** | **Совместно С-1** (Two-pane реализация) | **Совместно С-1** (Two-pane реализация) |

## Неделя 3 (22-28 марта)

| День | UI/UX Дизайнер | Frontend-разработчик |
|---|---|---|
| **Пн** | **Совместно С-2** (A11y реализация) | **Совместно С-2** (A11y реализация) |
| **Вт** | **Совместно С-3** (Анимации) | **Совместно С-3** (Анимации) |
| **Ср** | Полировка макетов | Задача 3.1 (Debounce) |
| **Чт** | Финальное ревью дизайна | Задача 3.2 (RepaintBoundary) |
| **Пт** | **Релиз v0.6.0** | Задача 3.3-3.4 (Оптимизация) |

---

# 📊 СВОДНАЯ ТАБЛИЦА

| Роль | Задач | Оценка | Срок |
|---|---|---|---|
| **UI/UX Дизайнер** | 9 | 24 часа | 1-2 недели |
| **Frontend-разработчик** | 11 | 54 часа | 2-3 недели |
| **Совместно** | 3 | 18 часов | 1 неделя |
| **ВСЕГО** | **23** | **96 часов** | **3 недели** |

---

# ✅ КРИТЕРИИ УСПЕХА

## Для UI/UX дизайнера

- [ ] Все гайдлайны обновлены (A11y, error states, animations)
- [ ] Макеты two-pane созданы для всех брейкпоинтов
- [ ] Спецификации кнопок и типографики актуализированы
- [ ] Changelog обновлён до версии 1.6.0
- [ ] Все ассеты экспортированы в `for_development/`

## Для Frontend-разработчика

- [ ] StorageRepository разделён на 3 класса
- [ ] Валидация перемещена в Domain слой
- [ ] Все утечки памяти исправлены
- [ ] Unit-тесты: ≥90% покрытие Use Cases
- [ ] Widget-тесты: ≥70% покрытие экранов
- [ ] Integration-тесты: 3 сценария работают
- [ ] Debounce и RepaintBoundary добавлены
- [ ] Сборка без ошибок

## Совместные критерии

- [ ] Two-pane макет работает на tablet/desktop
- [ ] Доступность: все Semantics добавлены
- [ ] Анимации плавные (60 FPS)
- [ ] Релиз v0.6.0 опубликован

---

**План составил:** Технический Писатель (ИИ-агент)  
**Дата:** 8 марта 2026 г.  
**Версия:** 1.0  
**Статус:** ✅ Готов к реализации

---

**PassGen v0.6.0** | [MIT License](../../LICENSE)
