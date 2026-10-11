import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_model.dart';

class MedicationRepository {
  static const String _key = 'aquasoothe_medications_v1';
  final SharedPreferences _prefs;

  MedicationRepository(this._prefs);

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
  }
}
