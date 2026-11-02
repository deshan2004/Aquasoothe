import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_model.dart';

class MedicationRepository {
  final SharedPreferences _prefs;
  final String _userKey;

  fb_auth.FirebaseAuth get _firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  MedicationRepository(this._prefs, {this._userKey = 'guest_'});

  String get _key => '${_userKey}medications_v1';

  List<MedicationItem> getMedications() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return MedicationItem.defaultSeniorMedications();
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      final now = DateTime.now();

      return decoded.map((item) {
        final med = MedicationItem.fromJson(item as Map<String, dynamic>);
        // Check if last taken date was today. If not, reset isTakenToday to false!
        if (med.lastTakenDate != null) {
          final isSameDay = med.lastTakenDate!.year == now.year &&
              med.lastTakenDate!.month == now.month &&
              med.lastTakenDate!.day == now.day;
          if (!isSameDay) {
            return med.copyWith(isTakenToday: false);
          }
        }
        return med;
      }).toList();
    } catch (_) {
      return MedicationItem.defaultSeniorMedications();
    }
  }

  Future<void> saveMedications(List<MedicationItem> items) async {
    final encoded = jsonEncode(items.map((m) => m.toJson()).toList());
    await _prefs.setString(_key, encoded);

    // Sync with Firestore if user is authenticated
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('medications')
            .doc('current')
            .set({
              'updatedAt': FieldValue.serverTimestamp(),
              'items': items.map((m) => m.toJson()).toList(),
            }, SetOptions(merge: true));
      }
    } catch (_) {}
  }
}
