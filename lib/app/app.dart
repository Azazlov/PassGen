import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassGen',
      home: const TabScaffold(),
      theme: getTheme(false),
      darkTheme: getTheme(true),
      themeMode: ThemeMode.system,
    );
  }
}

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  brightness: Brightness.light,
);

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4),
  brightness: Brightness.dark,
);

ThemeData getTheme(bool isDarkMode) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: isDarkMode ? darkColorScheme : lightColorScheme,
    typography: Typography.material2018(),
    textTheme: GoogleFonts.latoTextTheme(
      isDarkMode?ThemeData.dark().textTheme:ThemeData.light().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
    // Дополнительные настройки темы
    // ...
  );
}