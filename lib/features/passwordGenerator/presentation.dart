// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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
          Text(
            'Настройки длины пароля',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),
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
          Divider(height: 32),
          ExpansionTile(
            title:  Text('Настройки обязательности'), children: [
            buildSwitch(
              label: 'Заглавные буквы', 
              value: data.reqUpper, 
              isUsed: (v) => setState(() => data.reqUpper = v),
              icon: Icons.text_fields
            ),
            buildSwitch(
              label: 'Строчные буквы', 
              value: data.reqLower, 
              isUsed: (v) => setState(() => data.reqLower = v),
              icon: Icons.text_fields
            ),
            buildSwitch(
              label: 'Цифры', 
              value: data.reqDigits, 
              isUsed: (v) => setState(() => data.reqDigits = v),
              icon: Icons.dialpad
            ),
            buildSwitch(
              label: 'Спец. символы', 
              value: data.reqSpec1, 
              isUsed: (v) => setState(() => data.reqSpec1 = v),
              icon: Icons.tag
            ),
            buildSwitch(
              label: "Доп. спец. символы", 
              value: data.reqSpec2, 
              isUsed: (v) => setState(() => data.reqSpec2 = v),
              icon: Icons.tag
            ),
          ]),
          SizedBox(height: 48),
          buildButton(
            label: 'Сгенерировать', 
            function: () {
              setState(() {
                try{
                  data.generatePassword();
                }
                catch (e){
                  showDialogWindow1("Ошибка", '$e', context);
                }
              });
              }
          ), 
          buildCopyOnTap(
            label: 'Пароль', 
            text1: data.password, 
            function: data.copyPsswd
          ),
        ],
      ),
    ));
  }
}