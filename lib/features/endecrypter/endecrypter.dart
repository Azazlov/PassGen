import 'package:flutter/cupertino.dart';
import 'package:secure_pass/features/passwordGenerator/psswd_gen_interface.dart';
import 'package:flutter/services.dart';
import 'package:secure_pass/features/storage/storage_service.dart';
import 'package:secure_pass/shared/interface.dart';
import 'package:secure_pass/shared/dialog.dart';

class EndecrypterScreen extends StatefulWidget {
  const EndecrypterScreen({super.key});

  @override
  State<EndecrypterScreen> createState() => _EndecrypterScreen();
}

class _EndecrypterScreen extends State<EndecrypterScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController masterKeyController = TextEditingController();

  late PasswordGenerationInterface generator;

  String mssg = '';

  @override 
  void initState(){
    super.initState();
    generator = PasswordGenerationInterface();
    setupConfigs();
  }

  Future<void> setupConfigs() async{
    dynamic configs = await getConfigs('endecrypter');
    keyController.text = configs[0];
    masterKeyController.text = configs[1];
  }

  Future<void> deEncrypt() async {
    setState(() {
      mssg = 'Перевод...';
    });

    if (textController.text == ''){
      mssg = 'Сообщение или код не должно быть пустым';
      return;
    }

    dynamic result = 'Неизвестная ошибка';

    try{
      result = await generator.generateMssg(
        secret: textController.text, 
        key: keyController.text, 
      );
    }
    on Exception{
      result = await generator.generateSecret(
        mssg: textController.text, 
        key: keyController.text, 
      );
    }
      
    await saveConfig(
      'endecrypter', 
      [
        keyController.text, 
        masterKeyController.text
      ]
    );

    setState(() {
      mssg = result;
    });
  }

  void copySecret(){
    showDialogWindow1('Скопировано', 'Сообщение/шифр скопирован в буфер обмена', context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(

      navigationBar: const CupertinoNavigationBar(
        middle: Text('Шифратор/Дешифратор'),
      ),

      child: Center(
        child: ListView(
          padding: setPadding(),
          children: [
            buildInput('Сообщение/код', 'Текст/шифр', textController, false, TextInputType.text, context),
            buildInput('Ключ шифрования', 'mum{gse24}', keyController, true, TextInputType.text, context),
            // buildInput('Мастер-ключ шифрования', 'jasdkb{bc[]}', masterKeyController, true, TextInputType.text, context),
            
            const SizedBox(height: 40),
            buildButton('(Де)шифрование', deEncrypt),
            buildCopyOnTap('Сообщение/шифр', mssg, copySecret),
          ],
        ),
      )
    );
  }
}