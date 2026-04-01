import 'package:flutter/material.dart';
import '../../../domain/entities/notification.dart' as app_entities;

/// Виджет карточки уведомления
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onDismiss,
    this.onAction,
  });

  final app_entities.Notification notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getTypeColors(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors['backgroundColor'],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка типа уведомления
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors['iconBackgroundColor'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: colors['iconColor'],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Контент уведомления
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и время
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors['titleColor'],
                          ),
                        ),
                      ),
                      // Кнопка закрытия
                      if (onDismiss != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: onDismiss,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Сообщение
                  Text(
                    notification.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Кнопка действия (если есть)
                  if (onAction != null)
                    TextButton(
                      onPressed: onAction,
                      child: const Text('Перейти'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _getTypeColors(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (notification.type) {
      case app_entities.NotificationType.weakPassword:
        return {
          'backgroundColor': theme.colorScheme.errorContainer,
          'iconBackgroundColor': theme.colorScheme.error.withOpacity(0.1),
          'iconColor': theme.colorScheme.error,
          'titleColor': theme.colorScheme.onErrorContainer,
        };
      
      case app_entities.NotificationType.duplicatePassword:
        return {
          'backgroundColor': theme.colorScheme.warningContainer ?? 
                            theme.colorScheme.errorContainer,
          'iconBackgroundColor': theme.colorScheme.error.withOpacity(0.1),
          'iconColor': theme.colorScheme.error,
          'titleColor': theme.colorScheme.onErrorContainer,
        };
      
      case app_entities.NotificationType.oldPassword:
        return {
          'backgroundColor': theme.colorScheme.tertiaryContainer,
          'iconBackgroundColor': theme.colorScheme.tertiary.withOpacity(0.1),
          'iconColor': theme.colorScheme.tertiary,
          'titleColor': theme.colorScheme.onTertiaryContainer,
        };
      
      case app_entities.NotificationType.success:
        return {
          'backgroundColor': theme.colorScheme.primaryContainer,
          'iconBackgroundColor': theme.colorScheme.primary.withOpacity(0.1),
          'iconColor': theme.colorScheme.primary,
          'titleColor': theme.colorScheme.onPrimaryContainer,
        };
      
      case app_entities.NotificationType.error:
        return {
          'backgroundColor': theme.colorScheme.errorContainer,
          'iconBackgroundColor': theme.colorScheme.error.withOpacity(0.1),
          'iconColor': theme.colorScheme.error,
          'titleColor': theme.colorScheme.onErrorContainer,
        };
      
      case app_entities.NotificationType.securityWarning:
        return {
          'backgroundColor': theme.colorScheme.errorContainer,
          'iconBackgroundColor': theme.colorScheme.error.withOpacity(0.1),
          'iconColor': theme.colorScheme.error,
          'titleColor': theme.colorScheme.onErrorContainer,
        };
    }
  }

  IconData _getIconForType(app_entities.NotificationType type) {
    switch (type) {
      case app_entities.NotificationType.weakPassword:
        return Icons.warning;
      case app_entities.NotificationType.duplicatePassword:
        return Icons.content_copy;
      case app_entities.NotificationType.oldPassword:
        return Icons.schedule;
      case app_entities.NotificationType.success:
        return Icons.check_circle;
      case app_entities.NotificationType.error:
        return Icons.error;
      case app_entities.NotificationType.securityWarning:
        return Icons.security;
    }
  }
}

/// Расширение для warning container цвета
extension WarningContainerColor on ColorScheme {
  Color? get warningContainer => tertiaryContainer;
}
