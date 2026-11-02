import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';

class AlarmRepository {
  final SharedPreferences _prefs;
  final String _userKey;

  fb_auth.FirebaseAuth get _firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  AlarmRepository(this._prefs, {this._userKey = 'guest_'});

  String get _key => '${_userKey}nature_alarm_v1';

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

    // Sync with Firestore if user is authenticated
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('alarms')
            .doc('current')
            .set({
              ...alarm.toJson(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (_) {}
  }
}
