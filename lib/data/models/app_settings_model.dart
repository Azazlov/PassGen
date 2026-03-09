/// Модель настройки приложения для базы данных
class AppSettingsModel {
  const AppSettingsModel({
    required this.key,
    required this.value,
    this.encrypted = false,
  });

  /// Создание из Map (SQLite)
  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      key: map['key'] as String,
      value: map['value'] as String,
      encrypted: (map['encrypted'] as int?) == 1,
    );
  }
  final String key;
  final String value;
  final bool encrypted;

  /// Преобразование в Map (SQLite)
  Map<String, dynamic> toMap() {
    return {'key': key, 'value': value, 'encrypted': encrypted ? 1 : 0};
  }

  /// Копия с изменениями
  AppSettingsModel copyWith({String? key, String? value, bool? encrypted}) {
    return AppSettingsModel(
      key: key ?? this.key,
      value: value ?? this.value,
      encrypted: encrypted ?? this.encrypted,
    );
  }

  @override
  String toString() {
    return 'AppSettingsModel(key: $key, value: $value, encrypted: $encrypted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettingsModel &&
        other.key == key &&
        other.value == value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}
