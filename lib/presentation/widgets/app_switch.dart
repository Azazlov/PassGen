import 'package:flutter/material.dart';

/// Переключатель (Switch) с иконкой и описанием
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Switch(value: value, onChanged: onChanged),
      dense: true,
      onTap: () => onChanged(!value),
      selected: value,
    );
  }
}
