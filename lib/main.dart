import 'package:flutter/cupertino.dart';
import 'package:secure_pass/psswdGen.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(const PasswordGeneratorApp());
  WidgetsFlutterBinding.ensureInitialized();
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Password Generator',
      home: PasswordGeneratorScreen(),
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController masterController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController lengthController = TextEditingController(text: '16');

  bool useUpper = true;
  bool useLower = true;
  bool useDigits = true;
  bool useSpec1 = false;
  bool useSpec2 = false;
  bool useSpec3 = false;

  String generatedPassword = 'Здесь будет ваш пароль';
  String pastInputs = '';
  String checkTo = '';
  int inputError = 0;

  void generatePassword() async {
    final master = masterController.text;
    final service = serviceController.text;
    final len = int.tryParse(lengthController.text) ?? 16;

    
    inputError = 0;
    checkTo = master+service+len.toString()+useUpper.toString()+useLower.toString()+useDigits.toString()+useSpec1.toString()+useSpec2.toString()+useSpec3.toString();

    if (checkTo == pastInputs){
      return;
    }
    pastInputs = checkTo;

    if (master.isEmpty || service.isEmpty) {
      setState(() => generatedPassword = 'Заполните все поля. ');
      inputError++;
    }else{
      if (master.length < 8){
        setState(() => generatedPassword = 'Мастер-пароль короткий! ');
        inputError++;
      }
      if (master.length > 64){
        setState(() => generatedPassword = 'Слишком длинный пароль! ');
        inputError++;
      }
    }

    if (!(useUpper || useLower || useDigits || useSpec1 || useSpec2 || useSpec3)){
      setState(() => generatedPassword = 'Выберите хотя бы один флажок. ');
      inputError++;
    }

    if (inputError > 0){
      return;
    }

    setState(() => generatedPassword = 'Генерация...');

    final psswd = await compute(generateSync, {
      'master': master,
      'service': service,
      'length': len,
      'upper': useUpper,
      'lower': useLower,
      'digits': useDigits,
      'spec1': useSpec1,
      'spec2': useSpec2,
      'spec3': useSpec3,
    });

    setState(() {
      generatedPassword = psswd;
    });
  }

  Widget buildSwitch(String label, bool value, void Function(bool) onChanged) {
    return CupertinoFormRow(
      prefix: Text(label),
      child: CupertinoSwitch(value: value, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Генератор паролей'),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 400,
            maxWidth: 800,
            minHeight: 600,
          ),
        child: ListView(
          padding: const EdgeInsets.only(top: 60.0, right: 20, left: 20, bottom: 20),
          children: [
            Text('Мастер-пароль'),
            CupertinoTextField(
              padding: const EdgeInsets.all(16.0),
              controller: masterController,
              placeholder: 'Не забудьте его!',
              obscureText: true,
              onSubmitted: (_) => generatePassword()
            ),
            const SizedBox(height: 12),
            Text('Сервис (example.com)'),
            CupertinoTextField(
              padding: const EdgeInsets.all(16.0),
              controller: serviceController,
              placeholder: 'Можно дополнить почтой/номером телефона',
              onSubmitted: (_) => generatePassword()
            ),

            const SizedBox(height: 12),
            Text('Длина пароля'),
            CupertinoTextField(
              padding: const EdgeInsets.all(16.0),
              controller: lengthController,
              placeholder: 'от 8 до 64',
              keyboardType: TextInputType.number,
              onSubmitted: (_) => generatePassword()
              
            ),

            const SizedBox(height: 24),
            buildSwitch('Заглавные буквы', useUpper, (v) => setState(() => useUpper = v)),
            buildSwitch('Строчные буквы', useLower, (v) => setState(() => useLower = v)),
            buildSwitch('Цифры', useDigits, (v) => setState(() => useDigits = v)),
            buildSwitch('!@#\$%^&*()_+-=', useSpec1, (v) => setState(() => useSpec1 = v)),
            buildSwitch("\"'`,./;:[]}{<>\\|", useSpec2, (v) => setState(() => useSpec2 = v)),
            buildSwitch('~?', useSpec3, (v) => setState(() => useSpec3 = v)),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              child: const Text('Сгенерировать'),
              padding: const EdgeInsets.all(16.0),
              onPressed: generatePassword,
            ),
            const SizedBox(height: 24),
            ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: generatedPassword));
                  showCupertinoDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      title: const Text('Скопировано'),
                      content: const Text('Пароль скопирован в буфер обмена.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey),
                  ),
                  child: Center(
                    child: Text(
                      generatedPassword,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontFamily: 'segoe UI', color: Color.fromARGB(255, 234, 234, 234)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }
}
