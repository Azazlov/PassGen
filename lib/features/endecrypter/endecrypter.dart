import 'package:flutter/cupertino.dart';
import 'package:secure_pass/features/passwordGenerator/domain/psswdGenInterface.dart';
import 'package:flutter/services.dart';
import 'package:secure_pass/features/storage/storageService.dart';

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
    dynamic configs = await getConfig('endecrypter');
    // print(configs);
    keyController.text = configs[0];
    masterKeyController.text = configs[1];
  }

  Future<void> generatePassword() async {
    setState(() {
      mssg = 'Перевод...';
    });

    dynamic result = 'Неизвестная ошибка';

    try{
      result = await generator.generateMssg(secret: textController.text, key: keyController.text, masterKey: masterKeyController.text);
    }
    on FormatException{
      result = await generator.generateSecret(mssg: textController.text, key: keyController.text, masterKey: masterKeyController.text);
    }
      
    await saveConfig('endecrypter', [keyController.text, masterKeyController.text]);

    setState(() {
      mssg = result;
    });
  }

  Widget buildInput(String label, String placeholder, controller, hidden, symbols){
    return 
    ListBody(
      children: [
      const SizedBox(height: 18,),
      Text(label),
      CupertinoTextField(
        padding: const EdgeInsets.all(12.0),
        controller: controller,
        placeholder: placeholder,
        obscureText: hidden,
        keyboardType: symbols,
        onSubmitted: (_) => generatePassword()
      )
      ],
    );
  }

  Widget buildCopy(String label, String data, bool isCopied){
    return ListBody(
      children: [
        const SizedBox(height: 48),
        Text(label, style: const TextStyle(fontSize: 20),),
        GestureDetector(
          onTap: () {
            if (isCopied){
              Clipboard.setData(ClipboardData(text: data));
              showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: const Text('Скопировано'),
                  content: Text('$label скопирован в буфер обмена.'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    )
                  ],
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 214, 214, 214),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(255, 90, 90, 90)),
            ),
            child: Center(
              child: Text(
                data,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontFamily: 'segoe UI', color: Color.fromARGB(255, 21, 21, 21)),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(

      navigationBar: const CupertinoNavigationBar(
        middle: Text('Шифратор/Дешифратор'),
      ),
      child: Center(
        // child: ConstrainedBox(
        //   constraints: const BoxConstraints(
        //     minWidth: 400,
        //     maxWidth: 600,
        //     minHeight: 600,
        //   ),
        child: ListView(
          padding: const EdgeInsets.only(top: 100.0, right: 20, left: 20, bottom: 20),
          children: [
            ConstrainedBox(constraints: const BoxConstraints(
              maxWidth: 400
            )),
            buildInput('Сообщение/код', 'Текст/шифр', textController, false, TextInputType.text),
            buildInput('Ключ шифрования', 'mum{gse24}', keyController, true, TextInputType.text),
            buildInput('Мастер-ключ шифрования', 'jasdkb{bc[]}', masterKeyController, true, TextInputType.text),
            
            const SizedBox(height: 24),
            CupertinoButton.filled(
              padding: const EdgeInsets.all(16.0),
              onPressed: generatePassword,
              child: const Text('Сгенерировать'),
            ),
            buildCopy('Сообщение/шифр', mssg, true),

            const SizedBox(height: 48),
          ],
        ),
      
    ));
  }
}