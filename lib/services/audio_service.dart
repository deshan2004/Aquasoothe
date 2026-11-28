import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../models/sound_model.dart';

enum SleepTimerPreset {
  min15(15, '15 Minutes'),
  min30(30, '30 Minutes'),
  min45(45, '45 Minutes'),
  min60(60, '60 Minutes'),
  custom(-1, 'Custom'),
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
  int _customTimerMinutes = 20;
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
  int get customTimerMinutes => _customTimerMinutes;
  int get secondsRemaining => _secondsRemaining;
  bool get isFadingOut => _isFadingOut;

  String get formattedTimeRemaining {
    if (_selectedPreset == SleepTimerPreset.allNight || _secondsRemaining <= 0) {
      return 'Off';
    }
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

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
      final wasPlaying = _isPlaying;
      _isPlaying = state.playing;
      if (wasPlaying && !_isPlaying) {
        if (_secondaryPlayer.playing) {
          _secondaryPlayer.pause();
        }
      } else if (!wasPlaying && _isPlaying) {
        if (_isMixerEnabled && _secondaryTrack != null && !_secondaryPlayer.playing) {
          _secondaryPlayer.play();
        }
      }
      notifyListeners();
    });
  }

  static const Map<String, String> _soundArtCovers = {
    'rainfall': 'https://images.unsplash.com/photo-1519692933481-e162a57d6721?w=800&auto=format&fit=crop&q=80',
    'ocean': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    'waterfall': 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=800&auto=format&fit=crop&q=80',
    'forest': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&auto=format&fit=crop&q=80',
    'crickets': 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=800&auto=format&fit=crop&q=80',
    'pink_noise': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
    'brown_noise': 'https://images.unsplash.com/photo-1509114397022-ed747cca3f65?w=800&auto=format&fit=crop&q=80',
  };

  Uri _resolveArtworkForTrack(SoundTrack track) {
    final onlineCover = _soundArtCovers[track.id];
    if (onlineCover != null) {
      return Uri.parse(onlineCover);
    }
    if (track.category == 'AI Personalized' || track.id.startsWith('ai_bespoke_')) {
      return Uri.parse('https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&auto=format&fit=crop&q=80');
    }
    if (track.category == 'User Custom' || track.id.startsWith('user_sound_')) {
      return Uri.parse('https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80');
    }
    return Uri.parse('asset:///assets/images/weather_banner.jpg');
  }

  AudioSource _buildAudioSource(SoundTrack track) {
    final artUri = _resolveArtworkForTrack(track);
    final artistLabel = _isMixerEnabled && _secondaryTrack != null
        ? 'AquaSoothe • Blended with ${_secondaryTrack!.title}'
        : (track.category == 'AI Personalized'
            ? 'AquaSoothe AI • Prescribed Sleep Therapy'
            : 'AquaSoothe • Nature Sound Therapy');

    final albumLabel = track.description.isNotEmpty
        ? track.description
        : 'Restorative Neuro-Acoustic Loop';

    final mediaItem = MediaItem(
      id: track.id,
      album: albumLabel,
      title: track.title,
      artist: artistLabel,
      genre: 'Circadian Sleep Sanctuary',
      artUri: artUri,
      displayTitle: track.title,
      displaySubtitle: artistLabel,
      displayDescription: albumLabel,
      duration: Duration(minutes: _secondsRemaining > 0 ? (_secondsRemaining / 60).ceil() : 45),
    );

    if (track.assetPath.startsWith('http://') || track.assetPath.startsWith('https://')) {
      return AudioSource.uri(Uri.parse(track.assetPath), tag: mediaItem);
    } else if (track.assetPath.startsWith('assets/')) {
      return AudioSource.asset(track.assetPath, tag: mediaItem);
    } else {
      return AudioSource.file(track.assetPath, tag: mediaItem);
    }
  }

  Future<void> _setSourceForPlayer(SoundTrack track) async {
    final source = _buildAudioSource(track);
    await _player.setAudioSource(source);
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(_volume);
  }

  Future<void> _setSecondarySource(SoundTrack track) async {
    if (track.assetPath.startsWith('http://') || track.assetPath.startsWith('https://')) {
      await _secondaryPlayer.setAudioSource(AudioSource.uri(Uri.parse(track.assetPath)));
    } else if (track.assetPath.startsWith('assets/')) {
      await _secondaryPlayer.setAudioSource(AudioSource.asset(track.assetPath));
    } else {
      await _secondaryPlayer.setAudioSource(AudioSource.file(track.assetPath));
    }
    await _secondaryPlayer.setLoopMode(LoopMode.one);
    await _secondaryPlayer.setVolume(_secondaryVolume);
  }

  Future<void> selectTrack(SoundTrack track) async {
    final wasPlaying = _isPlaying;
    _currentTrack = track;
    notifyListeners();

    try {
      await _setSourceForPlayer(track);

      if (wasPlaying) {
        await play();
      }
    } catch (e) {
      debugPrint("Error loading primary audio source ${track.assetPath}: $e");
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
      await _setSecondarySource(track);

      if (_isPlaying && _isMixerEnabled) {
        await _secondaryPlayer.play();
      }
    } catch (e) {
      debugPrint("Error loading secondary audio source ${track.assetPath}: $e");
    }
  }

  Future<void> toggleMixer(bool enabled) async {
    _isMixerEnabled = enabled;
    if (!enabled) {
      await _secondaryPlayer.stop();
    } else if (_isPlaying && _secondaryTrack != null) {
      try {
        if (_secondaryPlayer.audioSource == null) {
          await _setSecondarySource(_secondaryTrack!);
        }
        await _secondaryPlayer.setVolume(_secondaryVolume);
        await _secondaryPlayer.play();
      } catch (e) {
        debugPrint("Error playing secondary track in mixer: $e");
      }
    }
    notifyListeners();
  }

  Future<void> play() async {
    try {
      if (_player.audioSource == null) {
        await _setSourceForPlayer(_currentTrack);
      }
      await _player.setVolume(_volume);
      await _player.play();

      if (_isMixerEnabled && _secondaryTrack != null) {
        if (_secondaryPlayer.audioSource == null) {
          await _setSecondarySource(_secondaryTrack!);
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
      final totalMins = preset == SleepTimerPreset.custom ? _customTimerMinutes : preset.minutes;
      _secondsRemaining = totalMins > 0 ? totalMins * 60 : 0;
    }
    notifyListeners();
  }

  void setCustomMinutes(int minutes) {
    if (minutes <= 0) return;
    _customTimerMinutes = minutes;
    _selectedPreset = SleepTimerPreset.custom;
    if (_isPlaying) {
      _startSleepTimer();
    } else {
      _secondsRemaining = minutes * 60;
    }
    notifyListeners();
  }

  void _startSleepTimer() {
    _cancelTimers();
    _isFadingOut = false;

    final totalMins = _selectedPreset == SleepTimerPreset.custom
        ? _customTimerMinutes
        : _selectedPreset.minutes;

    if (_selectedPreset == SleepTimerPreset.allNight || totalMins <= 0) {
      _secondsRemaining = 0;
      return;
    }

    _secondsRemaining = totalMins * 60;

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
