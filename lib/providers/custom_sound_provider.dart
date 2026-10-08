import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../repositories/custom_sound_repository.dart';
import 'hydration_provider.dart';

final customSoundRepositoryProvider = Provider<CustomSoundRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CustomSoundRepository(prefs);
});

class CustomSoundNotifier extends StateNotifier<List<SoundTrack>> {
  final CustomSoundRepository _repository;

  CustomSoundNotifier(this._repository) : super(_repository.getCustomSounds());

  Future<void> saveCustomSound(SoundTrack sound) async {
    await _repository.saveCustomSound(sound);
    state = _repository.getCustomSounds();
  }

  Future<void> deleteCustomSound(String id) async {
    await _repository.deleteCustomSound(id);
    state = _repository.getCustomSounds();
  }
}

final customSoundProvider = StateNotifierProvider<CustomSoundNotifier, List<SoundTrack>>((ref) {
  final repo = ref.watch(customSoundRepositoryProvider);
  return CustomSoundNotifier(repo);
});
