import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'providers/hydration_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Local Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const AquaSootheApp(),
    ),
  );
}

class AquaSootheApp extends ConsumerWidget {
  const AquaSootheApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final settingsState = ref.watch(settingsProvider);

    final textScaleFactor = settingsState.textScaleFactor;
    final isOnboardingCompleted = settingsState.isOnboardingCompleted;

    Widget homeWidget;
    if (user == null) {
      homeWidget = const AuthScreen();
    } else if (!isOnboardingCompleted) {
      homeWidget = const OnboardingScreen();
    } else {
      homeWidget = const MainNavigationScreen();
    }

    return MaterialApp(
      title: 'AquaSoothe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(textScaleFactor),
      darkTheme: AppTheme.darkTheme(textScaleFactor),
      themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: homeWidget,
    );
  }
}
