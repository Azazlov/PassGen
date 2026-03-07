import 'package:flutter/material.dart';

/// Диалог с одной кнопкой
void showAppDialog({
  required BuildContext context,
  required String title,
  required String content,
  String actionLabel = 'ОК',
  VoidCallback? onAction,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text(actionLabel),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            onAction?.call();
          },
        ),
      ],
    ),
  );
}

/// Диалог с двумя кнопками
void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmLabel,
  required VoidCallback onConfirm,
  required String cancelLabel,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text(cancelLabel),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            onCancel?.call();
          },
        ),
        TextButton(
          child: Text(
            confirmLabel,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            onConfirm();
          },
        ),
      ],
    ),
  );
}

/// Диалог с тремя кнопками
void showTripleOptionDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String option1Label,
  required VoidCallback onOption1,
  required String option2Label,
  required VoidCallback onOption2,
  String cancelLabel = 'Отмена',
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text(option1Label),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            onOption1();
          },
        ),
        TextButton(
          child: Text(option2Label),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            onOption2();
          },
        ),
        TextButton(
          child: Text(cancelLabel),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    ),
  );
}

/// Диалог подтверждения сохранения пароля
void showSavePasswordConfirmationDialog({
  required BuildContext context,
  required String service,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Сохранить пароль?'),
      content: Text('Сохранить пароль для сервиса "$service" в хранилище?'),
      actions: [
        TextButton(
          child: const Text('Отмена'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            onCancel?.call();
          },
        ),
        TextButton(
          child: Text(
            'Сохранить',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            onConfirm();
          },
        ),
      ],
    ),
  );
}
