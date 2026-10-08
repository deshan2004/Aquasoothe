import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/settings_repository.dart';
import 'hydration_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

class SettingsState {
  final double textScaleFactor;
  final bool isOnboardingCompleted;
  final String lastUsedSoundId;
  final bool isDarkMode;

  SettingsState({
    required this.textScaleFactor,
    required this.isOnboardingCompleted,
    required this.lastUsedSoundId,
    required this.isDarkMode,
  });

  SettingsState copyWith({
    double? textScaleFactor,
    bool? isOnboardingCompleted,
    String? lastUsedSoundId,
    bool? isDarkMode,
  }) {
    return SettingsState(
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      lastUsedSoundId: lastUsedSoundId ?? this.lastUsedSoundId,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository)
      : super(SettingsState(
          textScaleFactor: _repository.getTextScaleFactor(),
          isOnboardingCompleted: _repository.isOnboardingCompleted(),
          lastUsedSoundId: _repository.getLastUsedSoundId(),
          isDarkMode: _repository.isDarkMode(),
        ));

  Future<void> setTextScaleFactor(double factor) async {
    await _repository.setTextScaleFactor(factor);
    state = state.copyWith(textScaleFactor: factor);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _repository.setOnboardingCompleted(completed);
    state = state.copyWith(isOnboardingCompleted: completed);
  }

  Future<void> setLastUsedSoundId(String id) async {
    await _repository.setLastUsedSoundId(id);
    state = state.copyWith(lastUsedSoundId: id);
  }

  Future<void> setDarkMode(bool isDark) async {
    await _repository.setDarkMode(isDark);
    state = state.copyWith(isDarkMode: isDark);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
