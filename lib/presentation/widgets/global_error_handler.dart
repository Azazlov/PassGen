import 'package:flutter/material.dart';

/// Глобальный обработчик ошибок
class GlobalErrorHandler extends ChangeNotifier {
  String? _error;
  bool _isVisible = false;

  String? get error => _error;
  bool get isVisible => _isVisible;

  /// Показывает ошибку
  void showError(String error) {
    _error = error;
    _isVisible = true;
    notifyListeners();
  }

  /// Скрывает ошибку
  void dismiss() {
    _error = null;
    _isVisible = false;
    notifyListeners();
  }

  /// Очищает ошибку
  void clear() {
    _error = null;
    _isVisible = false;
  }
}
