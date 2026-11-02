import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/hydration_model.dart';
import '../models/sound_model.dart';
import '../models/medication_model.dart';
import '../models/sleep_journal_model.dart';
import '../models/user_model.dart';

/// Client service that connects Flutter to the AquaSoothe MS SQL REST API backend.
class SqlApiService {
  // Configurable base URL:
  // - iOS Simulator / macOS / Web: http://localhost:5001/api
  // - Android Emulator: http://10.0.2.2:5001/api
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5001/api';
    }
    return 'http://localhost:5001/api';
  }

  static const Duration _timeout = Duration(seconds: 4);

  /// Checks if the MS SQL backend is reachable and running
  static Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // Authentication
  // -------------------------------------------------------------
  static Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('[SqlApiService] signUp offline fallback: $e');
      return null;
    }
  }

  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('[SqlApiService] login offline fallback: $e');
      return null;
    }
  }

  // -------------------------------------------------------------
  // Hydration
  // -------------------------------------------------------------
  static Future<List<HydrationLog>?> getHydrationLogs(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/hydration/logs?userId=$userId'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => HydrationLog.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('[SqlApiService] getHydrationLogs note: $e');
      return null;
    }
  }

  static Future<bool> addHydrationLog(String userId, HydrationLog log) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/hydration/logs'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': log.id,
              'userId': userId,
              'amountMl': log.amountMl,
              'unit': log.unit,
              'timestamp': log.timestamp.toIso8601String(),
            }),
          )
          .timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[SqlApiService] addHydrationLog note: $e');
      return false;
    }
  }

  static Future<bool> saveHydrationGoal(String userId, HydrationGoal goal) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/hydration/goal'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'dailyTargetMl': goal.dailyTargetMl,
              'preferredUnit': goal.preferredUnit,
              'reminderIntervalMinutes': (goal.intervalHours * 60).round(),
            }),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[SqlApiService] saveHydrationGoal note: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // Custom Sounds
  // -------------------------------------------------------------
  static Future<bool> saveCustomSound(String userId, SoundTrack sound) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/sounds'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': sound.id,
              'userId': userId,
              'title': sound.title,
              'description': sound.description,
              'assetPath': sound.assetPath,
              'iconCode': sound.icon.codePoint,
              'category': sound.category,
            }),
          )
          .timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[SqlApiService] saveCustomSound note: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // Medications
  // -------------------------------------------------------------
  static Future<bool> saveMedications(String userId, List<MedicationItem> items) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/medications'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'items': items.map((m) => m.toJson()).toList(),
            }),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[SqlApiService] saveMedications note: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // Sleep Journal
  // -------------------------------------------------------------
  static Future<bool> logSleep(String userId, SleepLog log) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/sleep'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': log.id,
              'userId': userId,
              'date': log.date.toIso8601String(),
              'rating': log.rating.name,
              'previousDayWaterMl': log.previousDayWaterMl,
              'notes': log.notes,
            }),
          )
          .timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[SqlApiService] logSleep note: $e');
      return false;
    }
  }
}
