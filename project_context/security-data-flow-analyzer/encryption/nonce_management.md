# 🔢 Nonce Management Specification — Управление nonce

**Версия:** 1.0  
**Дата:** 9 марта 2026  
**Статус:** ✅ Утверждено  
**Проект:** PassGen v0.5.0

---

## 1. ОБЗОР

Этот документ описывает спецификацию управления **nonce** (number used once) для алгоритма шифрования ChaCha20-Poly1305 в приложении PassGen.

---

## 2. ТЕРМИНОЛОГИЯ

### 2.1 Определения

| Термин | Определение |
|---|---|
| **Nonce** | Number used once — уникальное число для одной операции шифрования |
| **IV** | Initialization Vector — более общий термин |
| **Counter** | Счётчик в режиме counter mode |
| **CSPRNG** | Cryptographically Secure Pseudo-Random Number Generator |

### 2.2 Обозначения

```
Nonce = Number used once
IV    = Initialization Vector
```

В контексте ChaCha20-Poly1305: **Nonce = IV**

---

## 3. НАЗНАЧЕНИЕ NONCE

### 3.1 Зачем нужен nonce?

**Основная цель:** Обеспечить уникальность зашифрованных сообщений при использовании одного ключа.

```
Ключ + Nonce₁ → Ciphertext₁  ✅ Уникальный
Ключ + Nonce₂ → Ciphertext₂  ✅ Уникальный
Ключ + Nonce₁ → Ciphertext₁' ❌ КОЛЛИЗИЯ!
```

### 3.2 Последствия повторного использования nonce

**Критическая уязвимость:**

Если один nonce используется дважды с одним ключом:
```
Ciphertext₁ = Plaintext₁ ⊕ ChaCha20(Key, Nonce)
Ciphertext₂ = Plaintext₂ ⊕ ChaCha20(Key, Nonce)

Ciphertext₁ ⊕ Ciphertext₂ = Plaintext₁ ⊕ Plaintext₂
```

**Результат:** XOR двух открытых текстов известен атакующему!

### 3.3 Требования к nonce

| Требование | Описание | Критичность |
|---|---|---|
| **Уникальность** | Никогда не повторять для данного ключа | 🔴 Критическое |
| **Непредсказуемость** | Генерироваться CSPRNG | 🔴 Критическое |
| **Длина** | Соответствовать алгоритму | 🟡 Высокое |
| **Синхронизация** | Доступен при дешифровании | 🟡 Высокое |

---

## 4. NONCE В CHACHA20

### 4.1 Параметры ChaCha20

| Параметр | Значение |
|---|---|
| **Минимальная длина nonce** | 96 бит (12 байт) |
| **Рекомендуемая длина** | 96 бит (IETF стандарт) |
| **Максимальная длина** | 192 бит (24 байта) |
| **Внутренний counter** | 32 бита |

### 4.2 Структура nonce в PassGen

**Используемая длина:** 256 бит (32 байта) — превышает стандарт

**Обоснование:**
- ✅ Больший запас уникальности
- ✅ Совместимость с PBKDF2 (также 32 байта)
- ✅ Минимальные накладные расходы

```
┌────────────────────────────────────────┐
│  Nonce (32 байта / 256 бит)            │
│  ───────────────────────────────────   │
│  [0][1][2][3]...[30][31]              │
│   ↑                                   │
│   2^256 возможных значений            │
└────────────────────────────────────────┘
```

---

## 5. ГЕНЕРАЦИЯ NONCE

### 5.1 Алгоритм генерации

**Генератор:** CSPRNG (Cryptographically Secure PRNG)

**Dart реализация:**
```dart
import 'dart:math';

List<int> generateRandomBytes({
  int length = 32,
  List<int> range = const [0, 255],
}) {
  final random = Random.secure();  // CSPRNG
  return List.generate(
    length,
    (_) => random.nextInt(range[1] - range[0]) + range[0],
  );
}
```

### 5.2 Характеристики CSPRNG

