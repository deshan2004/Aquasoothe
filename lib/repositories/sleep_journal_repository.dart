import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_journal_model.dart';

class SleepJournalRepository {
  static const String _sleepLogsKey = 'aquasoothe_sleep_journal_logs_v1';
  final SharedPreferences _prefs;
  fb_auth.FirebaseAuth get _firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  SleepJournalRepository(this._prefs);

  List<SleepLog> getLogs() {
    final rawJson = _prefs.getString(_sleepLogsKey);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((e) => SleepLog.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> logSleep(SleepLog log) async {
    final logs = getLogs();
    logs.removeWhere((element) =>
        element.date.year == log.date.year &&
        element.date.month == log.date.month &&
        element.date.day == log.date.day);
    logs.insert(0, log);
    await _prefs.setString(_sleepLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));

    // Firestore sync
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('sleep_journals')
            .doc(log.id)
            .set(log.toJson());
      }
    } catch (_) {}
  }

  SleepLog? getTodayLog() {
    final logs = getLogs();
    final now = DateTime.now();
    for (final l in logs) {
      if (l.date.year == now.year && l.date.month == now.month && l.date.day == now.day) {
        return l;
      }
    }
    return null;
  }
}
