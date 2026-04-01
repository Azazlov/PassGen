# 🔐 ChaCha20-Poly1305 Specification

**Версия:** 1.0  
**Дата:** 9 марта 2026  
**Статус:** ✅ Утверждено  
**Проект:** PassGen v0.5.0

---

## 1. ОБЗОР

Этот документ описывает спецификацию использования алгоритма **ChaCha20-Poly1305** в приложении PassGen для шифрования данных.

---

## 2. АЛГОРИТМ

### 2.1 Описание

**ChaCha20-Poly1305** — это алгоритм authenticated encryption with associated data (AEAD), который комбинирует:

- **ChaCha20** — потоковый шифр (256-bit ключ)
- **Poly1305** — код аутентификации сообщений (MAC)

**Стандарт:** RFC 8439  
**Тип:** AEAD (Authenticated Encryption with Associated Data)  
**Режим:** IETF (nonce + counter)

### 2.2 Параметры

| Параметр | Значение | Обоснование |
|---|---|---|
| **Длина ключа** | 256 бит (32 байта) | Стойкость к квантовым атакам |
| **Длина nonce** | 96 бит (12 байт) | Стандарт IETF |
| **Длина MAC** | 128 бит (16 байт) | Стандарт Poly1305 |
| **Размер блока** | 64 байта | Внутренний размер ChaCha20 |
| **Количество раундов** | 20 | Базовое количество |

### 2.3 Реализация в PassGen

**Пакет:** `cryptography` (Dart)  
**Класс:** `Chacha20.poly1305Aead()`

```dart
import 'package:cryptography/cryptography.dart';

final Chacha20 _algorithm = Chacha20.poly1305Aead();
```

---

## 3. ШИФРОВАНИЕ

### 3.1 Процесс шифрования

```
┌─────────────────────────────────────────────────────────┐
│                    ШИФРОВАНИЕ                           │
└─────────────────────────────────────────────────────────┘

  Plaintext (открытый текст)
       │
       ▼
  ┌─────────────────┐
  │   ChaCha20      │ ← Key (256 бит)
  │   (шифрование)  │ ← Nonce (96 бит)
  └────────┬────────┘
           │
           ▼
  Ciphertext (зашифрованный текст)
       │
       ▼
  ┌─────────────────┐
  │   Poly1305      │ ← Key (производный от ChaCha20)
  │   (MAC)         │ ← AAD (опционально)
  └────────┬────────┘
           │
           ▼
  ┌─────────────────────────────────────┐
  │  SecretBox                          │
  │  ├─ cipherText                      │
  │  ├─ nonce                           │
  │  └─ mac (Poly1305 tag)              │
  └─────────────────────────────────────┘
```

### 3.2 Код шифрования

```dart
import 'package:cryptography/cryptography.dart';

Future<Map<String, dynamic>> encrypt({
  required List<int> message,      // Открытый текст
  required List<int> password,     // Ключ шифрования
}) async {
  try {
    // 1. Генерируем уникальный nonce
    final nonce = generateRandomBytes(length: 32);

    // 2. Derive ключ из пароля
    final secretKey = await _deriveKey(password: password, nonce: nonce);

    // 3. Шифруем ChaCha20-Poly1305
    final algorithm = Chacha20.poly1305Aead();
    final secretBox = await algorithm.encrypt(
      message,
      secretKey: secretKey,
    );

    // 4. Возвращаем компоненты
    return {
      'nonce': CryptoUtils.encodeBytesBase64(nonce),
      'nonceBox': CryptoUtils.encodeBytesBase64(secretBox.nonce),
      'cipherText': CryptoUtils.encodeBytesBase64(secretBox.cipherText),
      'mac': CryptoUtils.encodeBytesBase64(secretBox.mac.bytes),
    };
  } catch (e) {
    throw EncryptionFailure(message: 'Ошибка шифрования: $e');
  }
}
```

### 3.3 Формат выходных данных

```json
{
  "nonce": "<base64, 32 байта>",
  "nonceBox": "<base64, 12 байт>",
  "cipherText": "<base64, переменная длина>",
  "mac": "<base64, 16 байт>"
}
```

---

## 4. ДЕШИФРОВАНИЕ

### 4.1 Процесс дешифрования

```
┌─────────────────────────────────────────────────────────┐
│                   ДЕШИФРОВАНИЕ                          │
└─────────────────────────────────────────────────────────┘

  SecretBox
  ├─ cipherText
  ├─ nonce
  └─ mac
       │
       ▼
  ┌─────────────────┐
  │  Проверка MAC   │ ← Key (производный)
  │  (Poly1305)     │
  └────────┬────────┘
           │
     ┌─────┴─────┐
     │           │
   ✅ MAC      ❌ MAC
   OK          FAIL
     │           │
     ▼           ▼
┌─────────┐  ┌──────────┐
│ChaCha20 │  │  Exception│
│Decrypt  │  │  (Integrity│
└────┬────┘  │   Failure) │
     │       └──────────┘
     ▼
Plaintext
```

