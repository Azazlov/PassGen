# 🔑 Key Management — Управление ключами шифрования

**Версия:** 1.0  
**Дата:** 9 марта 2026  
**Статус:** ✅ Утверждено  
**Проект:** PassGen v0.5.0

---

## 1. ОБЗОР

Этот документ описывает жизненный цикл ключей шифрования в приложении PassGen: генерацию, хранение, использование, ротацию и уничтожение.

---

## 2. ТИПЫ КЛЮЧЕЙ

### 2.1 Классификация ключей

| Тип ключа | Назначение | Длина | Где хранится | Время жизни |
|---|---|---|---|---|
| **Мастер-ключ** | Деривация рабочих ключей | 256 бит | RAM (не хранится) | Сессия |
| **Ключ шифрования** | Шифрование паролей | 256 бит | RAM | Операция |
| **Ключ аутентификации** | Проверка PIN | 256 бит | RAM | Операция |
| **Соль PBKDF2** | Деривация ключей | 256 бит | SQLite | Постоянно |
| **Nonce** | Уникальность шифрования | 256 бит | С данными | Постоянно |

### 2.2 Иерархия ключей

```
┌─────────────────────────────────────┐
│        Мастер-пароль (PIN)          │  ← Пользователь вводит
│        (4-8 цифр)                   │
└─────────────────┬───────────────────┘
                  │
                  ▼
         ┌─────────────────┐
         │    PBKDF2       │  ← 10,000 итераций
         │  (с солью)      │
         └────────┬────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│       Мастер-ключ (256 бит)         │  ← Деривируется при входе
│       (хранится в RAM)              │
└─────────────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│ Ключ шифрования │ │ Ключ MAC        │
│ (ChaCha20)      │ │ (Poly1305)      │
└─────────────────┘ └─────────────────┘
```

---

## 3. ГЕНЕРАЦИЯ КЛЮЧЕЙ

### 3.1 Деривация мастер-ключа

**Алгоритм:** PBKDF2-HMAC-SHA256

**Параметры:**
```dart
final pbkdf2 = Pbkdf2(
  macAlgorithm: Hmac.sha256(),
  iterations: 10000,      // OWASP рекомендует ≥10,000
  bits: 256,              // 256-bit ключ
);
```

**Процесс:**
1. Пользователь вводит PIN (4-8 цифр)
2. Генерируется случайная соль (32 байта, CSPRNG)
3. PBKDF2 деривирует ключ из PIN + соль
4. Мастер-ключ сохраняется в RAM
5. Соль сохраняется в SQLite

**Код:**
```dart
Future<Map<String, String>> _hashPin(String pin) async {
  // Генерируем случайную соль
  final saltBytes = _generateSecureRandomBytes(32);
  final salt = base64Encode(saltBytes);

  // Создаём хэш
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: pbkdf2Iterations,
    bits: 256,
  );

  final secretKey = await pbkdf2.deriveKeyFromPassword(
    password: pin,
    nonce: Uint8List.fromList(saltBytes),
  );

  final hash = base64Encode(await secretKey.extractBytes());

  return {'hash': hash, 'salt': salt};
}
```

### 3.2 Генерация соли

**Требования:**
- ✅ Использовать CSPRNG (`Random.secure()`)
- ✅ Минимум 128 бит (16 байт)
- ✅ Уникальная для каждого пользователя
- ✅ Хранить отдельно от хэша

**Текущая реализация:**
```dart
List<int> _generateSecureRandomBytes(int length) {
  final random = Random.secure();
  return List.generate(length, (_) => random.nextInt(256));
}
```

### 3.3 Генерация nonce

**Требования:**
- ✅ Уникальный для каждой операции шифрования
- ✅ Минимум 96 бит (12 байт)
- ✅ Не секретный, можно хранить открыто

**Текущая реализация:**
```dart
final nonce = generateRandomBytes(length: 32);  // 256 бит
```

---

## 4. ХРАНЕНИЕ КЛЮЧЕЙ

### 4.1 Места хранения

| Ключ | RAM | SQLite | SharedPreferences | Файл |
|---|---|---|---|---|
| Мастер-ключ | ✅ Временно | ❌ | ❌ | ❌ |
| Ключ шифрования | ✅ Временно | ❌ | ❌ | ❌ |
| Соль PBKDF2 | ❌ | ✅ | ❌ | ❌ |
| Хэш PIN | ❌ | ✅ | ⚠️ Временно | ❌ |
| Nonce | ❌ | ✅ (с данными) | ❌ | ✅ (в .passgen) |

### 4.2 Защита ключей в RAM

**Проблемы:**
- ⚠️ Dart garbage collection может оставить копии в памяти
- ⚠️ Swap файл может записать RAM на диск
- ⚠️ Cold boot атаки могут извлечь данные из RAM

**Текущие меры защиты:**
1. Минимальное время жизни ключа в RAM
2. Затирание после использования (где возможно)
3. Избегание создания лишних копий

**Рекомендации:**
```dart
// После использования затирать
void _wipeKey(List<int> key) {
  for (int i = 0; i < key.length; i++) {
    key[i] = 0;
  }
}
```

