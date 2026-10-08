import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/sound_model.dart';

enum SleepTimerPreset {
  min15(15, '15 Minutes'),
  min30(30, '30 Minutes'),
  min45(45, '45 Minutes'),
  min60(60, '60 Minutes'),
  allNight(0, 'All Night (No Timer)');

  final int minutes;
  final String label;
  const SleepTimerPreset(this.minutes, this.label);
}

class AudioServiceNotifier extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _secondaryPlayer = AudioPlayer();

  SoundTrack _currentTrack = SoundTrack.defaultTracks[2]; // Default: Rainfall
  SoundTrack? _secondaryTrack; // Secondary layered track (optional)

  bool _isPlaying = false;
  double _volume = 0.6; // Primary volume 60%
  double _secondaryVolume = 0.4; // Secondary volume 40%
  static const double maxSafeVolume = 0.8; // Safe hard cap (80%)

  bool _isMixerEnabled = false;
  SleepTimerPreset _selectedPreset = SleepTimerPreset.min30;
  Timer? _countdownTimer;
  Timer? _fadeOutTimer;
  int _secondsRemaining = 0;
  bool _isFadingOut = false;

  AudioPlayer get player => _player;
  AudioPlayer get secondaryPlayer => _secondaryPlayer;

  SoundTrack get currentTrack => _currentTrack;
  SoundTrack? get secondaryTrack => _secondaryTrack;

  bool get isPlaying => _isPlaying;
  bool get isMixerEnabled => _isMixerEnabled;

  double get volume => _volume;
  double get secondaryVolume => _secondaryVolume;

  SleepTimerPreset get selectedPreset => _selectedPreset;
  int get secondsRemaining => _secondsRemaining;
  bool get isFadingOut => _isFadingOut;

  AudioServiceNotifier() {
    _initAudioSession();
    _initPlayerListeners();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint("AudioSession setup notice: $e");
    }
  }

  void _initPlayerListeners() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  Future<void> selectTrack(SoundTrack track) async {
    final wasPlaying = _isPlaying;
    _currentTrack = track;
    notifyListeners();

    try {
      await _player.setAsset(track.assetPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(_volume);

      if (wasPlaying) {
        await play();
      }
    } catch (e) {
      debugPrint("Error loading primary audio asset ${track.assetPath}: $e");
    }
  }

  Future<void> selectSecondaryTrack(SoundTrack? track) async {
    _secondaryTrack = track;
    notifyListeners();

    if (track == null) {
      await _secondaryPlayer.stop();
      return;
    }

    try {
      await _secondaryPlayer.setAsset(track.assetPath);
      await _secondaryPlayer.setLoopMode(LoopMode.one);
      await _secondaryPlayer.setVolume(_secondaryVolume);

      if (_isPlaying && _isMixerEnabled) {
        await _secondaryPlayer.play();
      }
    } catch (e) {
      debugPrint("Error loading secondary audio asset ${track.assetPath}: $e");
    }
  }

  void toggleMixer(bool enabled) {
    _isMixerEnabled = enabled;
    if (!enabled) {
      _secondaryPlayer.stop();
    } else if (_isPlaying && _secondaryTrack != null) {
      _secondaryPlayer.play();
    }
    notifyListeners();
  }

  Future<void> play() async {
    try {
      if (_player.audioSource == null) {
        await _player.setAsset(_currentTrack.assetPath);
        await _player.setLoopMode(LoopMode.one);
      }
      await _player.setVolume(_volume);
      await _player.play();

      if (_isMixerEnabled && _secondaryTrack != null) {
        if (_secondaryPlayer.audioSource == null) {
          await _secondaryPlayer.setAsset(_secondaryTrack!.assetPath);
          await _secondaryPlayer.setLoopMode(LoopMode.one);
        }
        await _secondaryPlayer.setVolume(_secondaryVolume);
        await _secondaryPlayer.play();
      }

      _startSleepTimer();
      notifyListeners();
    } catch (e) {
      debugPrint("Error starting audio playback: $e");
    }
  }

  Future<void> pause() async {
    _cancelTimers();
    await _player.pause();
    await _secondaryPlayer.pause();
    notifyListeners();
  }

  Future<void> stop() async {
    _cancelTimers();
    await _player.stop();
    await _secondaryPlayer.stop();
    notifyListeners();
  }

  void setVolume(double newVol) {
    final safeVol = newVol.clamp(0.0, maxSafeVolume);
    _volume = safeVol;
    if (!_isFadingOut) {
      _player.setVolume(_volume);
    }
    notifyListeners();
  }

  void setSecondaryVolume(double newVol) {
    final safeVol = newVol.clamp(0.0, maxSafeVolume);
    _secondaryVolume = safeVol;
    if (!_isFadingOut) {
      _secondaryPlayer.setVolume(_secondaryVolume);
    }
    notifyListeners();
  }

  void setTimerPreset(SleepTimerPreset preset) {
    _selectedPreset = preset;
    if (_isPlaying) {
      _startSleepTimer();
    } else {
      _secondsRemaining = preset.minutes * 60;
    }
    notifyListeners();
  }

  void _startSleepTimer() {
    _cancelTimers();
    _isFadingOut = false;

    if (_selectedPreset == SleepTimerPreset.allNight || _selectedPreset.minutes == 0) {
      _secondsRemaining = 0;
      return;
    }

    _secondsRemaining = _selectedPreset.minutes * 60;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;

        if (_secondsRemaining <= 30 && !_isFadingOut) {
          _startFadeOut();
        }

        notifyListeners();
      } else {
        _cancelTimers();
        stop();
      }
    });
  }

  void _startFadeOut() {
    _isFadingOut = true;
    final initialVol = _volume;
    final initialSecVol = _secondaryVolume;
    int stepCount = 0;
    const totalSteps = 60; // 30 seconds

    _fadeOutTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      stepCount++;
      final progress = stepCount / totalSteps;
      
      final currentVol = (initialVol * (1.0 - progress)).clamp(0.0, initialVol);
      final currentSecVol = (initialSecVol * (1.0 - progress)).clamp(0.0, initialSecVol);
      
      _player.setVolume(currentVol);
      _secondaryPlayer.setVolume(currentSecVol);

      if (stepCount >= totalSteps) {
        timer.cancel();
      }
    });
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _fadeOutTimer?.cancel();
    _fadeOutTimer = null;
    _isFadingOut = false;
  }

  @override
  void dispose() {
    _cancelTimers();
    _player.dispose();
    _secondaryPlayer.dispose();
    super.dispose();
  }
}
