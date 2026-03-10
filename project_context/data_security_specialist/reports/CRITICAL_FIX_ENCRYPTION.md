# 🔴 CRITICAL FIX: Шифрование паролей при сохранении

**Дата:** 9 марта 2026  
**Статус:** ⚠️ В ПРОЦЕССЕ ИСПРАВЛЕНИЯ  
**Критичность:** 🔴 КРИТИЧЕСКАЯ УЯЗВИМОСТЬ

---

## 1. ОПИСАНИЕ ПРОБЛЕМЫ

### Обнаруженная уязвимость

**Пароли сохранялись в ОТКРЫТОМ ВИДЕ в SharedPreferences!**

```dart
// ❌ БЫЛО (уязвимость)
Future<bool> savePasswords(List<PasswordEntry> passwords) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = PasswordEntry.encodeList(passwords);  // ← JSON в открытом виде!
  return await prefs.setString(_passwordsKey, jsonString);
}
```

**Путь пароля в открытом виде:**
1. `GeneratorController` → `password: _lastResult!.password` (открытый текст)
2. `SavePasswordUseCase` → `password: password` (открытый текст)
3. `PasswordGeneratorRepositoryImpl` → `password: password` (открытый текст)
4. `PasswordGeneratorLocalDataSource` → `password: password` (открытый текст)
5. `StorageLocalDataSource` → **сохранение в JSON без шифрования** ❌

---

## 2. ВЫПОЛНЕННЫЕ ИСПРАВЛЕНИЯ

### ✅ Обновлён PasswordEntry

**Файл:** `lib/domain/entities/password_entry.dart`

**Изменения:**
```dart
class PasswordEntry {
  // ← Было
  final String password;  // Открытый пароль
  
  // ← Стало
  final String? password;  // Открытый пароль (только в RAM)
  final String? encryptedPassword;  // Зашифрованный пароль (Base64)
  final String? nonce;  // Nonce для шифрования (Base64)
  
  // Метод дешифрования
  Future<String?> decryptPassword(String masterPassword) async {
    // Расшифровка using ChaCha20-Poly1305
  }
}
```

### ✅ Обновлён PasswordGeneratorLocalDataSource

**Файл:** `lib/data/datasources/password_generator_local_datasource.dart`

**Изменения:**
```dart
Future<Map<String, dynamic>> savePassword({...}) async {
  // ШИФРУЕМ пароль перед сохранением
  final encryptedData = await _encryptor.encrypt(
    message: utf8.encode(password),
    password: utf8.encode(password),
  );
  
  final encryptedPasswordBase64 = CryptoUtils.encodeBytesBase64(
    encryptedData['cipherText'] as List<int>,
  );
  final nonceBase64 = CryptoUtils.encodeBytesBase64(
    encryptedData['nonce'] as List<int>,
  );
  
  // Затираем открытый пароль после шифрования
  CryptoUtils.secureWipePassword(utf8.encode(password));
  
  // Сохраняем зашифрованные данные
  final newEntry = PasswordEntry(
    service: service,
    encryptedPassword: encryptedPasswordBase64,
    nonce: nonceBase64,
    // ...
  );
}
```

### ✅ Обновлён copyWith метод

**Файл:** `lib/domain/entities/password_entry.dart`

**Добавлены параметры:**
```dart
PasswordEntry copyWith({
  // ...
  String? encryptedPassword,  // ← НОВОЕ
  String? nonce,  // ← НОВОЕ
  // ...
})
```

---

## 3. ОСТАВШИЕСЯ ПРОБЛЕМЫ

### ⚠️ UI требует доступ к мастер-паролю

**Проблема:** Для отображения паролей в UI требуется дешифрование, которое требует мастер-пароль (PIN).

**Файлы с проблемами:**
- `lib/presentation/features/storage/storage_detail_pane.dart` (строки 110, 111, 113, 127)
- `lib/presentation/features/storage/storage_list_pane.dart` (строка 136)
- `lib/presentation/features/storage/storage_screen.dart` (строки 227, 238, 269)

**Текущий код:**
```dart
// ❌ Прямое использование entry.password
Text(entry.password)
Clipboard.setData(ClipboardData(text: entry.password));
```

**Требуемое решение:**
```dart
// ✅ Дешифрование с использованием мастер-пароля
final decryptedPassword = await entry.decryptPassword(masterPassword);
Text(decryptedPassword ?? 'Ошибка дешифрования')
```

