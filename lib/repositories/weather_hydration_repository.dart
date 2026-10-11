import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_hydration_model.dart';

class WeatherHydrationRepository {
  final SharedPreferences _prefs;
  static const String _key = 'aquasoothe_weather_hydration_v1';

  WeatherHydrationRepository(this._prefs);

  WeatherHydrationModel getWeatherSettings() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      return const WeatherHydrationModel();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherHydrationModel.fromJson(map);
    } catch (_) {
      return const WeatherHydrationModel();
    }
  }

  Future<void> saveWeatherSettings(WeatherHydrationModel model) async {
    await _prefs.setString(_key, jsonEncode(model.toJson()));
  }
}
