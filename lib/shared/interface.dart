import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Переключатель
Widget buildSwitch(String label, bool value, void Function(bool) onChanged) {
  return ListTile(
    title: Text(label),
    trailing: Switch(
      value: value,
      onChanged: onChanged,
    ),
  );
}

// Поле ввода
Widget buildInput(String label, String placeholder, TextEditingController controller,
    bool hidden, TextInputType symbols, Function submFunction) {
  return Column(
    children: [
      const SizedBox(height: 18),
      Text(label),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          // fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.all(12),
          hintText: placeholder,
        ),
        obscureText: hidden,
        keyboardType: symbols,
        onSubmitted: (_) => submFunction(),
      ),
    ],
  );
}

// Кнопка
Widget buildButton(String label, VoidCallback function) {
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
Widget buildCopyOnTap(String label, String text1, Function function) {
  return Column(
    children: [
      SizedBox(height: 48),
      Text(
        label,
        style: TextStyle(fontSize: 20),
      ),
      text1 != '' && text1 != "Нет конфигов"
          ? GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text1));
                function();
              },
              child: buildBigText(text1),
            )
          : buildBigText(text1),
    ],
  );
}

EdgeInsets setPadding() {
  return EdgeInsets.only(top: 88, right: 30, left: 30, bottom: 88);
}
