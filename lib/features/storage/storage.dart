import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:secure_pass/features/storage/storageService.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  void initState(){
    
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Скоро будет...'),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Эта часть приложения еще в разработке',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
