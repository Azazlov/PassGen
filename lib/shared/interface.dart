import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Переключатель
Widget buildSwitch({  
  required String label, 
  required bool value, 
  required void Function(bool) onChanged
  }) {
  return ListTile(
    leading: Icon(Icons.toll_sharp),
    title: Text(label),
    subtitle: Text('Включить или отключить $label'),
    trailing: 
    Switch(
      value: value,
      onChanged: onChanged,
    ),
  );
}

// Поле ввода
Widget buildInput({
  required String label, 
  required String placeholder, 
  required TextEditingController textController,
  required bool hidden, 
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
Widget buildCopyOnTap({
  required String label, 
  required String text1, 
  required Function function
  }) {
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


// Model for password option used by the option switches
class PasswordOption {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  PasswordOption({
    required this.label,
    required this.value,
    this.onChanged,
  });
}

class _PasswordCategoryTile extends StatelessWidget {
  final String title;
  final List<PasswordOption> options;

  const _PasswordCategoryTile({required this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: options.map((option) => _OptionSwitch(option: option)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionSwitch extends StatelessWidget {
  final PasswordOption option;

  const _OptionSwitch({required this.option});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch.adaptive(
          value: option.value,
          onChanged: (v) => option.onChanged?.call(v),
        ),
        Text(option.label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}