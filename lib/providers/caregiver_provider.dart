import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/caregiver_model.dart';
import '../repositories/caregiver_repository.dart';
import 'hydration_provider.dart';

final caregiverRepositoryProvider = Provider<CaregiverRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CaregiverRepository(prefs);
});

class CaregiverNotifier extends StateNotifier<CaregiverSettings> {
  final CaregiverRepository _repository;

  CaregiverNotifier(this._repository) : super(_repository.getSettings());

  Future<void> toggleEnabled(bool enabled) async {
    final updated = state.copyWith(isEnabled: enabled);
    await _repository.saveSettings(updated);
    state = updated;
  }

  Future<void> updateCaregiverName(String name) async {
    final updated = state.copyWith(caregiverName: name);
    await _repository.saveSettings(updated);
    state = updated;
  }

  Future<void> updateCutoffTime(int hour, int minute) async {
    final updated = state.copyWith(cutoffHour: hour, cutoffMinute: minute);
    await _repository.saveSettings(updated);
    state = updated;
  }

  Future<void> generateNewInviteCode() async {
    final randomNum = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    final newCode = 'AQUA-$randomNum';
    final updated = state.copyWith(inviteCode: newCode);
    await _repository.saveSettings(updated);
    state = updated;
  }
}

final caregiverProvider = StateNotifierProvider<CaregiverNotifier, CaregiverSettings>((ref) {
  final repo = ref.watch(caregiverRepositoryProvider);
  return CaregiverNotifier(repo);
});
