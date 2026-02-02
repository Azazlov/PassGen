import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Переключатель
Widget buildSwitch({  
  required String label, 
  required bool value, 
  required void Function(bool) isUsed,
  required IconData icon
  }) {
  return ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text('В пароле будут $label'),
    trailing: 
      Switch(
        value: value,
        onChanged: isUsed,
      ),
    dense: true,
    onTap: () => isUsed(!value),
    selected: value,
  );
}

Widget buildSwitchWithUnique({  
  required String label, 
  required bool value, 
  required void Function(bool) isUsed,
  required bool? Function(bool?) isUnique,
  required IconData icon
  }) {
  return ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text('Включить или отключить $label'),
    trailing: 
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Уникальные'),
          Checkbox(
            value: value,
            onChanged: isUnique,
          ),
          Switch(
            value: value,
            onChanged: isUsed,
          ),
        ],
      ));
  }

// Поле ввода
Widget buildInput({
  required String label, 
  required String placeholder, 
  required TextEditingController textController,
  bool hidden = false, 
  required TextInputType symbols, 
  required Function submFunction
  }) {
  return Column(
    children: [
      const SizedBox(height: 18),
      // Text(label),
      TextFormField(
        keyboardType: symbols,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'.*')),
        ],
        controller: textController,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );
}

// Кнопка
Widget buildButton({  
  required String label, 
  required VoidCallback function
  }) {
  return ElevatedButton(
    onPressed: function,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(label),
  );
}

// Большой текст
Widget buildBigText(String text) {
  return Container(
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

// Текст с копированием
// Текст с копированием
Widget buildCopyOnTap({
  required String label, 
  required String text1, 
  required Function function
  }) {
  return Column(
    children: [
      const SizedBox(height: 48),
      Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 16),
      text1 != '' && text1 != "Нет конфигов"
          ? GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text1));
                function();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 90, 90, 90),
                      width: 2,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 245, 245, 245),
                        const Color.fromARGB(255, 235, 235, 235),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          text1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontFamily: 'segoe UI',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : buildBigText(text1),
    ],
  );
}

EdgeInsets setPadding() {
  return EdgeInsets.only(top: 88, right: 30, left: 30, bottom: 88);
}