| Характеристика | Значение |
|---|---|
| **Алгоритм** | Fortuna-like (Dart) |
| **Энтропия** | ≥256 бит |
| **Период** | ≥2^256 |
| **Предсказуемость** | Практически невозможна |

### 5.3 Инициализация CSPRNG

**Dart автоматически:**
- Собирает энтропию из ОС
- Использует системные источники случайности
- Автоматически пересевает

**Требуется от разработчика:**
```dart
// ✅ ПРАВИЛЬНО
final random = Random.secure();

// ❌ НЕПРАВИЛЬНО
final random = Random();  // Без .secure()!
```

---

## 6. ХРАНЕНИЕ NONCE

### 6.1 Принцип хранения

**Nonce НЕ является секретным!**

```
┌─────────────────────────────────────┐
│  Можно хранить открыто:             │
│  • В одном файле с ciphertext       │
│  • В одной записи БД                │
│  • В заголовке файла                │
└─────────────────────────────────────┘
```

### 6.2 Формат хранения в БД

**Таблица `password_entries`:**
```sql
CREATE TABLE password_entries (
  id INTEGER PRIMARY KEY,
  service TEXT NOT NULL,
  login TEXT,
  encrypted_password BLOB NOT NULL,  -- ciphertext
  nonce BLOB NOT NULL,                -- nonce (открыто!)
  created_at INTEGER,
  updated_at INTEGER
);
```

### 6.3 Формат хранения в .passgen

```
┌─────────────────────────────────────┐
│ HEADER: "PASSGEN_V1" (10 байт)      │
├─────────────────────────────────────┤
│ VERSION: 1 (1 байт)                 │
├─────────────────────────────────────┤
│ FLAGS: 0 (1 байт)                   │
├─────────────────────────────────────┤
│ NONCE: 32 байта ← ОТКРЫТО           │
├─────────────────────────────────────┤
│ DATA_LENGTH: 4 байта                │
├─────────────────────────────────────┤
│ DATA: ciphertext                    │
├─────────────────────────────────────┤
│ MAC: 16 байт                        │
└─────────────────────────────────────┘
```

### 6.4 Код сохранения

```dart
// Сохранение в SQLite
await db.insert('password_entries', {
  'service': service,
  'login': login,
  'encrypted_password': encryptedData['cipherText'],  // BLOB
  'nonce': encryptedData['nonce'],                     // BLOB (открыто)
  'created_at': now,
  'updated_at': now,
});
```

---

## 7. ИСПОЛЬЗОВАНИЕ NONCE

### 7.1 Шифрование

**Процесс:**
```dart
Future<Map<String, dynamic>> encrypt({
  required List<int> message,
  required List<int> password,
}) async {
  // 1. Генерируем УНИКАЛЬНЫЙ nonce
  final nonce = generateRandomBytes(length: 32);

  // 2. Derive ключ
  final secretKey = await _deriveKey(password: password, nonce: nonce);

  // 3. Шифруем с nonce
  final algorithm = Chacha20.poly1305Aead();
  final secretBox = await algorithm.encrypt(
    message,
    secretKey: secretKey,
  );

  // 4. Возвращаем nonce + ciphertext + mac
  return {
    'nonce': CryptoUtils.encodeBytesBase64(nonce),
    'cipherText': CryptoUtils.encodeBytesBase64(secretBox.cipherText),
    'mac': CryptoUtils.encodeBytesBase64(secretBox.mac.bytes),
  };
}
```

### 7.2 Дешифрование

**Процесс:**
```dart
Future<List<int>> decrypt({
  required Map<String, dynamic> encryptedData,
  required List<int> password,
}) async {
  // 1. Извлекаем nonce (открыто)
  final nonce = CryptoUtils.decodeBytesBase64(encryptedData['nonce']);

  // 2. Извлекаем ciphertext и mac
  final cipherText = CryptoUtils.decodeBytesBase64(encryptedData['cipherText']);
  final macBytes = CryptoUtils.decodeBytesBase64(encryptedData['mac']);

  // 3. Создаём SecretBox
  final secretBox = SecretBox(
    cipherText,
    nonce: nonce,  // ← Тот же nonce!
    mac: Mac(macBytes),
  );

  // 4. Derive ключ с тем же nonce
  final secretKey = await _deriveKey(password: password, nonce: nonce);

  // 5. Дешифруем
  return await _algorithm.decrypt(secretBox, secretKey: secretKey);
}
```

