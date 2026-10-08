import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hydration_model.dart';

class HydrationRepository {
  static const String _logsKey = 'aquasoothe_hydration_logs_v1';
  static const String _goalKey = 'aquasoothe_hydration_goal_v1';

  final SharedPreferences _prefs;
  fb_auth.FirebaseAuth get _firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  HydrationRepository(this._prefs);

  List<HydrationLog> getLogs() {
    final rawJson = _prefs.getString(_logsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((e) => HydrationLog.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addLog(HydrationLog log) async {
    final logs = getLogs();
    logs.insert(0, log); // Newest first
    await _prefs.setString(_logsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));

    // Sync with Firestore if user is authenticated
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('hydration_logs')
            .doc(log.id)
            .set(log.toJson());
      }
    } catch (_) {}
  }

  Future<void> clearLogs() async {
    await _prefs.remove(_logsKey);
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        final snapshots = await _firestore
            .collection('users')
            .doc(uid)
            .collection('hydration_logs')
            .get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
      }
    } catch (_) {}
  }

  HydrationGoal getGoal() {
    final rawJson = _prefs.getString(_goalKey);
    if (rawJson == null || rawJson.isEmpty) {
      return HydrationGoal();
    }
    try {
      return HydrationGoal.fromJson(jsonDecode(rawJson));
    } catch (_) {
      return HydrationGoal();
    }
  }

  Future<void> saveGoal(HydrationGoal goal) async {
    await _prefs.setString(_goalKey, jsonEncode(goal.toJson()));
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .set({'hydration_goal': goal.toJson()}, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  /// Calculates total ml consumed today
  int getTodayTotalMl() {
    final logs = getLogs();
    final now = DateTime.now();
    int total = 0;
    for (final log in logs) {
      if (log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day) {
        total += log.amountMl;
      }
    }
    return total;
  }

  /// Calculates past 7 days hydration totals per day
  Map<DateTime, int> getPast7DaysTotals() {
    final logs = getLogs();
    final now = DateTime.now();
    final Map<DateTime, int> totals = {};

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      totals[day] = 0;
    }

    for (final log in logs) {
      final logDay = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (totals.containsKey(logDay)) {
        totals[logDay] = (totals[logDay] ?? 0) + log.amountMl;
      }
    }

    return totals;
  }
}
