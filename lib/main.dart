import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'translations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'providers/operator_guard_provider.dart';
import 'providers/operator_block_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers
  FlutterError.onError = (details) {
    print('>>> Global FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    print('>>> Global PlatformDispatcher error: $error\n$stack');
    return true;
  };

  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;

  runApp(
    ProviderScope(
      child: NetTideApp(showHome: showHome),
    ),
  );
}

class NetTideApp extends ConsumerStatefulWidget {
  final bool showHome;
  const NetTideApp({Key? key, required this.showHome}) : super(key: key);

  @override
  ConsumerState<NetTideApp> createState() => _NetTideAppState();
}

class _NetTideAppState extends ConsumerState<NetTideApp> {
  @override
  void initState() {
    super.initState();
    // This ensures that the providers are read only after the first frame is rendered,
    // guaranteeing that the Flutter engine and platform channels are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(operatorGuardProvider);
      ref.read(operatorBlockControllerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    return MaterialApp(
      title: 'NetTide',
      themeMode: themeMode,
      locale: localeState.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
        Locale('es', ''),
        Locale('fr', ''),
        Locale('de', ''),
        Locale('pt', ''),
        Locale('zh', ''),
        Locale('hi', ''),
        Locale('id', ''),
        Locale('fil', ''),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2342),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: ThemeData.light().textTheme,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: ThemeData(brightness: Brightness.dark).textTheme,
      ),
      home: widget.showHome ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
