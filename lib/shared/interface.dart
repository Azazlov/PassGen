import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

Widget buildSwitch(String label, bool value, void Function(bool) onChanged) {
  return CupertinoFormRow(
    padding: EdgeInsets.all(10),
    prefix: Text(label),
    child: CupertinoSwitch(value: value, onChanged: onChanged),
  );
}

Widget buildInput(String label, String placeholder, controller, hidden, symbols, submFunction){
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
      onSubmitted: (_) => submFunction()
    )
    ],
  );
}

Widget buildButton(label, function){
  return
  CupertinoButton.filled(
    padding: EdgeInsets.all(16.0),
    onPressed: function,
    child: Text(label),
  );
}

Widget buildBigText(text){
  return
  Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color.fromARGB(255, 90, 90, 90)),
    ),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 32, fontFamily: 'segoe UI'),
      ),
    ),
  );
}

Widget buildCopyOnTap(label, text1, function){
  return
  ListBody(
    children: [
      SizedBox(height: 48),
      Text(
        label, 
        style: TextStyle(fontSize: 20)
      ),
      text1!='' && text1 != "Нет конфигов"?
      GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text1));
            function();
          },
          child: buildBigText(text1)
      ):
      buildBigText(text1)
    ],
  );
}

EdgeInsets setPadding(){
  return EdgeInsets.only(top: 88, right: 30, left: 30, bottom: 88);
}