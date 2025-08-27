import 'package:flutter/material.dart';

// Диалог с одной кнопкой
void showDialogWindow1(String label, String text, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(label),
      content: Text(text),
      actions: [
        TextButton(
          child: const Text('Ок'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    ),
  );
}

// Диалог с двумя кнопками
void showDialogWindow2(
    String label,
    String text,
    BuildContext context,
    String text1,
    Function function1,
    String text2,
    Function function2) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(label),
      content: Text(text),
      actions: [
        TextButton(
          child: Text(text1),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            function1();
          },
        ),
        TextButton(
          child: Text(text2),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            function2();
          },
        ),
      ],
    ),
  );
}

// Пустая функция осталась без изменений
void pass() {}
