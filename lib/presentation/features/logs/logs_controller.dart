import 'package:flutter/material.dart';

import '../../../domain/entities/security_log.dart';
import '../../../domain/usecases/log/get_logs_usecase.dart';

/// Контроллер для просмотра логов
class LogsController extends ChangeNotifier {
  LogsController({required GetLogsUseCase getLogsUseCase})
    : _getLogsUseCase = getLogsUseCase;
  final GetLogsUseCase _getLogsUseCase;

  List<SecurityLog> _logs = [];
  bool _isLoading = false;
  String? _error;

  List<SecurityLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _logs.isEmpty;

  /// Загрузка логов
  Future<void> loadLogs({int limit = 100}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _logs = await _getLogsUseCase.execute(limit: limit);
    } catch (e) {
      _error = 'Ошибка загрузки логов: $e';
      _logs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Группировка логов по дате
  Map<String, List<SecurityLog>> getLogsByDate() {
    final Map<String, List<SecurityLog>> grouped = {};

    for (final log in _logs) {
      final date = _formatDate(log.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(log);
    }

    return grouped;
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (logDate == today) {
      return 'Сегодня';
    } else if (logDate == yesterday) {
      return 'Вчера';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  /// Получение иконки для типа события
  IconData getEventIcon(String actionType) {
    switch (actionType) {
      case 'AUTH_SUCCESS':
        return Icons.login;
      case 'AUTH_FAILURE':
        return Icons.lock_outline;
      case 'AUTH_LOCKOUT':
        return Icons.lock_reset;
      case 'PIN_SETUP':
        return Icons.pin;
      case 'PIN_CHANGED':
        return Icons.edit;
      case 'PIN_REMOVED':
        return Icons.remove_circle_outline;
      case 'PWD_CREATED':
        return Icons.password;
      case 'PWD_ACCESSED':
        return Icons.visibility;
      case 'PWD_DELETED':
        return Icons.delete;
      case 'DATA_EXPORT':
        return Icons.file_download;
      case 'DATA_IMPORT':
        return Icons.file_upload;
      case 'SETTINGS_CHG':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  /// Получение цвета для типа события
  Color getEventColor(String actionType, ThemeData theme) {
    if (actionType.contains('FAILURE') ||
        actionType.contains('LOCKOUT') ||
        actionType.contains('DELETED')) {
      return Colors.red;
    } else if (actionType.contains('SUCCESS') ||
        actionType.contains('CREATED')) {
      return Colors.green;
    } else if (actionType.contains('EXPORT') || actionType.contains('IMPORT')) {
      return Colors.blue;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  /// Форматирование времени
  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _logs.clear();
    super.dispose();
  }
}
