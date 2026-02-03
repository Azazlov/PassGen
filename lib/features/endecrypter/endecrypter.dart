import 'package:flutter/material.dart';
import 'package:pass_gen/features/storage/storage_service.dart';
import 'package:pass_gen/shared/interface.dart';
import 'package:pass_gen/shared/dialogs.dart';
import 'package:pass_gen/features/endecrypter/endecrypter_interface.dart';

class EndecrypterScreen extends StatefulWidget {
  const EndecrypterScreen({super.key});

  @override
  State<EndecrypterScreen> createState() => _EndecrypterScreen();
}

class _EndecrypterScreen extends State<EndecrypterScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController masterKeyController = TextEditingController();

  late EndecrypterInterface generator;

  String mssg = '';
  String mssgCode = '';

  @override 
  void initState(){
    super.initState();
    generator = EndecrypterInterface();
    setupConfigs();
  }

  Future<void> setupConfigs() async{
    try{
      dynamic configs = await getConfigs('endecrypter');
      keyController.text = configs[0];
      masterKeyController.text = configs[1];
    }
    catch (e){e;}
  }

  Future<void> encrypt() async {
    setState(() {
      // mssg = 'Перевод...';
    });

    if (textController.text.trim() == ''){
      mssg = 'Сообщение или код не должно быть пустым';
      return;
    }

    dynamic result;

    result = await generator.encryptMessage(
      message: textController.text, 
      password: keyController.text
    );
      
    await saveConfig(
      'endecrypter', 
      [
        keyController.text, 
        masterKeyController.text
      ]
    );

    setState(() {
      mssgCode = 'Скопировать шифр';
      mssg = result;
    });
  }

  Future<void> decrypt() async {
    setState(() {
      // mssg = 'Перевод...';
    });

    if (textController.text.trim() == ''){
      mssg = 'Сообщение или код не должно быть пустым';
      return;
    }

    dynamic result;

    try{
      result = await generator.decryptMessage(
        encrJSON: textController.text, 
        key: keyController.text
      );
    }
    catch (e){
      setState(() {
        mssg = 'Ошибка дешифрования. Проверьте правильность введенных данных.';
      });
      return;
    }
      
    await saveConfig(
      'endecrypter', 
      [
        keyController.text, 
        masterKeyController.text
      ]
    );

    setState(() {
      mssgCode = 'Скопировать сообщение';
      mssg = result;
    });
  }

  void copySecret(){
    showDialogWindow1('Скопировано', 'Сообщение/шифр скопирован в буфер обмена', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // appBar: const NavigationBarTheme(
      //   child: Text('Шифратор/Дешифратор'),
      // ),

      body: Center(
        child: ListView(
          padding: setPadding(),
          children: [
            // buildInput('Сообщение/код', 'Текст/шифр', textController, false, TextInputType.text, pass),
            // buildInput('Ключ шифрования', 'Любой надежный ключ', keyController, true, TextInputType.text, pass),
            // buildInput('Мастер-ключ шифрования', 'jasdkb{bc[]}', masterKeyController, true, TextInputType.text, context),
            
            const SizedBox(height: 40),
            // buildButton('Шифрование', encrypt),
            // buildButton('Дешифрование', decrypt),
            // buildCopyOnTap(mssgCode, mssg, copySecret),
          ],
        ),
      )
    );
  }
}