---

## 8. ГАРАНТИИ УНИКАЛЬНОСТИ

### 8.1 Вероятность коллизии

**Формула (парадокс дней рождения):**
```
P(collision) ≈ n² / (2 × 2^256)

Где:
  n = количество операций шифрования
  2^256 = количество возможных nonce
```

**Расчёт для PassGen:**
| Операций (n) | Вероятность коллизии |
|---|---|
| 1,000 | ~10^-71 |
| 1,000,000 | ~10^-65 |
| 1,000,000,000 | ~10^-59 |
| 2^64 | ~10^-13 |

**Вывод:** Практически невозможно при 32 байтах

### 8.2 Стратегии обеспечения уникальности

| Стратегия | Описание | PassGen |
|---|---|---|
| **Случайная** | CSPRNG генерация | ✅ Используется |
| **Счётчик** | Инкрементальный nonce | ❌ Не используется |
| **Гибридная** | Timestamp + counter | ❌ Не используется |
| **UUID-based** | UUID v4 | ❌ Не используется |

### 8.3 Почему случайная генерация?

**Преимущества:**
- ✅ Простота реализации
- ✅ Не требует состояния
- ✅ Статистическая уникальность
- ✅ Нет риска рассинхронизации

**Недостатки:**
- ⚠️ Теоретическая возможность коллизии
- ⚠️ Требует качественный CSPRNG

---

## 9. ПРОВЕРКА УНИКАЛЬНОСТИ

### 9.1 Аудит nonce

**Периодичность:** Ежемесячно

**Проверка:**
```sql
-- Поиск дубликатов nonce в БД
SELECT nonce, COUNT(*) as count
FROM password_entries
GROUP BY nonce
HAVING COUNT(*) > 1;
```

**Ожидаемый результат:** 0 записей

### 9.2 Мониторинг

**Метрики:**
- Количество сгенерированных nonce
- Количество записей в БД
- Статистика коллизий (должна быть 0)

**Логирование:**
```dart
// Логирование для аудита (не сами nonce!)
logEventUseCase.execute(
  actionType: EventTypes.PWD_CREATED,
  details: 'Password encrypted with new nonce',
);
```

---

## 10. БЕЗОПАСНОСТЬ

### 10.1 Угрозы

| Угроза | Вероятность | Влияние | Меры защиты |
|---|---|---|---|
| **Повтор nonce** | 🟢 Очень низкая | 🔴 Критическое | CSPRNG 32 байта |
| **Предсказание nonce** | 🟢 Очень низкая | 🔴 Критическое | Random.secure() |
| **Кража nonce** | 🟡 Средняя | 🟢 Низкое | Не является секретом |
| **Модификация nonce** | 🟢 Низкая | 🔴 Критическое | MAC проверка |

### 10.2 Best Practices

#### ✅ DO (Правильно)

```dart
// Генерировать новый nonce для КАЖДОГО шифрования
final nonce = generateRandomBytes(length: 32);

// Использовать CSPRNG
final random = Random.secure();

// Хранить nonce вместе с ciphertext
await db.insert('password_entries', {
  'encrypted_password': ciphertext,
  'nonce': nonce,  // Открыто!
});

// Проверять MAC при дешифровании
try {
  await decrypt(encryptedData, key);
} catch (e) {
  // Обработать ошибку
}
```

#### ❌ DON'T (Неправильно)

```dart
// ❌ Повторное использование nonce
final nonce = fixedNonce;  // НИКОГДА!

// ❌ Предсказуемый генератор
final random = Random();  // Без .secure()!

// ❌ Инкрементальный nonce
nonce[31]++;  // Риск рассинхронизации!

// ❌ Хранить nonce отдельно
// (не критично, но неудобно)
```

---

