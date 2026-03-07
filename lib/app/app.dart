import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Data sources
import '../../data/datasources/encryptor_local_datasource.dart';
import '../../data/datasources/password_generator_local_datasource.dart';
import '../../data/datasources/storage_local_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';

// Repositories
import '../../data/repositories/password_generator_repository_impl.dart';
import '../../data/repositories/encryptor_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/security_log_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/app_settings_repository_impl.dart';

// Use cases
import '../../domain/usecases/password/generate_password_usecase.dart';
import '../../domain/usecases/password/save_password_usecase.dart';
import '../../domain/usecases/encryptor/encrypt_message_usecase.dart';
import '../../domain/usecases/encryptor/decrypt_message_usecase.dart';
import '../../domain/usecases/storage/get_configs_usecase.dart';
import '../../domain/usecases/storage/save_configs_usecase.dart';
import '../../domain/usecases/storage/get_passwords_usecase.dart';
import '../../domain/usecases/storage/delete_password_usecase.dart';
import '../../domain/usecases/storage/export_passwords_usecase.dart';
import '../../domain/usecases/storage/import_passwords_usecase.dart';
import '../../domain/usecases/storage/export_passgen_usecase.dart';
import '../../domain/usecases/storage/import_passgen_usecase.dart';
import '../../domain/usecases/auth/setup_pin_usecase.dart';
import '../../domain/usecases/auth/verify_pin_usecase.dart';
import '../../domain/usecases/auth/change_pin_usecase.dart';
import '../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../domain/usecases/auth/get_auth_state_usecase.dart';
import '../../domain/usecases/log/log_event_usecase.dart';
import '../../domain/usecases/log/get_logs_usecase.dart';
import '../../domain/usecases/category/get_categories_usecase.dart';
import '../../domain/usecases/category/create_category_usecase.dart';
import '../../domain/usecases/category/delete_category_usecase.dart';
import '../../domain/usecases/category/update_category_usecase.dart';
import '../../domain/usecases/settings/get_setting_usecase.dart';
import '../../domain/usecases/settings/set_setting_usecase.dart';
import '../../domain/usecases/settings/remove_setting_usecase.dart';

// Controllers
import '../../presentation/features/generator/generator_controller.dart';
import '../../presentation/features/encryptor/encryptor_controller.dart';
import '../../presentation/features/storage/storage_controller.dart';
import '../../presentation/features/auth/auth_controller.dart';

// Screens
import '../../presentation/features/generator/generator_screen.dart';
import '../../presentation/features/encryptor/encryptor_screen.dart';
import '../../presentation/features/storage/storage_screen.dart';
import '../../presentation/features/about/about_screen.dart';
import '../../presentation/features/auth/auth_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';

/// Перечисление для типобезопасного управления вкладками
enum AppTab {
  generator(Icons.create, 'Генератор'),
  encryptor(Icons.lock, 'Шифратор'),
  storage(Icons.archive, 'Хранилище'),
  settings(Icons.settings, 'Настройки'),
  about(Icons.info, 'О программе');

  const AppTab(this.icon, this.label);
  final IconData icon;
  final String label;

  static AppTab fromIndex(int index) => values[index.clamp(0, values.length - 1)];
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Data Sources (singletons)
        Provider(create: (_) => EncryptorLocalDataSource()),
        Provider(create: (_) => StorageLocalDataSource()),
        Provider(create: (_) => AuthLocalDataSource()),
        Provider(
          create: (context) => PasswordGeneratorLocalDataSource(
            context.read<EncryptorLocalDataSource>(),
            context.read<StorageLocalDataSource>(),
          ),
        ),

