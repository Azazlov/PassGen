import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Виджет анимации успешного копирования
class LottieCopySuccess extends StatelessWidget {
  final double size;
  final bool autoplay;

  const LottieCopySuccess({
    super.key,
    this.size = 48,
    this.autoplay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'project_context/design/animations/copy_success.json',
      width: size,
      height: size,
      animate: autoplay,
      fit: BoxFit.contain,
    );
  }
}

/// Виджет анимации ошибки PIN
class LottiePinError extends StatelessWidget {
  final double size;
  final bool autoplay;

  const LottiePinError({
    super.key,
    this.size = 64,
    this.autoplay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'project_context/design/animations/pin_error.json',
      width: size,
      height: size,
      animate: autoplay,
      fit: BoxFit.contain,
    );
  }
}

/// Виджет анимации индикатора стойкости пароля
class LottieStrengthPulse extends StatelessWidget {
  final double size;
  final bool autoplay;
  final double strength; // 0.0 - 1.0

  const LottieStrengthPulse({
    super.key,
    this.size = 32,
    this.autoplay = true,
    this.strength = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'project_context/design/animations/strength_pulse.json',
      width: size,
      height: size,
      animate: autoplay,
      fit: BoxFit.contain,
    );
  }
}
