import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm_model.dart';
import '../models/sound_model.dart';
import '../repositories/alarm_repository.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import 'hydration_provider.dart';

import '../providers/audio_provider.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AlarmRepository(prefs);
});

class AlarmNotifier extends StateNotifier<AlarmModel> {
  final AlarmRepository _repository;
  final AudioServiceNotifier _audioNotifier;
  Timer? _previewTimer;
  Timer? _clockTicker;
  int? _lastRungMinute;
  bool _isPreviewing = false;
  double _previewVolume = 0.1;

  bool get isPreviewing => _isPreviewing;
  double get previewVolume => _previewVolume;

  AlarmNotifier(this._repository, this._audioNotifier) : super(_repository.getAlarm()) {
    NotificationService().scheduleGentleAlarm(state);
    _startClockTicker();
  }

  void _startClockTicker() {
    _clockTicker?.cancel();
    _clockTicker = Timer.periodic(const Duration(seconds: 5), (_) => _checkAlarmTrigger());
  }

  void _checkAlarmTrigger() {
    if (!state.isEnabled || state.isRinging || _isPreviewing) return;
    final now = DateTime.now();
    if (now.hour == state.hour && now.minute == state.minute) {
      if (_lastRungMinute != now.minute) {
        _lastRungMinute = now.minute;
        triggerAlarm();
      }
    }
  }

  /// Triggers the wake-up alarm sound in background/app with gentle volume fade-in
  Future<void> triggerAlarm([AudioServiceNotifier? overrideNotifier]) async {
    final audio = overrideNotifier ?? _audioNotifier;
    _isPreviewing = false;
    _previewTimer?.cancel();
    state = state.copyWith(isRinging: true);

    final track = SoundTrack.defaultTracks.firstWhere(
      (t) => t.id == state.soundId,
      orElse: () => SoundTrack.defaultTracks.first,
    );

    await audio.selectTrack(track);
    audio.setVolume(0.15);
    await audio.play();

    // Fade-in volume gradually from 0.15 to safe 0.75
    final totalSteps = (state.fadeInMinutes.clamp(1, 10)) * 6; // step every 5s
    int currentStep = 0;
    _previewTimer?.cancel();
    _previewTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!state.isRinging) {
        timer.cancel();
        return;
      }
      currentStep++;
      final targetVol = (0.15 + (0.60 * (currentStep / (totalSteps > 0 ? totalSteps : 1)))).clamp(0.15, 0.75);
      audio.setVolume(targetVol);
      if (currentStep >= totalSteps) {
        timer.cancel();
      }
    });
  }

  /// Turns off the alarm (stops the sound, clears ringing, turns off toggle)
  Future<void> turnOffAlarm([AudioServiceNotifier? overrideNotifier]) async {
    final audio = overrideNotifier ?? _audioNotifier;
    _previewTimer?.cancel();
    _isPreviewing = false;
    final updated = state.copyWith(isRinging: false, isEnabled: false);
    state = updated;
    await _repository.saveAlarm(updated);
    await audio.stop();
    audio.setVolume(0.6); // Reset default volume
    await NotificationService().scheduleGentleAlarm(updated);
  }

  /// Snoozes the alarm by specified minutes (default 5 mins)
  Future<void> snoozeAlarm({int minutes = 5, bool isSinhala = false, AudioServiceNotifier? overrideNotifier}) async {
    final audio = overrideNotifier ?? _audioNotifier;
    _previewTimer?.cancel();
    _isPreviewing = false;
    await audio.pause();
    audio.setVolume(0.6);

    final now = DateTime.now();
    final newTime = now.add(Duration(minutes: minutes));
    final updated = state.copyWith(
      isRinging: false,
      isEnabled: true,
      hour: newTime.hour,
      minute: newTime.minute,
    );
    state = updated;
    await _repository.saveAlarm(updated);
    await NotificationService().scheduleGentleAlarm(updated, isSinhala: isSinhala);
  }

  Future<void> toggleEnabled(bool enabled, {bool isSinhala = false}) async {
    final updated = state.copyWith(isEnabled: enabled, isRinging: enabled ? state.isRinging : false);
    state = updated;
    await _repository.saveAlarm(updated);
    await NotificationService().scheduleGentleAlarm(updated, isSinhala: isSinhala);
    if (!enabled && state.isRinging) {
      await turnOffAlarm();
    }
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
  Future<void> startPreview([AudioServiceNotifier? overrideNotifier]) async {
    final audio = overrideNotifier ?? _audioNotifier;
    _previewTimer?.cancel();
    _isPreviewing = true;
    _previewVolume = 0.1;

    final track = SoundTrack.defaultTracks.firstWhere(
      (t) => t.id == state.soundId,
      orElse: () => SoundTrack.defaultTracks.first,
    );

    await audio.selectTrack(track);
    audio.setVolume(0.1);
    await audio.play();

    // Gradually ramp volume from 0.1 to 0.7 every 1.5 seconds to demonstrate fade-in
    _previewTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isPreviewing) {
        timer.cancel();
        return;
      }
      if (_previewVolume < 0.75) {
        _previewVolume += 0.12;
        audio.setVolume(_previewVolume);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> stopPreview([AudioServiceNotifier? overrideNotifier]) async {
    final audio = overrideNotifier ?? _audioNotifier;
    _isPreviewing = false;
    _previewTimer?.cancel();
    await audio.pause();
    audio.setVolume(0.6); // Reset default volume
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    _previewTimer?.cancel();
    super.dispose();
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmModel>((ref) {
  final repo = ref.watch(alarmRepositoryProvider);
  final audio = ref.watch(audioServiceProvider);
  return AlarmNotifier(repo, audio);
});
