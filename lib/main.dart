import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/hydration_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background audio service for lock screen and notification controls
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.aquasoothe.audio',
      androidNotificationChannelName: 'AquaSoothe Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  } catch (e) {
    debugPrint('JustAudioBackground init note: $e');
  }

  // Initialize Firebase with project credentials
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
    final settingsState = ref.watch(settingsProvider);
    final textScaleFactor = settingsState.textScaleFactor;

    return MaterialApp(
      title: 'AquaSoothe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(textScaleFactor),
      darkTheme: AppTheme.darkTheme(textScaleFactor),
      themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
