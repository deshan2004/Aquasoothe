import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_model.dart';
import '../repositories/medication_repository.dart';
import '../services/notification_service.dart';
import 'hydration_provider.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MedicationRepository(prefs);
});

class MedicationNotifier extends StateNotifier<List<MedicationItem>> {
  final MedicationRepository _repository;

  MedicationNotifier(this._repository) : super(_repository.getMedications()) {
    // Schedule initial medication reminders automatically
    NotificationService().scheduleMedicationReminders(state);
  }

  /// Marks the medication as taken and automatically logs 250ml water via HydrationNotifier
  Future<int?> takeMedication(String id, HydrationNotifier hydrationNotifier) async {
    final index = state.indexWhere((m) => m.id == id);
    if (index == -1) return null;

    final med = state[index];
    if (med.isTakenToday) return null; // Already taken today

    final updated = med.copyWith(
      isTakenToday: true,
      lastTakenDate: DateTime.now(),
    );

    final newList = List<MedicationItem>.from(state);
    newList[index] = updated;
    state = newList;

    await _repository.saveMedications(newList);

    // Automatically log water intake!
    await hydrationNotifier.logWater(med.waterMl);
    return med.waterMl;
  }

  Future<void> addMedication(MedicationItem item, {bool isSinhala = false}) async {
    final newList = [...state, item];
    state = newList;
    await _repository.saveMedications(newList);
    await NotificationService().scheduleMedicationReminders(newList, isSinhala: isSinhala);
  }

  Future<void> deleteMedication(String id, {bool isSinhala = false}) async {
    final newList = state.where((m) => m.id != id).toList();
    state = newList;
    await _repository.saveMedications(newList);
    await NotificationService().scheduleMedicationReminders(newList, isSinhala: isSinhala);
  }

  Future<void> resetAllForTesting({bool isSinhala = false}) async {
    final newList = state.map((m) => m.copyWith(isTakenToday: false)).toList();
    state = newList;
    await _repository.saveMedications(newList);
    await NotificationService().scheduleMedicationReminders(newList, isSinhala: isSinhala);
  }

  Future<void> syncNotifications({bool isSinhala = false}) async {
    await NotificationService().scheduleMedicationReminders(state, isSinhala: isSinhala);
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, List<MedicationItem>>((ref) {
  final repo = ref.watch(medicationRepositoryProvider);
  return MedicationNotifier(repo);
});
