import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/database/database_helper.dart';
import '../../data/datasources/auth_local_datasource.dart';
// Data sources
import '../../data/datasources/encryptor_local_datasource.dart';
import '../../data/datasources/password_generator_local_datasource.dart';
import '../../data/datasources/storage_local_datasource.dart';
import '../../data/formats/passgen_format.dart';
import '../../data/repositories/app_settings_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/encryptor_repository_impl.dart';
// Repositories
import '../../data/repositories/password_data_repository_impl.dart';
import '../../data/repositories/password_generator_repository_impl.dart';
import '../../data/repositories/password_history_repository_impl.dart';
import '../../data/repositories/security_log_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../domain/repositories/biometric_repository.dart';
import '../../domain/repositories/password_generator_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/qr_transfer_repository.dart';
import '../../domain/services/glitch_service.dart';
import '../../domain/services/performance_benchmark_service.dart';
import '../../domain/services/vault_unlock_service.dart';
import '../../domain/usecases/auth/change_pin_usecase.dart';
import '../../domain/usecases/auth/get_auth_state_usecase.dart';
import '../../domain/usecases/auth/remove_pin_usecase.dart';
import '../../domain/usecases/auth/setup_pin_usecase.dart';
import '../../domain/usecases/auth/verify_pin_usecase.dart';
import '../../domain/usecases/category/create_category_usecase.dart';
import '../../domain/usecases/category/delete_category_usecase.dart';
import '../../domain/usecases/category/get_categories_usecase.dart';
import '../../domain/usecases/category/update_category_usecase.dart';
import '../../domain/usecases/encryptor/decrypt_message_usecase.dart';
import '../../domain/usecases/encryptor/encrypt_message_usecase.dart';
import '../../domain/usecases/generator/validate_generator_settings_usecase.dart';
import '../../domain/usecases/log/clear_logs_usecase.dart';
import '../../domain/usecases/log/get_logs_usecase.dart';
import '../../domain/usecases/log/log_event_usecase.dart';
// Use cases
import '../../domain/usecases/password/generate_password_usecase.dart';
import '../../domain/usecases/password/get_password_history_usecase.dart';
import '../../domain/usecases/password/save_password_history_usecase.dart';
import '../../domain/usecases/password/save_password_usecase.dart';
import '../../domain/usecases/settings/get_setting_usecase.dart';
import '../../domain/usecases/settings/remove_setting_usecase.dart';
import '../../domain/usecases/settings/set_setting_usecase.dart';
import '../../domain/usecases/storage/delete_password_usecase.dart';
import '../../domain/usecases/storage/update_entry_usecase.dart';
import '../../domain/usecases/storage/export_passgen_usecase.dart';
import '../../domain/usecases/storage/export_passwords_usecase.dart';
import '../../domain/usecases/storage/get_passwords_usecase.dart';
import '../../domain/usecases/storage/import_passgen_usecase.dart';
import '../../domain/usecases/storage/import_passwords_usecase.dart';
import '../../domain/validators/password_settings_validator.dart';

import '../../presentation/features/auth/auth_controller.dart';
import '../../presentation/features/auth/auth_screen.dart';
import '../../presentation/features/categories/categories_controller.dart';
import '../../presentation/features/encryptor/encryptor_controller.dart';
import '../../presentation/features/encryptor/encryptor_screen.dart';
// Controllers
import '../../presentation/features/generator/generator_controller.dart';
// Screens
import '../../presentation/features/generator/generator_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';
import '../../presentation/features/storage/storage_controller.dart';
import '../../presentation/features/storage/storage_screen.dart';
import '../../presentation/widgets/global_error_banner.dart';
import '../../presentation/widgets/global_error_handler.dart';
// Core
import '../core/constants/breakpoints.dart';
import '../core/constants/spacing.dart';
import '../core/services/navigation_service.dart';

