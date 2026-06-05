import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../domain/entities/security_log.dart';
import '../../../domain/usecases/log/get_logs_usecase.dart';
import 'logs_controller.dart';

/// Экран просмотра логов безопасности
class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          LogsController(getLogsUseCase: context.read<GetLogsUseCase>())
            ..loadLogs(limit: 100),
      child: const _LogsScreenContent(),
    );
  }
}

class _LogsScreenContent extends StatefulWidget {
  const _LogsScreenContent();

  @override
  State<_LogsScreenContent> createState() => _LogsScreenContentState();
}

class _LogsScreenContentState extends State<_LogsScreenContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<LogsController>();
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tabletMin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал событий'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Экспорт CSV',
            onPressed: () => controller.exportToCsv(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => controller.loadLogs(limit: 100),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : isMobile
              ? _buildMobileContent(context, theme, controller)
              : _buildDesktopContent(context, theme, controller),
    );
  }

  Widget _buildMobileContent(
    BuildContext context,
    ThemeData theme,
    LogsController controller,
  ) {
    return Column(
      children: [
        _buildFilterChips(controller),
        _buildDateFilterRow(context, controller, theme),
        Expanded(
          child: controller.isEmpty
              ? _buildEmptyState(theme)
              : _buildLogsList(controller, theme),
        ),
      ],
    );
  }

  Widget _buildDesktopContent(
    BuildContext context,
    ThemeData theme,
    LogsController controller,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Фильтры', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildFilterChip(controller, LogsFilter.all, 'Все'),
                const SizedBox(height: 4),
                _buildFilterChip(controller, LogsFilter.login, 'Вход'),
                const SizedBox(height: 4),
                _buildFilterChip(controller, LogsFilter.changes, 'Изменения'),
                const SizedBox(height: 4),
                _buildFilterChip(controller, LogsFilter.export, 'Экспорт'),
                const SizedBox(height: 24),
                Text('Дата', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildDateFilterRow(context, controller, theme),
              ],
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: controller.isEmpty
              ? _buildEmptyState(theme)
              : _buildLogsList(controller, theme),
        ),
      ],
    );
  }

  Widget _buildFilterChips(LogsController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _buildFilterChip(controller, LogsFilter.all, 'Все'),
          const SizedBox(width: 8),
          _buildFilterChip(controller, LogsFilter.login, 'Вход'),
          const SizedBox(width: 8),
          _buildFilterChip(controller, LogsFilter.changes, 'Изменения'),
          const SizedBox(width: 8),
          _buildFilterChip(controller, LogsFilter.export, 'Экспорт'),
        ],
      ),
    );
  }

  Widget _buildDateFilterRow(
    BuildContext context,
    LogsController controller,
    ThemeData theme,
  ) {
    String label;
    if (!controller.hasDateFilter) {
      label = 'Любая дата';
    } else if (controller.fromDate != null && controller.toDate != null) {
      label =
          '${_formatRangeDate(controller.fromDate!)} – ${_formatRangeDate(controller.toDate!)}';
    } else if (controller.fromDate != null) {
      label = 'с ${_formatRangeDate(controller.fromDate!)}';
    } else {
      label = 'по ${_formatRangeDate(controller.toDate!)}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(label, overflow: TextOverflow.ellipsis),
              onPressed: () => _pickDateRange(context, controller),
            ),
          ),
          if (controller.hasDateFilter) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Сбросить диапазон',
              icon: const Icon(Icons.clear),
              onPressed: controller.clearDateRange,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    LogsController controller,
  ) async {
    final now = DateTime.now();
    final initial = (controller.fromDate != null && controller.toDate != null)
        ? DateTimeRange(start: controller.fromDate!, end: controller.toDate!)
        : null;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
      helpText: 'Выберите диапазон дат',
      cancelText: 'Отмена',
      confirmText: 'Применить',
      saveText: 'Применить',
    );
    if (picked != null) {
      controller.setDateRange(from: picked.start, to: picked.end);
    }
  }

  String _formatRangeDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Widget _buildFilterChip(
    LogsController controller,
    LogsFilter filter,
    String label,
  ) {
    return FilterChip(
      label: Text(label),
      selected: controller.selectedFilter == filter,
      onSelected: (_) => controller.setFilter(filter),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Нет логов',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Журнал событий пуст',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(LogsController controller, ThemeData theme) {
    final groupedLogs = controller.getLogsByDate();

    return ListView.builder(
      key: const PageStorageKey('logs_list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: groupedLogs.length,
      itemBuilder: (context, index) {
        final entry = groupedLogs.entries.elementAt(index);
        return _buildDateSection(entry.key, entry.value, controller, theme);
      },
    );
  }

  Widget _buildDateSection(
    String date,
    List<SecurityLog> logs,
    LogsController controller,
    ThemeData theme,
  ) {
    return Column(
      key: ValueKey('date_$date'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            date,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...logs.map((log) => _buildLogTile(log, controller, theme)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLogTile(
    SecurityLog log,
    LogsController controller,
    ThemeData theme,
  ) {
    final icon = controller.getEventIcon(log.actionType);
    final color = controller.getEventColor(log.actionType, theme);
    final time = controller.formatTime(log.timestamp);

    return Card(
      key: ValueKey('log_${log.id}_${log.timestamp.millisecondsSinceEpoch}'),
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: () => _showLogDetails(context, log, controller, theme),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          _formatActionType(log.actionType),
          style: TextStyle(color: color),
        ),
        subtitle: log.details != null
            ? Text(
                _formatDetails(log.details!),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }

  void _showLogDetails(
    BuildContext context,
    SecurityLog log,
    LogsController controller,
    ThemeData theme,
  ) {
    final icon = controller.getEventIcon(log.actionType);
    final color = controller.getEventColor(log.actionType, theme);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_formatActionType(log.actionType))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Время', _formatTimestamp(log.timestamp)),
            if (log.profileId != null)
              _buildDetailRow('Профиль', log.profileId.toString()),
            _buildDetailRow('Тип', log.actionType),
            _buildDetailRow(
              'Детали',
              log.details == null || log.details!.isEmpty
                  ? 'Нет данных'
                  : _formatDetails(log.details!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }

  String _formatActionType(String actionType) {
    return actionType
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0] + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _formatDetails(String details) {
    try {
      // Если details в формате JSON, можно отформатировать
      return details;
    } catch (_) {
      return details;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$day.$month.${dateTime.year} $hour:$minute:$second';
  }
}
