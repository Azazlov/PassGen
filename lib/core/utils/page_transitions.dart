import 'package:flutter/material.dart';

/// Утилиты для анимации переходов между экранами
/// Согласно ТЗ (Раздел 10.1)
class PageTransitions {
  const PageTransitions._();

  /// Создаёт маршрут с анимацией затухания и сдвига
  /// Длительность: 300ms
  static PageRouteBuilder<T> createFadeSlideRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Создаёт маршрут с анимацией только затухания
  /// Длительность: 200ms
  static PageRouteBuilder<T> createFadeRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  /// Создаёт маршрут с анимацией масштабирования
  /// Длительность: 300ms
  static PageRouteBuilder<T> createScaleRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
