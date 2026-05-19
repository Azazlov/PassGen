import 'package:flutter/cupertino.dart';

void showDialogWindow1(String label, String text, BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(label),
      content: Text(text),
      actions: [
        CupertinoDialogAction(
          child: const Text('Ок'),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}

void showDialogWindow2(
  String label,
  String text,
  BuildContext context,
  String text1,
  VoidCallback function1,
  String text2,
  VoidCallback function2,
) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(label),
      content: Text(text),
      actions: [
        CupertinoDialogAction(
          child: Text(text1),
          onPressed: () {
            Navigator.of(ctx).pop();
            function1();
          },
        ),
        CupertinoDialogAction(
          child: Text(text2),
          onPressed: () {
            Navigator.of(ctx).pop();
            function2();
          },
        ),
      ],
    ),
  );
}

void pass() {}