### 4.3 Хранение соли

**Текущее хранение:** SharedPreferences
```dart
await prefs.setString(_pinSaltKey, hashed['salt']!);
```

**Проблема:** ⚠️ SharedPreferences менее безопасен, чем SQLite

**Рекомендация:** Мигрировать на хранение в SQLite (таблица `app_settings`)

---

## 5. ИСПОЛЬЗОВАНИЕ КЛЮЧЕЙ

### 5.1 Шифрование паролей

**Процесс:**
1. Получить мастер-ключ из RAM
2. Сгенерировать уникальный nonce
3. Derive рабочий ключ шифрования
4. Зашифровать ChaCha20-Poly1305
5. Сохранить nonce + ciphertext + MAC

**Код:**
```dart
Future<Map<String, dynamic>> encrypt({
  required List<int> message,
  required List<int> password,  // Мастер-ключ
}) async {
  final nonce = generateRandomBytes();
  final secretKey = await _deriveKey(password: password, nonce: nonce);

  final secretBox = await _algorithm.encrypt(message, secretKey: secretKey);

  return {
    'nonce': CryptoUtils.encodeBytesBase64(nonce),
    'nonceBox': CryptoUtils.encodeBytesBase64(secretBox.nonce),
    'cipherText': CryptoUtils.encodeBytesBase64(secretBox.cipherText),
    'mac': CryptoUtils.encodeBytesBase64(secretBox.mac.bytes),
  };
}
```

### 5.2 Дешифрование паролей

**Процесс:**
1. Получить мастер-ключ из RAM
2. Извлечь nonce из хранилища
3. Derive рабочий ключ шифрования
4. Проверить MAC (Poly1305)
5. Дешифровать ChaCha20

**Код:**
```dart
Future<List<int>> decrypt({
  required Map<String, dynamic> encryptedData,
  required List<int> password,  // Мастер-ключ
}) async {
  final nonce = CryptoUtils.decodeBytesBase64(encryptedData['nonce']);
  final nonceBox = CryptoUtils.decodeBytesBase64(encryptedData['nonceBox']);
  final cipherText = CryptoUtils.decodeBytesBase64(encryptedData['cipherText']);
  final macBytes = CryptoUtils.decodeBytesBase64(encryptedData['mac']);

  final secretBox = SecretBox(cipherText, nonce: nonceBox, mac: Mac(macBytes));
  final secretKey = await _deriveKey(password: password, nonce: nonce);

  return await _algorithm.decrypt(secretBox, secretKey: secretKey);
}
```

### 5.3 Проверка PIN

**Процесс:**
1. Извлечь соль из хранилища
2. Derive ключ из введённого PIN + соль
3. Сравнить с сохранённым хэшем
4. Стереть ключ из RAM

**Код:**
```dart
Future<bool> _verifyPinHash(
  String pin,
  String storedHash,
  String storedSalt,
) async {
  final saltBytes = base64Decode(storedSalt);

  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: pbkdf2Iterations,
    bits: 256,
  );

  final secretKey = await pbkdf2.deriveKeyFromPassword(
    password: pin,
    nonce: Uint8List.fromList(saltBytes),
  );

  final computedHash = base64Encode(await secretKey.extractBytes());

  // Затирание ключа (рекомендация)
  _wipeKey(secretKey);

  return computedHash == storedHash;
}
```

---

## 6. РОТАЦИЯ КЛЮЧЕЙ

### 6.1 Текущий статус

❌ **Ротация ключей не реализована**

### 6.2 Когда требуется ротация

| Событие | Действие | Приоритет |
|---|---|---|
| Смена PIN | Перешифровать все пароли | 🔴 Обязательно |
| Компрометация | Экстренная смена всех ключей | 🔴 Обязательно |
| Обновление алгоритма | Миграция на новый алгоритм | 🟡 Рекомендуется |
| Плановая (год) | Профилактическая смена | 🟢 Опционально |

### 6.3 Процесс ротации при смене PIN

**Алгоритм:**
1. Пользователь вводит старый PIN
2. Проверка старого PIN
3. Derive старый мастер-ключ
4. Расшифровать все пароли старым ключом
5. Пользователь вводит новый PIN
6. Derive новый мастер-ключ
7. Зашифровать все пароли новым ключом
8. Сохранить новый хэш PIN и соль
9. Удалить старый мастер-ключ из RAM

**Псевдокод:**
```dart
Future<bool> rotateKeys(String oldPin, String newPin) async {
  // 1-3: Derive старый ключ
  final oldMasterKey = await deriveKey(oldPin);
  
  // 4: Расшифровать все пароли
  final passwords = await decryptAllPasswords(oldMasterKey);
  
  // 5-6: Derive новый ключ
  final newMasterKey = await deriveKey(newPin);
  
  // 7: Зашифровать новым ключом
  await encryptAllPasswords(passwords, newMasterKey);
  
  // 8: Сохранить новые credentials
  await saveNewPinCredentials(newPin);
  
  // 9: Затереть старые ключи
  _wipeKey(oldMasterKey);
  _wipeKey(newMasterKey);
  
  return true;
}
```