### 4.2 Код дешифрования

```dart
Future<List<int>> decrypt({
  required Map<String, dynamic> encryptedData,
  required List<int> password,
}) async {
  try {
    // 1. Извлекаем компоненты
    final nonce = CryptoUtils.decodeBytesBase64(encryptedData['nonce']);
    final nonceBox = CryptoUtils.decodeBytesBase64(encryptedData['nonceBox']);
    final cipherText = CryptoUtils.decodeBytesBase64(encryptedData['cipherText']);
    final macBytes = CryptoUtils.decodeBytesBase64(encryptedData['mac']);

    // 2. Создаём SecretBox
    final secretBox = SecretBox(
      cipherText,
      nonce: nonceBox,
      mac: Mac(macBytes),
    );

    // 3. Derive ключ
    final secretKey = await _deriveKey(password: password, nonce: nonce);

    // 4. Дешифруем (с автоматической проверкой MAC)
    return await _algorithm.decrypt(secretBox, secretKey: secretKey);
  } catch (e) {
    throw EncryptionFailure(message: 'Ошибка дешифрования: $e');
  }
}
```

### 4.3 Проверка целостности

**Poly1305 MAC проверяется автоматически** при дешифровании.

Если MAC не совпадает:
```
Exception: MacVerificationFailed
```

**Обработка:**
```dart
try {
  final plaintext = await decrypt(encryptedData, key);
} catch (e) {
  if (e is MacVerificationFailed) {
    // Нарушение целостности!
    throw EncryptionFailure(message: 'MAC verification failed');
  }
}
```

---

## 5. УПРАВЛЕНИЕ NONCE

### 5.1 Требования

| Требование | Описание | Статус |
|---|---|---|
| **Уникальность** | Каждый nonce должен быть уникальным для данного ключа | ✅ Обязательно |
| **Непредсказуемость** | nonce должен генерироваться CSPRNG | ✅ Обязательно |
| **Длина** | 96 бит (12 байт) минимум | ✅ 32 байта |
| **Секретность** | nonce не является секретным | ✅ Хранится открыто |

### 5.2 Генерация nonce

```dart
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

### 5.3 Хранение nonce

**Формат:** Отдельно от ciphertext, в открытом виде

```
┌─────────────────────────────────────┐
│  Зашифрованная запись               │
├─────────────────────────────────────┤
│  nonce: [32 байта] ← открыто        │
│  ciphertext: [переменная] ← шифр    │
│  mac: [16 байт] ← открыто           │
└─────────────────────────────────────┘
```

**SQLite:**
```sql
CREATE TABLE password_entries (
  id INTEGER PRIMARY KEY,
  encrypted_password BLOB NOT NULL,  -- ciphertext
  nonce BLOB NOT NULL,                -- nonce (открыто)
  ...
);
```

---

## 6. ДЕРИВАЦИЯ КЛЮЧА

### 6.1 Алгоритм деривации

**Алгоритм:** PBKDF2-HMAC-SHA256  
**Итерации:** 10,000  
**Длина ключа:** 256 бит

### 6.2 Код деривации

```dart
Future<SecretKey> _deriveKey({
  required List<int> password,
  List<int>? nonce,
}) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 10000,
    bits: 256,
  );

  nonce ??= generateRandomBytes(length: 32);

  return pbkdf2.deriveKeyFromPassword(
    password: CryptoUtils.encodeBytesBase64(password),
    nonce: Uint8List.fromList(nonce),
  );
}
```

### 6.3 Параметры PBKDF2

| Параметр | Значение | Стандарт |
|---|---|---|
| **Алгоритм** | HMAC-SHA256 | NIST SP 800-132 |
| **Итерации** | 10,000 | OWASP рекомендует ≥10,000 |
| **Длина ключа** | 256 бит | Соответствует ChaCha20 |
| **Соль** | 32 байта | CSPRNG |

---

## 7. ФОРМАТ .PASSGEN

### 7.1 Структура файла

```
┌─────────────────────────────────────┐
│ HEADER: "PASSGEN_V1" (10 байт)      │
├─────────────────────────────────────┤
│ VERSION: 1 (1 байт)                 │
├─────────────────────────────────────┤
│ FLAGS: 0 (1 байт)                   │
├─────────────────────────────────────┤
│ NONCE: 32 байта                     │
├─────────────────────────────────────┤
│ DATA_LENGTH: 4 байта (little-endian)│
├─────────────────────────────────────┤
│ DATA: зашифрованный JSON (ChaCha20) │
├─────────────────────────────────────┤
│ MAC: 16 байт (Poly1305 tag)         │
└─────────────────────────────────────┘
```

### 7.2 Кодирование

```dart
Future<String> exportToJson({
  required List<Map<String, dynamic>> data,
  required String masterPassword,
}) async {
  // 1. Сериализуем в JSON
  final jsonData = jsonEncode(data);
  final jsonDataBytes = utf8.encode(jsonData);

  // 2. Генерируем nonce
  final nonce = List<int>.generate(32, (_) => random.nextInt(256));

  // 3. Derive ключ
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 10000,
    bits: 256,
  );

  final secretKey = await pbkdf2.deriveKeyFromPassword(
    password: masterPassword,
    nonce: Uint8List.fromList(nonce),
  );

  // 4. Шифруем ChaCha20-Poly1305
  final algorithm = Chacha20.poly1305Aead();
  final secretBox = await algorithm.encrypt(
    jsonDataBytes,
    secretKey: secretKey,
  );

  // 5. Формируем файл
  final headerBytes = utf8.encode(magicHeader);
  final versionBytes = [formatVersion];
  final flagsBytes = [flagsNone];
  final dataLengthBytes = _intToBytes(secretBox.cipherText.length);

  final allBytes = <int>[
    ...headerBytes,
    ...versionBytes,
    ...flagsBytes,
    ...nonce,
    ...dataLengthBytes,
    ...secretBox.cipherText,
    ...secretBox.mac.bytes,
  ];

  // 6. Base64 кодирование
  return base64Encode(allBytes);
}
```

---

## 8. БЕЗОПАСНОСТЬ

### 8.1 Криптографическая стойкость

| Атака | Стойкость | Примечание |
|---|---|---|
| Brute-force ключа | 2^256 операций | Практически невозможно |
| Атака на nonce | Уникальность гарантирована | CSPRNG 32 байта |
| Атака на MAC | 2^128 операций | Практически невозможно |
| Квантовая атака (Grover) | 2^128 операций | Стойкий |

### 8.2 Рекомендации по использованию

#### ✅ DO (Правильно)

```dart
// Генерировать уникальный nonce для каждого шифрования
final nonce = generateRandomBytes(length: 32);

