import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherLocationData {
  final String locationName;
  final double temperature;
  final int humidity;
  final double apparentTemperature;
  final int weatherCode;

  WeatherLocationData({
    required this.locationName,
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.weatherCode,
  });
}

/// Real-time live Location and Weather Service for AquaSoothe
/// Uses IP Geolocation for zero-permission location tracking + Open-Meteo for live hyper-local weather
class WeatherLocationService {
  /// Fetches current user location via IP Geolocation, then queries Open-Meteo for live weather
  static Future<WeatherLocationData> fetchCurrentLocationAndWeather() async {
    double lat = 6.9271; // Default Colombo fallback
    double lon = 79.8612;
    String locationName = 'Colombo, Sri Lanka';

    // 1. Detect location via IP Geolocation (Zero permission needed, works across iOS Simulator & Android & WiFi)
    try {
      final ipRes = await http.get(
        Uri.parse('http://ip-api.com/json'),
      ).timeout(const Duration(seconds: 4));

      if (ipRes.statusCode == 200) {
        final ipData = jsonDecode(ipRes.body) as Map<String, dynamic>;
        if (ipData['status'] == 'success') {
          lat = (ipData['lat'] as num).toDouble();
          lon = (ipData['lon'] as num).toDouble();
          final city = ipData['city'] as String? ?? '';
          final country = ipData['country'] as String? ?? 'Sri Lanka';
          locationName = city.isNotEmpty ? '$city, $country' : country;
        }
      }
    } catch (_) {
      // Fallback to default Sri Lanka coordinates if IP geo has network timeout
    }

    // 2. Fetch live accurate weather from Open-Meteo API
    try {
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code',
      );
      final weatherRes = await http.get(weatherUrl).timeout(const Duration(seconds: 5));

      if (weatherRes.statusCode == 200) {
        final weatherData = jsonDecode(weatherRes.body) as Map<String, dynamic>;
        final current = weatherData['current'] as Map<String, dynamic>? ?? {};

        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 30.0;
        final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 75;
        final apparentTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
        final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

        return WeatherLocationData(
          locationName: locationName,
          temperature: temp,
          humidity: humidity,
          apparentTemperature: apparentTemp,
          weatherCode: weatherCode,
        );
      }
    } catch (_) {
      // Fallback
    }

    return WeatherLocationData(
      locationName: locationName,
      temperature: 30.0,
      humidity: 75,
      apparentTemperature: 32.0,
      weatherCode: 0,
    );
  }

  /// Preset Sri Lankan locations for quick switching
  static const Map<String, Map<String, dynamic>> sriLankanPresets = {
    'Colombo': {'lat': 6.9271, 'lon': 79.8612, 'name': 'Colombo, Sri Lanka'},
    'Kandy': {'lat': 7.2906, 'lon': 80.6337, 'name': 'Kandy, Sri Lanka'},
    'Galle': {'lat': 6.0535, 'lon': 80.2210, 'name': 'Galle, Sri Lanka'},
    'Nuwara Eliya': {'lat': 6.9497, 'lon': 80.7891, 'name': 'Nuwara Eliya, Sri Lanka'},
    'Anuradhapura': {'lat': 8.3114, 'lon': 80.4037, 'name': 'Anuradhapura, Sri Lanka'},
    'Jaffna': {'lat': 9.6615, 'lon': 80.0255, 'name': 'Jaffna, Sri Lanka'},
    'Polonnaruwa': {'lat': 7.9403, 'lon': 81.0188, 'name': 'Polonnaruwa, Sri Lanka'},
  };

  /// Fetch live weather for a specific preset city
  static Future<WeatherLocationData> fetchWeatherForCity(String cityName) async {
    final cityData = sriLankanPresets[cityName];
    if (cityData == null) return fetchCurrentLocationAndWeather();

    final lat = cityData['lat'] as double;
    final lon = cityData['lon'] as double;
    final name = cityData['name'] as String;

    try {
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code',
      );
      final weatherRes = await http.get(weatherUrl).timeout(const Duration(seconds: 5));

      if (weatherRes.statusCode == 200) {
        final weatherData = jsonDecode(weatherRes.body) as Map<String, dynamic>;
        final current = weatherData['current'] as Map<String, dynamic>? ?? {};

        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 30.0;
        final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 75;
        final apparentTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
        final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

        return WeatherLocationData(
          locationName: name,
          temperature: temp,
          humidity: humidity,
          apparentTemperature: apparentTemp,
          weatherCode: weatherCode,
        );
      }
    } catch (_) {}

    return WeatherLocationData(
      locationName: name,
      temperature: 30.0,
      humidity: 75,
      apparentTemperature: 32.0,
      weatherCode: 0,
    );
  }
}