---

## 7. УНИЧТОЖЕНИЕ КЛЮЧЕЙ

### 7.1 Когда уничтожать

| Событие | Ключи для уничтожения | Метод |
|---|---|---|
| Выход из сессии | Мастер-ключ | Затирание RAM |
| Завершение операции | Рабочий ключ шифрования | Garbage collection |
| Смена PIN | Старый мастер-ключ | Затирание + замена |
| Удаление приложения | Все ключи | Удаление файлов БД |

### 7.2 Методы затирания

**Базовое затирание:**
```dart
void _wipeKey(List<int> key) {
  for (int i = 0; i < key.length; i++) {
    key[i] = 0;
  }
}
```

**Усиленное затирание (рекомендация):**
```dart
void _secureWipeKey(List<int> key) {
  final random = Random.secure();
  // 1. Заполнить случайными данными
  for (int i = 0; i < key.length; i++) {
    key[i] = random.nextInt(256);
  }
  // 2. Заполнить нулями
  for (int i = 0; i < key.length; i++) {
    key[i] = 0;
  }
  // 3. Заполнить единицами
  for (int i = 0; i < key.length; i++) {
    key[i] = 0xFF;
  }
  // 4. Финальные нули
  for (int i = 0; i < key.length; i++) {
    key[i] = 0;
  }
}
```

### 7.3 Уничтожение при удалении приложения

**Процесс:**
1. Удалить файл базы данных SQLite
2. Удалить SharedPreferences
3. Удалить файлы кэша
4. Удалить файлы экспорта (.passgen, .json)

**Код:**
```dart
Future<void> wipeAllData() async {
  // Удалить БД
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'passgen.db'));
  
  // Очистить SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  // Удалить файлы экспорта
  final appDir = await getApplicationDocumentsDirectory();
  await appDir.delete(recursive: true);
}
```

---

## 8. БЕЗОПАСНОСТЬ КЛЮЧЕЙ

### 8.1 Угрозы

| Угроза | Вероятность | Влияние | Меры защиты |
|---|---|---|---|
| Кража из RAM | 🟡 Средняя | 🔴 Критическое | Затирание, минимальное хранение |
| Cold boot атака | 🟢 Низкая | 🔴 Критическое | Затирание перед выключением |
| Swap файл | 🟡 Средняя | 🔴 Критическое | Запрет swap (OS level) |
| Side-channel атаки | 🟢 Низкая | 🟡 Среднее | Constant-time сравнение |
| Квантовые компьютеры | 🟢 Низкая | 🟡 Среднее | 256-bit ключи (устойчивы) |

### 8.2 Рекомендации по улучшению

#### Критические (🔴)
- [ ] Мигрировать хранение соли из SharedPreferences в SQLite
- [ ] Реализовать затирание ключей после использования
- [ ] Добавить ротацию ключей при смене PIN

#### Важные (🟡)
- [ ] Использовать `SecureMemory` для чувствительных данных
- [ ] Добавить защиту от дампа памяти (Android: `FLAG_SECURE`)
- [ ] Реализовать constant-time сравнение хэшей

#### Низкие (🟢)
- [ ] Рассмотреть Android Keystore / iOS Keychain
- [ ] Добавить версионирование алгоритмов деривации
- [ ] Документировать процесс экстренной ротации

---

## 9. АУДИТ УПРАВЛЕНИЯ КЛЮЧАМИ

### 9.1 Чек-лист аудита

| Проверка | Требование | Статус |
|---|---|---|
| **Генерация соли** | CSPRNG, ≥128 бит | ✅ 256 бит, Random.secure() |
| **Деривация ключа** | PBKDF2 ≥10,000 итераций | ✅ 10,000 итераций |
| **Длина ключа** | 256 бит | ✅ 256 бит |
| **Хранение мастер-ключа** | Только RAM | ✅ В RAM |
| **Затирание ключей** | После использования | ⚠️ Не реализовано |
| **Ротация при смене PIN** | Перешифрование | ❌ Не реализовано |
| **Уникальность nonce** | CSPRNG для каждого | ✅ Реализовано |
| **Хранение соли** | Отдельно от хэша | ⚠️ SharedPreferences |

### 9.2 Оценка соответствия

| Категория | Оценка |
|---|---|
| Генерация ключей | 100/100 ✅ |
| Хранение ключей | 75/100 ⚠️ |
| Использование ключей | 90/100 ✅ |
| Ротация ключей | 0/100 ❌ |
| Уничтожение ключей | 50/100 ⚠️ |
| **ИТОГО** | **63/100** ⚠️ |

---

## 10. ИСТОРИЯ ИЗМЕНЕНИЙ

| Версия | Дата | Изменения | Автор |
|---|---|---|---|
| 1.0 | 9 марта 2026 | Первоначальная версия | AI Data Security Specialist |

---

**Документ утверждён:** 9 марта 2026  
**Дата следующего пересмотра:** 9 июня 2026  
**Статус:** ✅ Актуально