/// Перечисление для типобезопасного управления вкладками
/// Определено в navigation_service.dart
// enum AppTab - больше не нужен, импортируется из navigation_service.dart

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({
    super.key,
    this.authDataSource,
    this.authRepository,
    this.profileRepository,
    this.biometricRepository,
    this.qrTransferRepository,
    this.glitchService,
    this.benchmarkService,
    this.setupPinUseCase,
    this.verifyPinUseCase,
    this.changePinUseCase,
    this.removePinUseCase,
    this.getAuthStateUseCase,
    this.logEventUseCase,
  });
  final AuthLocalDataSource? authDataSource;
  final AuthRepositoryImpl? authRepository;
  final ProfileRepository? profileRepository;
  final BiometricRepository? biometricRepository;
  final QrTransferRepository? qrTransferRepository;
  final GlitchService? glitchService;
  final PerformanceBenchmarkService? benchmarkService;
  final SetupPinUseCase? setupPinUseCase;
  final VerifyPinUseCase? verifyPinUseCase;
  final ChangePinUseCase? changePinUseCase;
  final RemovePinUseCase? removePinUseCase;
  final GetAuthStateUseCase? getAuthStateUseCase;
  final LogEventUseCase? logEventUseCase;

  @override
  Widget build(BuildContext context) {
    // Сохраняем Use Cases в локальные переменные
    final setupPinUseCase = this.setupPinUseCase!;
    final verifyPinUseCase = this.verifyPinUseCase!;
    final changePinUseCase = this.changePinUseCase!;
    final removePinUseCase = this.removePinUseCase!;
    final getAuthStateUseCase = this.getAuthStateUseCase!;
    final logEventUseCase = this.logEventUseCase!;

    return MultiProvider(
      providers: [
        // Database Helper (должен быть первым!)
        Provider(create: (_) => DatabaseHelper()),

        // Сервис навигации
        ChangeNotifierProvider(create: (_) => NavigationService()),

        // Auth data source / repository - передаём готовые экземпляры (создаются в main.dart)
        Provider<AuthLocalDataSource>.value(value: authDataSource!),
        Provider<AuthRepositoryImpl>.value(value: authRepository!),
        Provider<ProfileRepository>.value(value: profileRepository!),
        Provider<BiometricRepository>.value(value: biometricRepository!),
        Provider<QrTransferRepository>.value(value: qrTransferRepository!),
        Provider<GlitchService>.value(value: glitchService!),
        Provider<PerformanceBenchmarkService>.value(value: benchmarkService!),
        Provider(create: (context) => SecurityLogRepositoryImpl()),

        // Data Sources (singletons)
        Provider(create: (_) => EncryptorLocalDataSource()),
        Provider(create: (_) => StorageLocalDataSource()),
        Provider(
          create: (context) => PasswordGeneratorLocalDataSource(
            context.read<EncryptorLocalDataSource>(),
            context.read<StorageLocalDataSource>(),
          ),
        ),

        // Repositories
        Provider<PasswordGeneratorRepositoryImpl>(
          create: (context) => PasswordGeneratorRepositoryImpl(
            context.read<PasswordGeneratorLocalDataSource>(),
          ),
        ),
        // Also expose as interface for abstraction
        Provider<PasswordGeneratorRepository>(
          create: (context) => context.read<PasswordGeneratorRepositoryImpl>(),
        ),
        Provider(
          create: (context) =>
              EncryptorRepositoryImpl(context.read<EncryptorLocalDataSource>()),
        ),
        Provider(create: (context) => PassgenFormat()),
        Provider(
          create: (context) =>
              StorageRepositoryImpl(context.read<StorageLocalDataSource>()),
        ),
        Provider(
          create: (context) => PasswordDataRepositoryImpl(
            context.read<StorageLocalDataSource>(),
            context.read<PassgenFormat>(),
          ),
        ),
        Provider(create: (context) => CategoryRepositoryImpl()),
        Provider(create: (context) => AppSettingsRepositoryImpl()),
        Provider(
          create: (context) =>
              PasswordHistoryRepositoryImpl(context.read<DatabaseHelper>()),
        ),
        ChangeNotifierProvider(create: (context) => GlobalErrorHandler()),

        // Use Cases
        Provider(create: (context) => const PasswordSettingsValidator()),
        Provider(
          create: (context) => ValidateGeneratorSettingsUseCase(
            context.read<PasswordSettingsValidator>(),
          ),
        ),
        Provider(
          create: (context) => GeneratePasswordUseCase(
            context.read<PasswordGeneratorRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => SavePasswordUseCase(
            context.read<PasswordGeneratorRepositoryImpl>(),
            context.read<PasswordHistoryRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => SavePasswordHistoryUseCase(
            context.read<PasswordHistoryRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => GetPasswordHistoryUseCase(
            context.read<PasswordHistoryRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) =>
              EncryptMessageUseCase(context.read<EncryptorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              DecryptMessageUseCase(context.read<EncryptorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetPasswordsUseCase(context.read<StorageRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              DeletePasswordUseCase(context.read<StorageRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              UpdateEntryUseCase(context.read<StorageRepositoryImpl>()),
        ),
        Provider(
          create: (context) => ExportPasswordsUseCase(
            context.read<PasswordDataRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => ImportPasswordsUseCase(
            context.read<PasswordDataRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) =>
              ExportPassgenUseCase(context.read<PasswordDataRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              ImportPassgenUseCase(context.read<PasswordDataRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              LogEventUseCase(context.read<SecurityLogRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetLogsUseCase(context.read<SecurityLogRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              ClearLogsUseCase(context.read<SecurityLogRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetCategoriesUseCase(context.read<CategoryRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              CreateCategoryUseCase(context.read<CategoryRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              DeleteCategoryUseCase(context.read<CategoryRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              UpdateCategoryUseCase(context.read<CategoryRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetSettingUseCase(context.read<AppSettingsRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              SetSettingUseCase(context.read<AppSettingsRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              RemoveSettingUseCase(context.read<AppSettingsRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              ChangePinUseCase(context.read<AuthRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              RemovePinUseCase(context.read<AuthRepositoryImpl>()),
        ),

        // Controllers
        ChangeNotifierProvider<CategoriesController>(
          create: (context) => CategoriesController(
            getCategoriesUseCase: context.read<GetCategoriesUseCase>(),
            createCategoryUseCase: context.read<CreateCategoryUseCase>(),
            updateCategoryUseCase: context.read<UpdateCategoryUseCase>(),
            deleteCategoryUseCase: context.read<DeleteCategoryUseCase>(),
          )..loadCategories(),
        ),
        ChangeNotifierProxyProvider5<
          GeneratePasswordUseCase,
          SavePasswordUseCase,
          ValidateGeneratorSettingsUseCase,
          LogEventUseCase,
          PasswordGeneratorRepositoryImpl,
          GeneratorController
        >(
          create: (context) => GeneratorController(
            generatePasswordUseCase: context.read<GeneratePasswordUseCase>(),
            savePasswordUseCase: context.read<SavePasswordUseCase>(),
            validateSettingsUseCase: context
                .read<ValidateGeneratorSettingsUseCase>(),
            logEventUseCase: context.read<LogEventUseCase>(),
            repository: context.read<PasswordGeneratorRepositoryImpl>(),
            getPasswordsUseCase: context.read<GetPasswordsUseCase>(),
          ),
          update: (context, genUc, saveUc, valUc, logUc, repo, controller) =>
              GeneratorController(
                generatePasswordUseCase: genUc,
                savePasswordUseCase: saveUc,
                validateSettingsUseCase: valUc,
                logEventUseCase: logUc,
                repository: repo,
                getPasswordsUseCase: context.read<GetPasswordsUseCase>(),
              ),
        ),
        ChangeNotifierProxyProvider2<
          EncryptMessageUseCase,
          DecryptMessageUseCase,
          EncryptorController
        >(
          create: (context) => EncryptorController(
            encryptUseCase: context.read<EncryptMessageUseCase>(),
            decryptUseCase: context.read<DecryptMessageUseCase>(),
          ),
          update: (_, encryptUc, decryptUc, controller) => EncryptorController(
            encryptUseCase: encryptUc,
            decryptUseCase: decryptUc,
          ),
        ),
        // StorageController с 7 зависимостями
        ChangeNotifierProvider<StorageController>(
          create: (context) => StorageController(
            getPasswordsUseCase: context.read<GetPasswordsUseCase>(),
            deletePasswordUseCase: context.read<DeletePasswordUseCase>(),
            exportPasswordsUseCase: context.read<ExportPasswordsUseCase>(),
            importPasswordsUseCase: context.read<ImportPasswordsUseCase>(),
            exportPassgenUseCase: context.read<ExportPassgenUseCase>(),
            importPassgenUseCase: context.read<ImportPassgenUseCase>(),
            logEventUseCase: context.read<LogEventUseCase>(),
            updateEntryUseCase: context.read<UpdateEntryUseCase>(),
            getPasswordHistoryUseCase: context.read<GetPasswordHistoryUseCase>(),
            savePasswordHistoryUseCase: context.read<SavePasswordHistoryUseCase>(),
            generatePasswordUseCase: context.read<GeneratePasswordUseCase>(),
            savePasswordUseCase: context.read<SavePasswordUseCase>(),
          ),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            setupPinUseCase: setupPinUseCase,
            verifyPinUseCase: verifyPinUseCase,
            changePinUseCase: changePinUseCase,
            removePinUseCase: removePinUseCase,
            getAuthStateUseCase: getAuthStateUseCase,
            logEventUseCase: logEventUseCase,
            biometricRepository: context.read<BiometricRepository>(),
            profileRepository: context.read<ProfileRepository>(),
            vaultUnlockService: authDataSource != null
                ? VaultUnlockService(
                    authDataSource: authDataSource!,
                    encryptor: EncryptorLocalDataSource(),
                    storage: StorageLocalDataSource(),
                  )
                : null,
            getSettingUseCase: context.read<GetSettingUseCase>(),
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

// Синяя цветовая схема согласно ТЗ
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2196F3), // Blue
  primary: const Color(0xFF2196F3),
  secondary: const Color(0xFF1976D2),
  tertiary: const Color(0xFF00897B),
  error: const Color(0xFFD32F2F),
  brightness: Brightness.light,
);

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2196F3), // Blue
  primary: const Color(0xFF64B5F6),
  secondary: const Color(0xFF42A5F5),
  tertiary: const Color(0xFF26A69A),
  error: const Color(0xFFEF5350),
  brightness: Brightness.dark,
);

ThemeData getTheme(bool isDarkMode) {
  final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();

  return ThemeData(
    useMaterial3: true,
    colorScheme: isDarkMode ? darkColorScheme : lightColorScheme,
    // Кастомизированная типографика согласно ТЗ (Раздел 2.3)
    textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: const TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: isDarkMode
          ? darkColorScheme.surface
          : lightColorScheme.surface,
      foregroundColor: isDarkMode
          ? darkColorScheme.onSurface
          : lightColorScheme.onSurface,
    ),
    // Кнопки высотой 48dp согласно ТЗ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: isDarkMode ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    // Анимации переходов согласно ТЗ (Раздел 10.1)
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
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
  NavigationService? _navigationService;

  void _onTabTapped(int index) {
    final newTab = AppTab.fromIndex(index);
    if (_currentTab != newTab) {
      setState(() => _currentTab = newTab);
      _navigationService?.navigateTo(newTab);
    }
    // Сбрасываем таймер неактивности при переключении вкладок
    context.read<AuthController>().resetInactivityTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Получаем сервис навигации
    _navigationService = context.read<NavigationService>();
    // Слушаем изменения из сервиса
    _navigationService!.addListener(_handleNavigationChange);
  }

  @override
  void dispose() {
    _navigationService?.removeListener(_handleNavigationChange);
    super.dispose();
  }

  void _handleNavigationChange() {
    if (_navigationService != null &&
        _currentTab != _navigationService!.currentTab) {
      setState(() {
        _currentTab = _navigationService!.currentTab;
      });
    }
  }

  /// Переключает на вкладку хранилища
  void navigateToStorage() {
    if (_currentTab != AppTab.storage) {
      setState(() => _currentTab = AppTab.storage);
      _navigationService?.navigateTo(AppTab.storage);
    }
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

  /// BottomNavigationBar для мобильных
  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: _currentTab.index,
      onTap: _onTabTapped,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }

  /// NavigationRail для планшетов и десктопов
  Widget _buildNavigationRail() {
    final theme = Theme.of(context);
    final isDesktop =
        MediaQuery.of(context).size.width >= Breakpoints.desktopMin;

    return NavigationRail(
      selectedIndex: _currentTab.index,
      onDestinationSelected: _onTabTapped,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedIconTheme: IconThemeData(
        color: theme.colorScheme.primary,
        size: isDesktop ? 28 : 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: isDesktop ? 28 : 24,
      ),
      selectedLabelTextStyle: theme.textTheme.labelLarge!,
      unselectedLabelTextStyle: theme.textTheme.labelLarge!.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      labelType: isDesktop
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.selected,
      minWidth: isDesktop ? 80 : 72,
      destinations: AppTab.values.map((tab) {
        return NavigationRailDestination(
          icon: Icon(tab.icon),
          label: Text(tab.label),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.md,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < Breakpoints.mobileMax;

    return Listener(
      onPointerDown: (_) {
        // Сбрасываем таймер неактивности при любом касании
        context.read<AuthController>().resetInactivityTimer();
      },
      child: Scaffold(
        body: Column(
          children: [
            // Глобальный баннер ошибок
            const GlobalErrorBanner(),
            // Основной контент
            Expanded(
              child: Row(
                children: [
                  // NavigationRail для планшетов/десктопов
                  if (!isMobile) _buildNavigationRail(),
                  // Основной контент
                  Expanded(
                    child: IndexedStack(
                      index: _currentTab.index,
                      children: const [
                        GeneratorScreen(),
                        EncryptorScreen(),
                        StorageScreen(),
                        SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // BottomNavigationBar только для мобильных
        bottomNavigationBar: isMobile ? _buildBottomNavigation() : null,
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
