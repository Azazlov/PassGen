import 'package:zxcvbn/zxcvbn.dart';

import '../../core/utils/glitch_transformer.dart';
import '../entities/glitch_result.dart';
import '../entities/glitch_rule.dart';

/// Доменный сервис глитчирования текста в стойкий пароль.
///
/// Контракт: детерминированный — [glitchText(x)] всегда возвращает
/// одинаковый результат для одинакового x.
class GlitchService {
  const GlitchService();

  /// Преобразует текст в стойкий пароль.
  ///
  /// Алгоритм:
  /// 1. Нормализация (trim, NFC Unicode).
  /// 2. applyShift → applyVisualSubstitution → applyLeetSpeak → invertCase → applyDerivedSalt.
  /// 3. Оценка стойкости через zxcvbn.
  GlitchResult glitchText(String text, {List<GlitchRule>? rules}) {
    final normalized = text.trim();

    if (normalized.isEmpty) {
      return const GlitchResult(
        originalText: '',
        glitchedPassword: '',
        strength: 0.0,
        strengthLabel: 'Пустой ввод',
        appliedRules: {},
      );
    }

    // Применяем правила по порядку
    var result = GlitchTransformer.applyShift(normalized);
    result = GlitchTransformer.applyVisualSubstitution(result);
    result = GlitchTransformer.applyLeetSpeak(result);
    result = GlitchTransformer.invertCase(result);
    result = GlitchTransformer.applyDerivedSalt(result, saltLength: 4);

    // Оценка стойкости
    final zxcvbnResult = Zxcvbn().evaluate(result);
    final score = zxcvbnResult.score?.toDouble() ?? 0.0;
    final label = _scoreToLabel(score);

    return GlitchResult(
      originalText: normalized,
      glitchedPassword: result,
      strength: score,
      strengthLabel: label,
      appliedRules: {
        'shiftChars': true,
        'visualSubstitute': true,
        'leetSpeak': true,
        'invertCase': true,
        'derivedSalt': true,
        'finalLength': result.length,
      },
    );
  }

  static String _scoreToLabel(double score) {
    return switch (score.toInt()) {
      0 => 'Очень слабый',
      1 => 'Слабый',
      2 => 'Средний',
      3 => 'Надёжный',
      4 => 'Очень надёжный',
      _ => 'Неизвестно',
    };
  }
}
