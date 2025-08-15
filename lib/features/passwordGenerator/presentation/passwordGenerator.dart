import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:secure_pass/features/passwordGenerator/domain/psswdGenInterface.dart';
import 'package:flutter/services.dart';
import 'package:secure_pass/features/storage/storageService.dart';


class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController masterController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController masterKeyController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController lengthController = TextEditingController(text: '16');
  late PasswordGenerationInterface generator;

  bool useRand = true;
  bool useUpper = true;
  bool useLower = true;
  bool useDigits = true;
  bool useSpec1 = false;
  bool useSpec2 = false;
  bool useSpec3 = false; 

  String generatedPassword = '';
  String secret = '';

  @override 
  void initState(){
    super.initState();
    generator = PasswordGenerationInterface();
    setupConfigs();
  }

  Future<void> setupConfigs() async{
    List<String> configs = await getConfig('psswdGen');
    print(configs);
    keyController.text = configs[0];
    masterKeyController.text = configs[1];
    masterController.text = configs[2];
    useRand = configs[3]=='true'?true:false;
    useUpper = configs[4]=='true'?true:false;
    useLower = configs[5]=='true'?true:false;
    useDigits = configs[6]=='true'?true:false;
    useSpec1 = configs[7]=='true'?true:false;
    useSpec2 = configs[8]=='true'?true:false;
    useSpec3 = configs[9]=='true'?true:false;
  }

  Future<void> generatePassword() async {
    setState(() {
      generatedPassword = 'Генерация...';
      secret = 'Криптографический анализ...';
    });
    final check = masterController.text.split('.');

    if (check.length == 4){
      final config = await generator.getConfig(config: masterController.text, key: keyController.text, masterKey: masterKeyController.text);
      final params = config.split('.');
      // print('$params');
      if (params.length == 9){
        String checkConfig = '';
        for (int i = 0; i < 8; i++){
          i!=7?checkConfig+='${params[i]}.':checkConfig+=params[i];
        }
        if (checkConfig.hashCode.toString() == params[8]){
          serviceController.text = check[0];
          masterController.text = params[0];
          lengthController.text = params[1];
          useUpper = params[2]=='true'?true:false;
          useLower = params[3]=='true'?true:false;
          useDigits = params[4]=='true'?true:false;
          useSpec1 = params[5]=='true'?true:false;
          useSpec2 = params[6]=='true'?true:false;
          useSpec3 = params[7]=='true'?true:false;
        }
      }
    }

    final success = await generator.generatePsswdSecret(
      master: masterController.text, 
      key: keyController.text,
      masterKey: masterKeyController.text,
      service: serviceController.text, 
      length: lengthController.text, 
      useUpper: useUpper, 
      useLower: useLower, 
      useDigits: useDigits, 
      useSpec1: useSpec1, 
      useSpec2: useSpec2, 
      useSpec3: useSpec3,
      secretPsswd: 'RH2RFC@u054+ERrWIao8dhJ4WB&THPhihXC()VYZY#SIX6^Y&DB1^b6WO)Y5#QlhG\$Y5U@DscggM(Crw!(CJ^Wl1YXR\$^Q&gg=gV^SUavI!Dr2XP&tCVaEiY1KE7Al30' 
      // secretPsswd для личного секретного пароля для генерации пароля
      // ПРИ ИЗМЕНЕНИИ МЕНЯЕТ ЛОГИКУ ФОРМИРОВАНИЯ ПАРОЛЯ
      // ПРИЛОЖЕНИЯ С РАЗНЫМИ ПАРОЛЯМИ НЕСОВМЕСТИМЫ ДЛЯ ГЕНЕРАЦИИ ОДИНАКОВЫХ ПАРОЛЕЙ ПРИ ОДИНАКОВЫХ КОНФИГАХ
    );

    if (useRand == true){
      masterController.text = await generator.generateMaster();
    }

    // print(await getConfig());
    await saveConfig('psswdGen', [
      keyController.text, 
      masterKeyController.text, 
      masterController.text,
      useRand.toString(),
      useUpper.toString(),
      useLower.toString(),
      useDigits.toString(),
      useSpec1.toString(),
      useSpec2.toString(),
      useSpec3.toString()
      ]);

    setState(() {
      generatedPassword = success[0];
      secret = success[1];
    });
  }

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
          padding: const EdgeInsets.only(top: 100.0, right: 20, left: 20, bottom: 20),
          children: [
            ConstrainedBox(constraints: const BoxConstraints(
              maxWidth: 400
            )),
            buildInput('Мастер-пароль', 'efasd<83', masterController, true, TextInputType.text),
            buildSwitch('Рандомный мастер-пароль', useRand, (v) => setState(() => useRand = v)),
            buildInput('Ключ шифрования', 'mum{gse24}', keyController, true, TextInputType.text),
            buildInput('Мастер-ключ шифрования', 'jasdkb{bc[]}', masterKeyController, true, TextInputType.text),
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
            buildCopy('Пароль', generatedPassword, true),
            buildCopy('Шифр', secret, true),
            const SizedBox(height: 48),
          ],
        ),
      
    ));
  }
}