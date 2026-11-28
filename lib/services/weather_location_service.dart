import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherLocationData {
  final String locationName;
  final double temperature;
  final int humidity;
  final double apparentTemperature;
  final int weatherCode;
  final double latitude;
  final double longitude;

  WeatherLocationData({
    required this.locationName,
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.weatherCode,
    this.latitude = 6.9271,
    this.longitude = 79.8612,
  });
}

/// Real-time live Location and Weather Service for AquaSoothe
/// Uses device Hardware GPS (Geolocator) + HTTPS Geolocation fallback + Open-Meteo
class WeatherLocationService {
  /// Fetches current user location via device GPS or HTTPS Geolocation, then queries Open-Meteo for live weather
  static Future<WeatherLocationData> fetchCurrentLocationAndWeather() async {
    double lat = 6.9271; // Default Colombo fallback
    double lon = 79.8612;
    String locationName = 'Colombo, Sri Lanka';
    bool locationFound = false;

    // 1. Priority 1: High-accuracy Device GPS via Geolocator
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 5),
            ),
          );
          lat = position.latitude;
          lon = position.longitude;
          locationFound = true;

          // Reverse geocode GPS coordinates via OSM Nominatim
          try {
            final geoUri = Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
            );
            final geoRes = await http.get(
              geoUri,
              headers: {'User-Agent': 'AquaSootheApp/1.0 (contact@aquasoothe.app)'},
            ).timeout(const Duration(seconds: 4));

            if (geoRes.statusCode == 200) {
              final geoData = jsonDecode(geoRes.body) as Map<String, dynamic>;
              final address = geoData['address'] as Map<String, dynamic>? ?? {};
              final place = address['city'] ??
                  address['town'] ??
                  address['suburb'] ??
                  address['village'] ??
                  address['county'] ??
                  address['municipality'] ??
                  '';
              final country = address['country'] ?? 'Sri Lanka';
              if (place.toString().isNotEmpty) {
                locationName = '$place, $country';
              }
            }
          } catch (e) {
            debugPrint('Reverse geocode error: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Device GPS location error: $e');
    }

    // 2. Priority 2: HTTPS IP Geolocation via ipwho.is (zero-permission, fast & accurate)
    if (!locationFound) {
      try {
        final ipRes = await http.get(
          Uri.parse('https://ipwho.is/'),
        ).timeout(const Duration(seconds: 4));

        if (ipRes.statusCode == 200) {
          final ipData = jsonDecode(ipRes.body) as Map<String, dynamic>;
          if (ipData['success'] == true) {
            lat = (ipData['latitude'] as num).toDouble();
            lon = (ipData['longitude'] as num).toDouble();
            final city = ipData['city'] as String? ?? '';
            final country = ipData['country'] as String? ?? 'Sri Lanka';
            locationName = city.isNotEmpty ? '$city, $country' : country;
            locationFound = true;
          }
        }
      } catch (_) {}
    }

    // 3. Priority 3: HTTPS IP Geolocation via ipinfo.io
    if (!locationFound) {
      try {
        final ipRes = await http.get(
          Uri.parse('https://ipinfo.io/json'),
        ).timeout(const Duration(seconds: 4));

        if (ipRes.statusCode == 200) {
          final ipData = jsonDecode(ipRes.body) as Map<String, dynamic>;
          final loc = ipData['loc'] as String? ?? '';
          if (loc.contains(',')) {
            final parts = loc.split(',');
            lat = double.tryParse(parts[0]) ?? lat;
            lon = double.tryParse(parts[1]) ?? lon;
          }
          final city = ipData['city'] as String? ?? '';
          final country = ipData['country'] as String? ?? 'Sri Lanka';
          locationName = city.isNotEmpty ? '$city, $country' : country;
        }
      } catch (_) {}
    }

    // 4. Fetch live hyper-local weather from Open-Meteo
    return fetchWeatherForCoordinates(lat, lon, locationName);
  }

  /// Fetches live weather for specific coordinates
  static Future<WeatherLocationData> fetchWeatherForCoordinates(
    double lat,
    double lon,
    String locationName,
  ) async {
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
          latitude: lat,
          longitude: lon,
        );
      }
    } catch (_) {}

    return WeatherLocationData(
      locationName: locationName,
      temperature: 30.0,
      humidity: 75,
      apparentTemperature: 32.0,
      weatherCode: 0,
      latitude: lat,
      longitude: lon,
    );
  }

  /// Search any city in Sri Lanka or globally with live suggestions
  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=6&language=en&format=json',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) {
          final m = e as Map<String, dynamic>;
          final name = m['name'] as String? ?? '';
          final admin1 = m['admin1'] as String? ?? '';
          final country = m['country'] as String? ?? '';
          final lat = (m['latitude'] as num?)?.toDouble() ?? 0.0;
          final lon = (m['longitude'] as num?)?.toDouble() ?? 0.0;
          final fullName = admin1.isNotEmpty ? '$name, $admin1, $country' : '$name, $country';
          return {
            'name': name,
            'fullName': fullName,
            'lat': lat,
            'lon': lon,
            'country': country,
          };
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Preset Sri Lankan locations for quick switching
  static const List<Map<String, dynamic>> sriLankanPresetsList = [
    {'name': 'Colombo', 'lat': 6.9271, 'lon': 79.8612, 'fullName': 'Colombo, Sri Lanka'},
    {'name': 'Kandy', 'lat': 7.2906, 'lon': 80.6337, 'fullName': 'Kandy, Sri Lanka'},
    {'name': 'Galle', 'lat': 6.0535, 'lon': 80.2210, 'fullName': 'Galle, Sri Lanka'},
    {'name': 'Nuwara Eliya', 'lat': 6.9497, 'lon': 80.7891, 'fullName': 'Nuwara Eliya, Sri Lanka'},
    {'name': 'Negombo', 'lat': 7.2083, 'lon': 79.8358, 'fullName': 'Negombo, Sri Lanka'},
    {'name': 'Gampaha', 'lat': 7.0917, 'lon': 79.9997, 'fullName': 'Gampaha, Sri Lanka'},
    {'name': 'Kurunegala', 'lat': 7.4863, 'lon': 80.3623, 'fullName': 'Kurunegala, Sri Lanka'},
    {'name': 'Jaffna', 'lat': 9.6615, 'lon': 80.0255, 'fullName': 'Jaffna, Sri Lanka'},
    {'name': 'Matara', 'lat': 5.9549, 'lon': 80.5550, 'fullName': 'Matara, Sri Lanka'},
    {'name': 'Anuradhapura', 'lat': 8.3114, 'lon': 80.4037, 'fullName': 'Anuradhapura, Sri Lanka'},
    {'name': 'Batticaloa', 'lat': 7.7102, 'lon': 81.6924, 'fullName': 'Batticaloa, Sri Lanka'},
    {'name': 'Ratnapura', 'lat': 6.6828, 'lon': 80.4037, 'fullName': 'Ratnapura, Sri Lanka'},
  ];

  static Future<WeatherLocationData> fetchWeatherForCity(String cityName) async {
    final match = sriLankanPresetsList.firstWhere(
      (element) => element['name'].toString().toLowerCase() == cityName.toLowerCase(),
      orElse: () => sriLankanPresetsList.first,
    );
    return fetchWeatherForCoordinates(
      match['lat'] as double,
      match['lon'] as double,
      match['fullName'] as String,
    );
  }
}
