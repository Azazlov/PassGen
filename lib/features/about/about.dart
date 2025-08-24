import 'package:flutter/cupertino.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('О программе'),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Secure Pass\n\nПростой и безопасный генератор паролей.\n\nСоздан во Flutter с использованием темы Cupertino.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
