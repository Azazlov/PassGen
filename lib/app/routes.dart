import 'package:flutter/cupertino.dart';
import 'package:secure_pass/features/endecrypter/about.dart';
import 'package:secure_pass/features/passwordGenerator/presentation/passwordGenerator.dart';

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
            print('${index}'); 
            switch (index) {  
                           
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