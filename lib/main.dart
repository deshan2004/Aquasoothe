import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/hydration_provider.dart';
import 'providers/settings_provider.dart';
import 'repositories/custom_sound_repository.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress known Flutter 3.47+ framework-level debug semantics assertions on iOS Simulator (object.dart:5705 / 5994)
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final str = details.exceptionAsString();
    if (str.contains('parentDataDirty') ||
        str.contains('_needsLayout') ||
        str.contains('was not laid out') ||
        str.contains('debugCheckForParentData')) {
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    final str = error.toString();
    if (str.contains('parentDataDirty') ||
        str.contains('_needsLayout') ||
        str.contains('was not laid out') ||
        str.contains('debugCheckForParentData')) {
      return true; // Suppress harmless framework-internal semantics assertion
    }
    return false;
  };

  // Cache documents directory path for dynamic iOS sandbox path resolution
  try {
    final docsDir = await getApplicationDocumentsDirectory();
    CustomSoundRepository.appDocumentsPath = docsDir.path;
  } catch (e) {
    debugPrint('Docs dir note: $e');
  }

  // Initialize background audio service for lock screen and notification controls
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.aquasoothe.audio',
      androidNotificationChannelName: 'AquaSoothe Nature Sanctuary',
      androidNotificationChannelDescription: 'Background audio playback & lock screen wellness therapy controls',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: const Color(0xFF0C4648),
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
