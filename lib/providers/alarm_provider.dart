import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm_model.dart';
import '../models/sound_model.dart';
import '../repositories/alarm_repository.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import 'hydration_provider.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AlarmRepository(prefs);
});

class AlarmNotifier extends StateNotifier<AlarmModel> {
  final AlarmRepository _repository;
  Timer? _previewTimer;
  bool _isPreviewing = false;
  double _previewVolume = 0.1;

  bool get isPreviewing => _isPreviewing;
  double get previewVolume => _previewVolume;

  AlarmNotifier(this._repository) : super(_repository.getAlarm()) {
    NotificationService().scheduleGentleAlarm(state);
  }

  Future<void> toggleEnabled(bool enabled, {bool isSinhala = false}) async {
    final updated = state.copyWith(isEnabled: enabled);
    state = updated;
    await _repository.saveAlarm(updated);
    await NotificationService().scheduleGentleAlarm(updated, isSinhala: isSinhala);
  }

  Future<void> toggleAlarm(bool enabled, {bool isSinhala = false}) =>
      toggleEnabled(enabled, isSinhala: isSinhala);

  Future<void> setTime(TimeOfDay time, {bool isSinhala = false}) async {
    final updated = state.copyWith(hour: time.hour, minute: time.minute);
    state = updated;
    await _repository.saveAlarm(updated);
    await NotificationService().scheduleGentleAlarm(updated, isSinhala: isSinhala);
  }

  Future<void> setSound(String soundId) async {
    final updated = state.copyWith(soundId: soundId);
    state = updated;
    await _repository.saveAlarm(updated);
  }

  Future<void> setFadeInMinutes(int minutes) async {
    final updated = state.copyWith(fadeInMinutes: minutes);
    state = updated;
    await _repository.saveAlarm(updated);
  }

  /// Demonstrates the gradual progressive volume fade-in
  Future<void> startPreview(AudioServiceNotifier audioNotifier) async {
    _previewTimer?.cancel();
    _isPreviewing = true;
    _previewVolume = 0.1;

    final track = SoundTrack.defaultTracks.firstWhere(
      (t) => t.id == state.soundId,
      orElse: () => SoundTrack.defaultTracks.first,
    );

    await audioNotifier.selectTrack(track);
    audioNotifier.setVolume(0.1);
    await audioNotifier.play();

    // Gradually ramp volume from 0.1 to 0.7 every 1.5 seconds to demonstrate fade-in
    _previewTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isPreviewing) {
        timer.cancel();
        return;
      }
      if (_previewVolume < 0.75) {
        _previewVolume += 0.12;
        audioNotifier.setVolume(_previewVolume);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> stopPreview(AudioServiceNotifier audioNotifier) async {
    _isPreviewing = false;
    _previewTimer?.cancel();
    await audioNotifier.pause();
    audioNotifier.setVolume(0.6); // Reset default volume
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmModel>((ref) {
  final repo = ref.watch(alarmRepositoryProvider);
  return AlarmNotifier(repo);
});
