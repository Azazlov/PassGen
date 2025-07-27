import 'package:flutter/cupertino.dart';
import 'package:secure_pass/features/passwordGenerator/domain/psswdGenInterface.dart';
import 'package:flutter/services.dart';


class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController masterController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController lengthController = TextEditingController(text: '16');
  late PasswordGenerationInterface generator;

  String generatedPassword = '';
  String secret = '';

  @override 
  void initState(){
    super.initState();
    generator = PasswordGenerationInterface();
  }

  Future<void> generatePassword() async {
    setState(() {
      generatedPassword = 'Генерация...';
      secret = 'Криптографический анализ...';
    });
    final success = await generator.generate(
      master: masterController.text, 
      key: keyController.text,
      service: serviceController.text, 
      length: lengthController.text, 
      useUpper: useUpper, 
      useLower: useLower, 
      useDigits: useDigits, 
      useSpec1: useSpec1, 
      useSpec2: useSpec2, 
      useSpec3: useSpec3
    );

    setState(() {
      
      generatedPassword = success[0];
      secret = success[1];
    });
  }

  bool useUpper = true;
  bool useLower = true;
  bool useDigits = true;
  bool useSpec1 = false;
  bool useSpec2 = false;
  bool useSpec3 = false; 

  Widget buildSwitch(String label, bool value, void Function(bool) onChanged) {
    return CupertinoFormRow(
      padding: EdgeInsets.all(10),
      prefix: Text(label),
      child: CupertinoSwitch(value: value, onChanged: onChanged),
    );
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
        middle: Text('Генератор паролей'),
      ),
      child: Center(
        // child: ConstrainedBox(
        //   constraints: const BoxConstraints(
        //     minWidth: 400,
        //     maxWidth: 600,
        //     minHeight: 600,
        //   ),
        child: ListView(
          padding: const EdgeInsets.only(top: 40.0, right: 20, left: 20, bottom: 20),
          children: [
            ConstrainedBox(constraints: const BoxConstraints(
              maxWidth: 400
            )),
            buildInput('Мастер-пароль', 'efasd<83', masterController, true, TextInputType.text),
            buildInput('Ключ шифрования', 'mum{gse24}', keyController, true, TextInputType.text),
            buildInput('Сервис', 'example.com', serviceController, false, TextInputType.text),
            buildInput('Длина пароля', '24', lengthController, false, TextInputType.number),

            const SizedBox(height: 20,),
            buildSwitch('Заглавные буквы', useUpper, (v) => setState(() => useUpper = v)),
            buildSwitch('Строчные буквы', useLower, (v) => setState(() => useLower = v)),
            buildSwitch('Цифры', useDigits, (v) => setState(() => useDigits = v)),
            buildSwitch('!@#\$%^&*()_+-=', useSpec1, (v) => setState(() => useSpec1 = v)),
            buildSwitch("\"'`,./;:[]}{<>\\|", useSpec2, (v) => setState(() => useSpec2 = v)),
            buildSwitch('~?', useSpec3, (v) => setState(() => useSpec3 = v)),
            
            const SizedBox(height: 24),
            CupertinoButton.filled(
              padding: const EdgeInsets.all(16.0),
              onPressed: generatePassword,
              child: const Text('Сгенерировать'),
            ),
            buildCopy('Пароль', generatedPassword, false),
            buildCopy('Шифр', secret, true),
            const SizedBox(height: 48),
          ],
        ),
      
    ));
  }
}