## 11. ТЕСТИРОВАНИЕ

### 11.1 Unit-тесты

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nonce Management Tests', () {
    test('Генерация уникальных nonce', () async {
      final encryptor = EncryptorLocalDataSource();
      final nonces = <String>{};

      // Генерируем 1000 nonce
      for (int i = 0; i < 1000; i++) {
        final nonce = encryptor.generateRandomBytes(length: 32);
        final nonceBase64 = CryptoUtils.encodeBytesBase64(nonce);

        // Проверяем уникальность
        expect(nonces.contains(nonceBase64), isFalse);
        nonces.add(nonceBase64);
      }

      expect(nonces.length, equals(1000));
    });

    test('Длина nonce', () {
      final encryptor = EncryptorLocalDataSource();

      for (int i = 0; i < 100; i++) {
        final nonce = encryptor.generateRandomBytes(length: 32);
        expect(nonce.length, equals(32));  // 256 бит
      }
    });

    test('Шифрование с разными nonce', () async {
      final encryptor = EncryptorLocalDataSource();
      final message = utf8.encode('Hello, World!');
      final password = [1, 2, 3, 4, 5, 6, 7, 8];

      final encrypted1 = await encryptor.encrypt(
        message: message,
        password: password,
      );
      final encrypted2 = await encryptor.encrypt(
        message: message,
        password: password,
      );

      // nonce должны быть разными
      expect(encrypted1['nonce'], isNot(equals(encrypted2['nonce'])));

      // ciphertext тоже (из-за разных nonce)
      expect(encrypted1['cipherText'], isNot(equals(encrypted2['cipherText'])));
    });

    test('Дешифрование с правильным nonce', () async {
      final encryptor = EncryptorLocalDataSource();
      final message = utf8.encode('Test message');
      final password = [1, 2, 3, 4];

      final encrypted = await encryptor.encrypt(
        message: message,
        password: password,
      );

      final decrypted = await encryptor.decrypt(
        encryptedData: encrypted,
        password: password,
      );

      expect(decrypted, equals(message));
    });
  });
}
```

---

## 12. ССЫЛКИ

### 12.1 Стандарты

| Стандарт | Описание |
|---|---|
| **RFC 8439** | ChaCha20 and Poly1305 for IETF Protocols |
| **NIST SP 800-38D** | Recommendation for Block Cipher Modes of Operation |
| **RFC 4086** | Randomness Requirements for Security |

### 12.2 Реализация

| Компонент | Пакет | Версия |
|---|---|---|
| **ChaCha20** | `cryptography` | ^2.7.0 |
| **CSPRNG** | `dart:math` | Built-in |
| **Base64** | `dart:convert` | Built-in |

---

## 13. ПРИЛОЖЕНИЕ A: ЧАСТО ЗАДАВАЕМЫЕ ВОПРОСЫ

### Q1: Можно ли использовать один nonce для разных ключей?

**A:** Да, это безопасно. nonce должен быть уникальным только для **конкретного ключа**.

```
Ключ₁ + Nonce₁ → Ciphertext₁  ✅
Ключ₂ + Nonce₁ → Ciphertext₂  ✅ (разные ключи)
```

### Q2: Нужно ли шифровать nonce?

**A:** Нет, nonce не является секретным. Его можно хранить открыто.

### Q3: Что делать, если произошла коллизия nonce?

**A:** Это практически невозможно при 32 байтах. Если произошло:
1. Немедленно сменить все ключи
2. Перешифровать все данные
3. Провести расследование инцидента

### Q4: Почему 32 байта, а не 12 (стандарт IETF)?

**A:** Больший размер даёт дополнительный запас уникальности без существенных накладных расходов.

---

## 14. ИСТОРИЯ ИЗМЕНЕНИЙ

| Версия | Дата | Изменения | Автор |
|---|---|---|---|
| 1.0 | 9 марта 2026 | Первоначальная версия | AI Data Security Specialist |

---

**Документ утверждён:** 9 марта 2026  
**Дата следующего пересмотра:** 9 марта 2027  
**Статус:** ✅ Актуально
