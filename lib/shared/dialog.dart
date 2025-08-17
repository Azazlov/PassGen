import 'package:flutter/cupertino.dart';

void showDialogWindow1(String label, String text, dynamic context){
  showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(label),
      content: Text(text),
      actions: [
        CupertinoDialogAction(
          child: const Text('Ок'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    ),
  );
}

void showDialogWindow2(label, text, context, text1, function1, text2, function2) async{
  showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(label),
      content: Text(text),
      actions: [
        CupertinoDialogAction(
          child: Text(text1),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            function1();
          },
        ),
        CupertinoDialogAction(
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

void pass(){
  
}