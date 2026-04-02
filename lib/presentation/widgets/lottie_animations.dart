import 'package:flutter/material.dart';

/// Виджет анимации успешного копирования
class LottieCopySuccess extends StatelessWidget {
  const LottieCopySuccess({super.key, this.size = 48, this.autoplay = true});
  final double size;
  final bool autoplay;

  @override
  Widget build(BuildContext context) {
    // Временная замена: иконка вместо отсутствующей Lottie анимации
    return Icon(
      Icons.check_circle,
      size: size,
      color: Colors.green,
    );
  }
}

/// Виджет анимации ошибки PIN
class LottiePinError extends StatelessWidget {
  const LottiePinError({super.key, this.size = 64, this.autoplay = true});
  final double size;
  final bool autoplay;

  @override
  Widget build(BuildContext context) {
    // Временная замена: иконка вместо отсутствующей Lottie анимации
    return Icon(
      Icons.error,
      size: size,
      color: Colors.red,
    );
  }
}

/// Виджет анимации индикатора стойкости пароля
class LottieStrengthPulse extends StatelessWidget {
  // 0.0 - 1.0

  const LottieStrengthPulse({
    super.key,
    this.size = 32,
    this.autoplay = true,
    this.strength = 0.5,
  });
  final double size;
  final bool autoplay;
  final double strength;

  @override
  Widget build(BuildContext context) {
    // Временная замена: круговой индикатор вместо отсутствующей Lottie анимации
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: strength,
        strokeWidth: 3,
        backgroundColor: Colors.grey.withValues(alpha: 0.3),
        valueColor: AlwaysStoppedAnimation<Color>(
          _getColorForStrength(strength),
        ),
      ),
    );
  }

  Color _getColorForStrength(double strength) {
    if (strength < 0.25) return Colors.red;
    if (strength < 0.5) return Colors.orange;
    if (strength < 0.75) return Colors.yellow[700]!;
    if (strength < 0.9) return Colors.green;
    return Colors.blue;
  }
}
