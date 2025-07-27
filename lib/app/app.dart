import 'package:flutter/cupertino.dart';
import 'routes.dart';

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'PSW',
      home: TabScaffold(), // <-- заменили
    );
  }
}