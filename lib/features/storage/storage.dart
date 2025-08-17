import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:secure_pass/features/storage/storageService.dart';
import 'package:secure_pass/features/passwordGenerator/domain/psswdGenInterface.dart';
import 'package:secure_pass/features/storage/storageInterface.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>{

  String encryptedConfig = 'Ничего не выбрано';
  String service = 'Нет названия сервиса';
  String keyConfig = 'encryptedConfigs';
  String thisConfig = '';

  int id = 0;
  late PasswordGenerationInterface generator;
  
  @override
  void initState(){
    super.initState();
    psswdConfigs(0);
  }

  Future<int> psswdConfigs(int i) async{
    // print('i: $i');
    if (i<0){
      return 0;
    }
    try{
      final a = await getConfigs(keyConfig);

      if (a.length == 0){
        setState(() {
          encryptedConfig = 'Нет Конфигов';
          service = 'Нет названия сервиса';
        });
        return 0;
      }
      
      if (i==a.length){
        if (i != 1){
          return 0;
        }
      }
      setState(() {
        thisConfig = a[i];
        final servicename = thisConfig.split('.')[0];
        final shortname = thisConfig.substring(servicename.length+1, 25);
        encryptedConfig = '$shortname...';
        service = servicename==''?'Нет названия сервиса':servicename;
        id = i;
      });
      return 1;
    }
    catch (exception){
      return 0;
    }


  }

  void nextConfig() async{
    trueConfig();
    await psswdConfigs(id+1);
  }
  void prevConfig() async{
    trueConfig();
    await psswdConfigs(id-1);
  }
  void trueConfig() async{
    await psswdConfigs(id);
  }

  Future<void> deleteConfig() async{
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Удалить'),
        content: Text('Вы точно хотите удалить выбранный конфиг?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Да'),
            onPressed: () async{
              Navigator.of(context, rootNavigator: true).pop();
              await removeConfig(keyConfig, id);

              await psswdConfigs(id+1);
              await psswdConfigs(id-1);
              await psswdConfigs(id+1);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Нет'),
            onPressed: () async{
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold (
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Хранилище ваших паролей'),
      ),
      child: Center(
        child: ListView(
          padding: const EdgeInsets.only(top: 100.0, right: 20, left: 20, bottom: 20),
          children: [
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () async {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Скопировать'),
                    content: Text('Вы хотите скопировать шифр или пароль?'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('Пароль'),
                        onPressed: () async{
                          final psswd = await getPsswd(id);
                          // print(psswd);
                          // ignore: use_build_context_synchronously
                          Navigator.of(context, rootNavigator: true).pop();
                          if (psswd == 'Error'){
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: const Text('Ошибка!'),
                                content: Text('Неверный пароль или же конфиг. Попробуйте поменять ключ на странице "Генератор"'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed: () async{
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  )
                                ],
                              ),
                            );
                          }
                          else{
                          Clipboard.setData(ClipboardData(text:
                           '${await getPsswd(id)}'
                           ));
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text('Скопировано'),
                              content: Text('Пароль скопирован в буфер обмена.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () async{
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                )
                              ],
                            ),
                            );
                          }
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Шифр'),
                        onPressed: () async{
                          Navigator.of(context, rootNavigator: true).pop();
                          Clipboard.setData(ClipboardData(text:
                           thisConfig
                           ));
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text('Скопировано'),
                              content: Text('Шифр скопирован в буфер обмена.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () async{
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
                },

                  child: Center(
                    child: Text(encryptedConfig),
                  ),
                ),
const SizedBox(height: 48),

                Center(
                  child: CupertinoButton.filled(
                  padding: const EdgeInsets.all(16.0),
                  onPressed: prevConfig,
                  child: const Text('<'),
                    )),

                const SizedBox(height: 48),
            Center(
              child: Text('$service (${id+1})'),
            ),

            const SizedBox(height: 48),
            Center(
              child: CupertinoButton.filled(
              padding: const EdgeInsets.all(16.0),
              onPressed: nextConfig,
              child: const Text('>'),
            )),

            const SizedBox(height: 48),
            Center(
              child: CupertinoButton.filled(
              padding: const EdgeInsets.all(16.0),
              onPressed: deleteConfig ,
              child: const Text('Удалить')
              ),
            ),
            const SizedBox(height: 48),
          ]
        ),
      ),
    );
  }

}


