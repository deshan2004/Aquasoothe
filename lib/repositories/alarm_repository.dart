import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';

class AlarmRepository {
  static const String _key = 'aquasoothe_nature_alarm_v1';
  final SharedPreferences _prefs;

  AlarmRepository(this._prefs);

  AlarmModel getAlarm() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const AlarmModel();
    }
    try {
      return AlarmModel.fromJson(jsonDecode(raw));
    } catch (_) {
      return const AlarmModel();
    }
  }

  Future<void> saveAlarm(AlarmModel alarm) async {
    await _prefs.setString(_key, jsonEncode(alarm.toJson()));
  }
}
