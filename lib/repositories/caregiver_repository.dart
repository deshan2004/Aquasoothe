import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/caregiver_model.dart';

class CaregiverRepository {
  static const String _caregiverKey = 'aquasoothe_caregiver_settings_v1';
  final SharedPreferences _prefs;

  CaregiverRepository(this._prefs);

  CaregiverSettings getSettings() {
    final rawJson = _prefs.getString(_caregiverKey);
    if (rawJson == null || rawJson.isEmpty) {
      return CaregiverSettings();
    }
    try {
      return CaregiverSettings.fromJson(jsonDecode(rawJson));
    } catch (_) {
      return CaregiverSettings();
    }
  }

  Future<void> saveSettings(CaregiverSettings settings) async {
    await _prefs.setString(_caregiverKey, jsonEncode(settings.toJson()));
    
    // TODO: Backend Integration (e.g., Firebase Firestore / Supabase REST API)
    // If settings.isEnabled is true, upload/sync caregiver pairing token and alert rules:
    // await FirebaseFirestore.instance.collection('caregiver_pairs').doc(settings.inviteCode).set({
    //   'userId': currentUser.uid,
    //   'caregiverName': settings.caregiverName,
    //   'cutoffHour': settings.cutoffHour,
    //   'cutoffMinute': settings.cutoffMinute,
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });
  }

  /// Syncs daily hydration and sleep sound status with caregiver cloud backend
  Future<void> syncStatusWithCaregiver({
    required int todayIntakeMl,
    required int goalMl,
    required String? lastSleepSessionSummary,
  }) async {
    final settings = getSettings();
    if (!settings.isEnabled) return;

    final updated = settings.copyWith(lastSyncedAt: DateTime.now());
    await saveSettings(updated);

    // TODO: Remote Caregiver Cloud Sync
    // Example Cloud Function / Firestore Push:
    // await FirebaseFirestore.instance.collection('caregiver_feeds').doc(settings.inviteCode).update({
    //   'todayIntakeMl': todayIntakeMl,
    //   'goalMl': goalMl,
    //   'goalMet': todayIntakeMl >= goalMl,
    //   'lastSleepSession': lastSleepSessionSummary,
    //   'lastUpdated': FieldValue.serverTimestamp(),
    // });
  }
}
