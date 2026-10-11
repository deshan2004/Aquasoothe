import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_hydration_model.dart';
import '../repositories/weather_hydration_repository.dart';
import 'hydration_provider.dart';

final weatherHydrationRepositoryProvider = Provider<WeatherHydrationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WeatherHydrationRepository(prefs);
});

class WeatherHydrationNotifier extends StateNotifier<WeatherHydrationModel> {
  final WeatherHydrationRepository _repository;
  final Ref _ref;

  WeatherHydrationNotifier(this._repository, this._ref) : super(_repository.getWeatherSettings());

  Future<void> updateTemperature(double temp) async {
    final updated = state.copyWith(temperatureCelsius: temp);
    state = updated;
    await _repository.saveWeatherSettings(updated);
    _syncWithHydrationGoal();
  }

  Future<void> toggleSmartAdjustment(bool enabled) async {
    final updated = state.copyWith(isSmartAdjustmentEnabled: enabled);
    state = updated;
    await _repository.saveWeatherSettings(updated);
    _syncWithHydrationGoal();
  }

  Future<void> setPresetLocation({
    required String locationName,
    required double temp,
    required int humidity,
  }) async {
    final updated = state.copyWith(
      locationName: locationName,
      temperatureCelsius: temp,
      humidityPercent: humidity,
    );
    state = updated;
    await _repository.saveWeatherSettings(updated);
    _syncWithHydrationGoal();
  }

  /// Automatically synchronizes the calculated weather goal with the core HydrationNotifier
  void _syncWithHydrationGoal() {
    try {
      final hydrationNotifier = _ref.read(hydrationProvider.notifier);
      final currentGoal = _ref.read(hydrationProvider).goal;
      final target = state.effectiveGoalMl;
      if (currentGoal.dailyTargetMl != target) {
        hydrationNotifier.updateGoal(currentGoal.copyWith(dailyTargetMl: target));
      }
    } catch (_) {}
  }
}

final weatherHydrationProvider = StateNotifierProvider<WeatherHydrationNotifier, WeatherHydrationModel>((ref) {
  final repo = ref.watch(weatherHydrationRepositoryProvider);
  return WeatherHydrationNotifier(repo, ref);
});
