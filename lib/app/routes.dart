import 'package:flutter/cupertino.dart';
import 'package:secure_pass/features/about/about.dart';
import 'package:secure_pass/features/storage/storage.dart';
import 'package:secure_pass/features/endecrypter/endecrypter.dart';
import 'package:secure_pass/features/passwordGenerator/password_generator.dart';

class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pencil_ellipsis_rectangle),
            label: 'Генератор',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.lock),
            label: 'Шифратор',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.archivebox),
            label: 'Хранилище',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.info),
            label: 'О программе',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {  
              case 0:
                return const PasswordGeneratorScreen();    
              case 1:
                return const EndecrypterScreen();
              case 2:
                return const StorageScreen();
              case 3:
                return const AboutScreen();
              default:
                return const PasswordGeneratorScreen();
            }
          },
        );
      },
    );
  }
}