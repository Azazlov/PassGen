import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Утилита детерминированной трансформации текста в стойкий пароль.
///
/// Каждое правило — чистая функция: одинаковый вход всегда даёт
/// одинаковый выход. Никаких случайных данных.
class GlitchTransformer {
  const GlitchTransformer._();

  // ==================== ТАБЛИЦЫ ПОДСТАНОВОК ====================

  static const Map<String, String> _visualSubstitutions = {
    'a': '@',
    'A': '@',
    'e': '3',
    'E': '3',
    'i': '1',
    'I': '1',
    'o': '0',
    'O': '0',
    's': '\$',
    'S': '\$',
    't': '7',
    'T': '7',
    'l': '!',
    'L': '!',
    'g': '9',
    'G': '9',
    'b': '8',
    'B': '8',
  };

  static const Map<String, String> _leetSpeak = {
    'a': '4',
    'A': '4',
    'e': '3',
    'E': '3',
    'i': '!',
    'I': '!',
    'o': '0',
    'O': '0',
    's': '5',
    'S': '5',
    't': '7',
    'T': '7',
    'z': '2',
    'Z': '2',
  };

  /// Алфавит для «солевых» символов
  static const String _saltAlphabet = 'A-Za-z0-9!@#\$%';

  // ==================== ПРАВИЛА ====================

  /// Сдвигает каждый символ на фиксированное число позиций.
  /// offset выводится детерминированно из длины входа.
  static String applyShift(String input) {
    if (input.isEmpty) return input;
    final offset = max(1, input.length % 5);
    final buffer = StringBuffer();
    for (final char in input.runes) {
      buffer.writeCharCode(char + offset);
    }
    return buffer.toString();
  }

  /// Заменяет символы на визуально схожие по фиксированной таблице.
  static String applyVisualSubstitution(String input) {
    return input.split('').map((c) => _visualSubstitutions[c] ?? c).join();
  }

  /// Добавляет «специи» — детерминированные символы, выведенные из SHA-256(input).
  static String applyDerivedSalt(String input, {int saltLength = 4}) {
    if (input.isEmpty || saltLength <= 0) return input;
    final hash = sha256.convert(utf8.encode(input)).bytes;
    final saltChars = <String>[];
    for (var i = 0; i < saltLength; i++) {
      final byte = hash[i % hash.length];
      final idx = byte % _saltAlphabet.length;
      saltChars.add(_saltAlphabet[idx]);
    }
    // Вставляем в начало и конец
    final salt = saltChars.join();
    final half = saltLength ~/ 2;
    return salt.substring(0, half) + input + salt.substring(half);
  }

  /// Инвертирует регистр символов на чётных позициях.
  static String invertCase(String input) {
    return input.split('').asMap().entries.map((e) {
      final i = e.key;
      final c = e.value;
      if (i % 2 == 0) {
        return c == c.toUpperCase() ? c.toLowerCase() : c.toUpperCase();
      }
      return c;
    }).join();
  }

  /// Применяет базовый leet-спик по фиксированной таблице.
  static String applyLeetSpeak(String input) {
    return input.split('').map((c) => _leetSpeak[c] ?? c).join();
  }
}
