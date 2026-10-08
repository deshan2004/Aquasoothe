import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _textScaleKey = 'aquasoothe_text_scale';
  static const String _onboardingCompleteKey = 'aquasoothe_onboarding_done';
  static const String _lastUsedSoundKey = 'aquasoothe_last_sound';
  static const String _darkModeKey = 'aquasoothe_dark_mode';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  double getTextScaleFactor() {
    return _prefs.getDouble(_textScaleKey) ?? 1.1; // Default slightly larger 1.1x for 50+
  }

  Future<void> setTextScaleFactor(double factor) async {
    await _prefs.setDouble(_textScaleKey, factor);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompleteKey, completed);
  }

  String getLastUsedSoundId() {
    return _prefs.getString(_lastUsedSoundKey) ?? 'rainfall';
  }

  Future<void> setLastUsedSoundId(String id) async {
    await _prefs.setString(_lastUsedSoundKey, id);
  }

  bool isDarkMode() {
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_darkModeKey, isDark);
  }
}