// Использовать CSPRNG
final random = Random.secure();

// Проверять MAC при дешифровании
try {
  final plaintext = await decrypt(encryptedData, key);
} catch (e) {
  // Обработать ошибку MAC
}

// Хранить nonce открыто вместе с ciphertext
```

#### ❌ DON'T (Неправильно)

```dart
// ❌ Повторное использование nonce
final nonce = fixedNonce;  // НИКОГДА!

// ❌ Предсказуемый генератор
final random = Random();  // Без .secure()

// ❌ Игнорирование проверки MAC
await algorithm.decrypt(secretBox, key);  // Без try-catch

// ❌ Хранение nonce отдельно от ciphertext
```

---

## 9. ТЕСТИРОВАНИЕ

### 9.1 Unit-тесты

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChaCha20-Poly1305 Tests', () {
    test('Шифрование и дешифрование', () async {
      final encryptor = EncryptorLocalDataSource();
      final message = utf8.encode('Hello, World!');
      final password = [1, 2, 3, 4, 5, 6, 7, 8];

      // Шифрование
      final encrypted = await encryptor.encrypt(
        message: message,
        password: password,
      );

      // Дешифрование
      final decrypted = await encryptor.decrypt(
        encryptedData: encrypted,
        password: password,
      );

      expect(decrypted, equals(message));
    });

    test('Уникальность nonce', () async {
      final encryptor = EncryptorLocalDataSource();
      final message = utf8.encode('Test');
      final password = [1, 2, 3, 4];

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
    });

    test('Нарушение целостности (MAC)', () async {
      final encryptor = EncryptorLocalDataSource();
      final message = utf8.encode('Test');
      final password = [1, 2, 3, 4];

      final encrypted = await encryptor.encrypt(
        message: message,
        password: password,
      );

      // Повредим ciphertext
      encrypted['cipherText'] = 'corrupted';

      expect(
        () => encryptor.decrypt(
          encryptedData: encrypted,
          password: password,
        ),
        throwsA(isA<EncryptionFailure>()),
      );
    });
  });
}
```

---

## 10. ССЫЛКИ

### 10.1 Стандарты

| Стандарт | Описание |
|---|---|
| **RFC 8439** | ChaCha20 and Poly1305 for IETF Protocols |
| **NIST SP 800-38D** | Recommendation for Block Cipher Modes of Operation |
| **OWASP** | Cryptographic Storage Cheat Sheet |

### 10.2 Реализация

| Компонент | Пакет | Версия |
|---|---|---|
| **ChaCha20** | `cryptography` | ^2.7.0 |
| **PBKDF2** | `cryptography` | ^2.7.0 |
| **CSPRNG** | `dart:math` | Built-in |

---

## 11. ИСТОРИЯ ИЗМЕНЕНИЙ

| Версия | Дата | Изменения | Автор |
|---|---|---|---|
| 1.0 | 9 марта 2026 | Первоначальная версия | AI Data Security Specialist |

---

**Документ утверждён:** 9 марта 2026  
**Дата следующего пересмотра:** 9 марта 2027  
**Статус:** ✅ Актуально
