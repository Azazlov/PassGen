import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал событий'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => controller.loadLogs(limit: 100),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.isEmpty
          ? _buildEmptyState(theme)
          : _buildLogsList(controller, theme),
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
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
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
}
