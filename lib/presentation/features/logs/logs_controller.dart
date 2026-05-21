import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/security_log.dart';
import '../../../domain/usecases/log/get_logs_usecase.dart';

enum LogsFilter { all, login, changes, export }

/// Контроллер для просмотра логов
class LogsController extends ChangeNotifier {
  LogsController({required GetLogsUseCase getLogsUseCase})
    : _getLogsUseCase = getLogsUseCase;
  final GetLogsUseCase _getLogsUseCase;

  List<SecurityLog> _logs = [];
  LogsFilter _selectedFilter = LogsFilter.all;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;
  String? _error;

  List<SecurityLog> get logs => _logs;
  LogsFilter get selectedFilter => _selectedFilter;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  bool get hasDateFilter => _fromDate != null || _toDate != null;
  List<SecurityLog> get filteredLogs => _logs
      .where(_matchesSelectedFilter)
      .where(_matchesDateRange)
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => filteredLogs.isEmpty;

  void setFilter(LogsFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Устанавливает диапазон дат для фильтрации.
  /// Любой из параметров может быть `null` (граница диапазона снимается).
  void setDateRange({DateTime? from, DateTime? to}) {
    _fromDate = from == null ? null : DateTime(from.year, from.month, from.day);
    _toDate = to == null ? null : DateTime(to.year, to.month, to.day);
    notifyListeners();
  }

  void clearDateRange() {
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

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

    for (final log in filteredLogs) {
      final date = _formatDate(log.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(log);
    }

    return grouped;
  }

  bool _matchesDateRange(SecurityLog log) {
    if (_fromDate == null && _toDate == null) return true;
    final logDate = DateTime(
      log.timestamp.year,
      log.timestamp.month,
      log.timestamp.day,
    );
    if (_fromDate != null && logDate.isBefore(_fromDate!)) return false;
    if (_toDate != null && logDate.isAfter(_toDate!)) return false;
    return true;
  }

  bool _matchesSelectedFilter(SecurityLog log) {
    switch (_selectedFilter) {
      case LogsFilter.all:
        return true;
      case LogsFilter.login:
        return log.actionType.startsWith('AUTH_') ||
            log.actionType.startsWith('PIN_') ||
            log.actionType.startsWith('SESSION_');
      case LogsFilter.changes:
        return log.actionType.contains('PWD_') ||
            log.actionType == 'SETTINGS_CHG';
      case LogsFilter.export:
        return log.actionType.contains('EXPORT') ||
            log.actionType.contains('IMPORT');
    }
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

  /// Форматирует дату-время для CSV
  String _formatCsvDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  /// Экранирует строковое значение для CSV
  String _csvEscape(String value) {
    if (value.contains('"') || value.contains(';') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Экспорт журнала безопасности в CSV-файл и открытие системного Share-листа.
  Future<void> exportToCsv() async {
    try {
      final logs = filteredLogs;
      final buffer = StringBuffer();

      // BOM для корректного отображения кириллицы в Excel
      buffer.write('\uFEFF');

      // Заголовки
      buffer.writeln('ID;Profile ID;Action Type;Timestamp;Details');

      for (final log in logs) {
        buffer.writeln(
          '${log.id ?? ""};'
          '${log.profileId ?? ""};'
          '${_csvEscape(log.actionType)};'
          '${_formatCsvDateTime(log.timestamp)};'
          '${_csvEscape(log.details ?? "")}',
        );
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/passgen_logs_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(buffer.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'PassGen — журнал событий',
        ),
      );
    } catch (e) {
      _error = 'Ошибка экспорта: $e';
      notifyListeners();
    }
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