        // Repositories
        Provider(
          create: (context) => PasswordGeneratorRepositoryImpl(
            context.read<PasswordGeneratorLocalDataSource>(),
          ),
        ),
        Provider(
          create: (context) => EncryptorRepositoryImpl(
            context.read<EncryptorLocalDataSource>(),
          ),
        ),
        Provider(
          create: (context) => StorageRepositoryImpl(
            context.read<StorageLocalDataSource>(),
          ),
        ),
        Provider(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthLocalDataSource>(),
          ),
        ),
        Provider(
          create: (context) => SecurityLogRepositoryImpl(),
        ),
        Provider(
          create: (context) => CategoryRepositoryImpl(),
        ),
        Provider(
          create: (context) => AppSettingsRepositoryImpl(),
        ),

        // Use Cases
        Provider(
          create: (context) => GeneratePasswordUseCase(
            context.read<PasswordGeneratorRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => SavePasswordUseCase(
            context.read<PasswordGeneratorRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => EncryptMessageUseCase(
            context.read<EncryptorRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => DecryptMessageUseCase(
            context.read<EncryptorRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => GetConfigsUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => SaveConfigsUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => GetPasswordsUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => DeletePasswordUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => ExportPasswordsUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => ImportPasswordsUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => ExportPassgenUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => ImportPassgenUseCase(
            context.read<StorageRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => SetupPinUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => VerifyPinUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => ChangePinUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => RemovePinUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => GetAuthStateUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => LogEventUseCase(
            context.read<SecurityLogRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => GetLogsUseCase(
            context.read<SecurityLogRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => GetCategoriesUseCase(
            context.read<CategoryRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => CreateCategoryUseCase(
            context.read<CategoryRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => DeleteCategoryUseCase(
            context.read<CategoryRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => UpdateCategoryUseCase(
            context.read<CategoryRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => GetSettingUseCase(
            context.read<AppSettingsRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => SetSettingUseCase(
            context.read<AppSettingsRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => RemoveSettingUseCase(
            context.read<AppSettingsRepositoryImpl>(),
          ),
        ),

        // Controllers
        ChangeNotifierProxyProvider3<
          GeneratePasswordUseCase,
          SavePasswordUseCase,
          LogEventUseCase,
          GeneratorController>(
          create: (context) => GeneratorController(
            generatePasswordUseCase: context.read<GeneratePasswordUseCase>(),
            savePasswordUseCase: context.read<SavePasswordUseCase>(),
            logEventUseCase: context.read<LogEventUseCase>(),
          ),
          update: (_, genUc, saveUc, logUc, controller) => GeneratorController(
            generatePasswordUseCase: genUc,
            savePasswordUseCase: saveUc,
            logEventUseCase: logUc,
          ),
        ),
        ChangeNotifierProxyProvider2<EncryptMessageUseCase, DecryptMessageUseCase, EncryptorController>(
          create: (context) => EncryptorController(
            encryptUseCase: context.read<EncryptMessageUseCase>(),
            decryptUseCase: context.read<DecryptMessageUseCase>(),
          ),
          update: (_, encryptUc, decryptUc, controller) => EncryptorController(
            encryptUseCase: encryptUc,
            decryptUseCase: decryptUc,
          ),
        ),
        ChangeNotifierProxyProvider5<
          GetPasswordsUseCase,
          DeletePasswordUseCase,
          ExportPasswordsUseCase,
          ImportPasswordsUseCase,
          LogEventUseCase,
          StorageController>(
          create: (context) => StorageController(
            getPasswordsUseCase: context.read<GetPasswordsUseCase>(),
            deletePasswordUseCase: context.read<DeletePasswordUseCase>(),
            exportPasswordsUseCase: context.read<ExportPasswordsUseCase>(),
            importPasswordsUseCase: context.read<ImportPasswordsUseCase>(),
            logEventUseCase: context.read<LogEventUseCase>(),
          ),
          update: (_, getUc, deleteUc, exportUc, importUc, logUc, controller) => StorageController(
            getPasswordsUseCase: getUc,
            deletePasswordUseCase: deleteUc,
            exportPasswordsUseCase: exportUc,
            importPasswordsUseCase: importUc,
            logEventUseCase: logUc,
          ),
        ),
        ChangeNotifierProxyProvider6<
          SetupPinUseCase,
          VerifyPinUseCase,
          ChangePinUseCase,
          RemovePinUseCase,
          GetAuthStateUseCase,
          LogEventUseCase,
          AuthController>(
          create: (context) => AuthController(
            setupPinUseCase: context.read<SetupPinUseCase>(),
            verifyPinUseCase: context.read<VerifyPinUseCase>(),
            changePinUseCase: context.read<ChangePinUseCase>(),
            removePinUseCase: context.read<RemovePinUseCase>(),
            getAuthStateUseCase: context.read<GetAuthStateUseCase>(),
            logEventUseCase: context.read<LogEventUseCase>(),
          ),
          update: (_, setupUc, verifyUc, changeUc, removeUc, getStateUc, logUc, controller) => AuthController(
            setupPinUseCase: setupUc,
            verifyPinUseCase: verifyUc,
            changePinUseCase: changeUc,
            removePinUseCase: removeUc,
            getAuthStateUseCase: getStateUc,
            logEventUseCase: logUc,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PassGen',
        home: const AuthWrapper(),
        theme: getTheme(false),
        darkTheme: getTheme(true),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
      ),
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
      isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}

class TabScaffold extends StatefulWidget {
  const TabScaffold({super.key});

  @override
  State<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  AppTab _currentTab = AppTab.generator;

  void _onTabTapped(int index) {
    final newTab = AppTab.fromIndex(index);
    if (_currentTab != newTab) {
      setState(() => _currentTab = newTab);
    }
    // Сбрасываем таймер неактивности при переключении вкладок
    context.read<AuthController>().resetInactivityTimer();
  }

  @override
  void initState() {
    super.initState();
    // Запускаем таймер неактивности после сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().resetInactivityTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Listener(
      onPointerDown: (_) {
        // Сбрасываем таймер неактивности при любом касании
        context.read<AuthController>().resetInactivityTimer();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentTab.index,
          children: const [
            GeneratorScreen(),
            EncryptorScreen(),
            StorageScreen(),
            SettingsScreen(),
            AboutScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab.index,
          onTap: _onTabTapped,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          items: AppTab.values.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
              tooltip: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Обёртка для проверки состояния аутентификации
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthController>().authState;

    // Если не аутентифицирован - показываем экран аутентификации
    if (!authState.isAuthenticated) {
      return const AuthScreen();
    }

    // Если аутентифицирован - показываем основное приложение
    return const TabScaffold();
  }
}
