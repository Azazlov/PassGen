import 'package:flutter/material.dart';
import 'package:pass_gen/features/about/about.dart';
import 'package:pass_gen/features/storage/storage.dart';
import 'package:pass_gen/features/endecrypter/endecrypter.dart';
import 'package:pass_gen/features/passwordGenerator/password_generator.dart';

class TabScaffold extends StatefulWidget {
  const TabScaffold({super.key});

  @override
  State<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  int _currentIndex = 0;

  @override
 Widget build(BuildContext context) {
  final theme = Theme.of(context);  // Получаем текущую тему
  
  return Scaffold(
    body: IndexedStack(
      index: _currentIndex,
      children: <Widget>[
        PasswordGeneratorScreen(),
        EndecrypterScreen(),
        StorageScreen(),
        AboutScreen(),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
      // Настраиваем параметры для корректного отображения
      backgroundColor: theme.colorScheme.background,  // Цвет фона
      selectedItemColor: theme.colorScheme.primary,    // Цвет выбранной вкладки
      unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.6),  // Цвет неактивных вкладок
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.create),
          label: 'Генератор',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lock),
          label: 'Шифратор',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.archive),
          label: 'Хранилище',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'О программе',
        ),
      ],
    ),
  );
}

}
