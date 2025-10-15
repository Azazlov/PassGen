import 'package:flutter/material.dart';

// Диалог с одной кнопкой
void showDialogWindow1(
  String titleTxt, 
  String contentTxt, 
  BuildContext context,
  {String btnTxt = 'Ок'}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titleTxt),
      content: Text(contentTxt),
      actions: [
        TextButton(
          child: Text(btnTxt),
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
    String titleTxt,
    String contentTxt,
    BuildContext context,
    String childTxt1,
    Function childFnc1,
    String childTxt2,
    Function childFnc2,
    {btnTxt = 'Отмена'}) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titleTxt),
      content: Text(contentTxt),
      actions: [
        TextButton(
          child: Text(childTxt1),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            childFnc1();
          },
        ),
        TextButton(
          child: Text(childTxt2),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            childFnc2();
          },
        ),
        TextButton(
          child: Text(btnTxt),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    ),
  );
}

// Диалог с 3 кнопками
void showDialogWindow3(
    String titleTxt,
    String contentTxt,
    BuildContext context,
    String childTxt1,
    Function childFnc1,
    String childTxt2,
    Function childFnc2,
    String childTxt3,
    Function childFnc3,) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titleTxt),
      content: Text(contentTxt),
      actions: [
        TextButton(
          child: Text(childTxt1),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            childFnc1();
          },
        ),
        TextButton(
          child: Text(childTxt2),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            childFnc2();
          },
        ),
      ],
    ),
  );
}

// Пустая функция осталась без изменений
void pass() {}