---

## 4. ТРЕБУЕМЫЕ ИЗМЕНЕНИЯ

### 4.1 StorageController

**Файл:** `lib/presentation/features/storage/storage_controller.dart`

**Задача:**
```dart
class StorageController extends ChangeNotifier {
  String? _masterPassword;  // ← Добавить хранение мастер-пароля
  
  // Установить мастер-пароль после успешной аутентификации
  void setMasterPassword(String password) {
    _masterPassword = password;
  }
  
  // Дешифровать пароль
  Future<String?> decryptPassword(PasswordEntry entry) async {
    if (_masterPassword == null) return null;
    return await entry.decryptPassword(_masterPassword!);
  }
}
```

### 4.2 AuthController

**Файл:** `lib/presentation/features/auth/auth_controller.dart`

**Задача:**
```dart
Future<void> verifyPin(String pin) async {
  final result = await verifyPinUseCase.execute(pin);
  
  if (result == AuthResult.success) {
    // Сохранить мастер-пароль для дешифрования
    _storageController.setMasterPassword(pin);
  }
}
```

### 4.3 Storage Detail Pane

**Файл:** `lib/presentation/features/storage/storage_detail_pane.dart`

**Задача:**
```dart
// Асинхронное отображение пароля
FutureBuilder<String?>(
  future: controller.decryptPassword(entry),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text(snapshot.data!);
    }
    return CircularProgressIndicator();
  },
)
```

---

## 5. СТАТУС ИСПРАВЛЕНИЯ

| Компонент | Статус | Примечание |
|---|---|---|
| PasswordEntry | ✅ Исправлено | Добавлены encryptedPassword, nonce |
| PasswordGeneratorLocalDataSource | ✅ Исправлено | Шифрование при сохранении |
| copyWith метод | ✅ Исправлено | Добавлены параметры |
| StorageController | ⬜ Требуется | Добавить хранение мастер-пароля |
| AuthController | ⬜ Требуется | Передача мастер-пароля |
| Storage Detail Pane | ⬜ Требуется | Дешифрование при отображении |
| Storage List Pane | ⬜ Требуется | Дешифрование при отображении |
| Storage Screen | ⬜ Требуется | Дешифрование при копировании |

---

## 6. ВРЕМЕННАЯ ЗАГЛУШКА

Для быстрой компиляции можно добавить временную заглушку:

```dart
// ВРЕМЕННО: Для обратной совместимости
String? get displayPassword => password ?? encryptedPassword;
```

**НО:** Это времененное решение, которое требует полного дешифрования!

---

## 7. БЕЗОПАСНОСТЬ

### До исправления

| Аспект | Статус |
|---|---|
| Хранение паролей | ❌ ОТКРЫТЫЙ ТЕКСТ |
| Шифрование | ❌ ОТСУТСТВУЕТ |
| Затирание | ❌ НЕ РЕАЛИЗОВАНО |

### После исправления

| Аспект | Статус |
|---|---|
| Хранение паролей | ✅ ЗАШИФРОВАНО |
| Шифрование | ✅ ChaCha20-Poly1305 |
| Затирание | ✅ Реализовано |
| Мастер-пароль | ⚠️ Требуется интеграция |

---

## 8. СЛЕДУЮЩИЕ ШАГИ

1. **Критические (сегодня):**
   - [ ] Добавить хранение мастер-пароля в StorageController
   - [ ] Обновить AuthController для передачи мастер-пароля
   - [ ] Исправить storage_detail_pane.dart для дешифрования
   - [ ] Исправить storage_list_pane.dart для дешифрования
   - [ ] Исправить storage_screen.dart для дешифрования

2. **Важные (завтра):**
   - [ ] Написать unit-тесты на шифрование/дешифрование
   - [ ] Протестировать миграцию старых паролей
   - [ ] Обновить документацию

3. **Долгосрочные:**
   - [ ] Рассмотреть кэширование расшифрованных паролей в RAM
   - [ ] Добавить таймаут на повторную аутентификацию
   - [ ] Реализовать биометрическую аутентификацию для дешифрования

---

**Статус:** ⚠️ КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ В ПРОЦЕССЕ  
**Приоритет:** 🔴 P0 - Блокирует релиз  
**Ответственный:** Data Security Specialist
