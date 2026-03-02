// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pass_gen/modules/generate_password.dart';
import 'package:pass_gen/shared/dialogs.dart';
import 'package:pass_gen/shared/interface.dart';
import 'logic.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {

  AppData data = AppData();

  @override 
  void initState(){
    super.initState();
    // setupConfigs();
  }

  @override
  Widget build(BuildContext context) {
  data.context = context;
  return 
  Scaffold(
    body: Center(
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SizedBox(height: 36),
          ListTile(
            title: Text(
              'Генератор паролей',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          buildCopyOnTap(
            label: 'Пароль', 
            text1: data.password, 
            function: data.copyPsswd
          ),
          buildInput(
            label: 'Сервис', 
            placeholder: 'Без точек', 
            textController: data.serviceController, 
            symbols: TextInputType.text, 
            submFunction: data.generatePassword
          ),
            Slider(
              value: data.passwordStrength.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              label: data.label,
              activeColor: data.color,
              onChanged: (value) {
                setState(() {
                  data.updateStrength(value.toInt());
                });
              },
            ),
          SizedBox(height: 18),
          ExpansionTile(
            title: Text('Настройки длины пароля'),
            children: [
              buildInput(
                label: 'Мин. длина', 
                placeholder: 'от 1 до 32', 
                textController: data.minLengthController, 
                symbols: TextInputType.number, 
                submFunction: data.generatePassword
              ),
              buildInput(
                label: 'Макс. длина', 
                placeholder: 'от 1 до 64', 
                textController: data.maxLengthController,  
                symbols: TextInputType.number, 
                submFunction: data.generatePassword
              ),
            ],
            ),
          // Divider(height: 32),
          ExpansionTile(
            title:  Text('Настройки обязательности'), children: [
            buildSwitch(
              label: 'Заглавные буквы', 
              value: data.reqUpper, 
              isUsed: (v){
                setState(() {
                  data.reqUpper = v;
                  data.toggleFlag(v? uppercaseIsReq: -uppercaseIsReq);
                });
              },
              icon: Icons.text_fields
            ),
            buildSwitch(
              label: 'Строчные буквы', 
              value: data.reqLower, 
              isUsed: (v){
                setState(() {
                  data.reqLower = v;
                  print(v);
                  data.toggleFlag(v? lowercaseIsReq: -lowercaseIsReq);
                });
              },
              icon: Icons.text_fields
            ),
            buildSwitch(
              label: 'Цифры', 
              value: data.reqDigits, 
              isUsed: (v){
                setState(() {
                  data.reqDigits = v;
                  data.toggleFlag(v? digitsIsReq: -digitsIsReq);
                });
              },
              icon: Icons.dialpad
            ),
            buildSwitch(
              label: 'Спец. символы', 
              value: data.reqSymbols, 
              isUsed: (v){
                setState(() {
                  data.reqSymbols = v;
                  data.toggleFlag(v? symbolsIsReq: -symbolsIsReq);
                });
              },
              icon: Icons.tag
            ),
          ]),
          SizedBox(height: 48),
          buildButton(
            label: 'Сгенерировать\n${data.strength}\n${data.config}\n${data.passwordConfig.configToBase64Mini()}', 
            function: () {
              setState(() {
                try{
                  if (!data.generating){
                    data.generatePassword();
                  }
                }
                catch (e){
                  showDialogWindow1("Ошибка", '$e', context);
                }
              });
              }
          ), 
        ],
      ),
    ));
  }
}