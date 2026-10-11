import 'package:flutter/services.dart';
import '../models/sound_model.dart';
import '../providers/hydration_provider.dart';
import 'audio_service.dart';

enum VoiceActionType {
  logWater,
  playSound,
  pauseSound,
  resumeSound,
  bedtimeMode,
  checkStatus,
  unknown,
}

class VoiceCommandResult {
  final bool success;
  final VoiceActionType actionType;
  final String recognizedText;
  final String feedbackMessageEn;
  final String feedbackMessageSi;
  final int? waterAmountMl;
  final String? trackTitle;

  const VoiceCommandResult({
    required this.success,
    required this.actionType,
    required this.recognizedText,
    required this.feedbackMessageEn,
    required this.feedbackMessageSi,
    this.waterAmountMl,
    this.trackTitle,
  });
}

class VoiceCommandService {
  /// Parses spoken or typed text and executes the corresponding action
  /// using the provided HydrationNotifier and AudioServiceNotifier.
  static Future<VoiceCommandResult> processCommand({
    required String input,
    required HydrationNotifier hydrationNotifier,
    required HydrationState hydrationState,
    required AudioServiceNotifier audioNotifier,
  }) async {
    final text = input.trim();
    final lower = text.toLowerCase();

    // Trigger subtle haptic feedback for command recognition
    HapticFeedback.mediumImpact();

    // 1. Water Intake Logging
    if (_isWaterCommand(lower)) {
      final amount = _extractWaterAmount(lower);
      await hydrationNotifier.logWater(amount);

      final newTotal = hydrationState.todayTotalMl + amount;
      final target = hydrationState.goal.dailyTargetMl;

      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.logWater,
        recognizedText: text,
        waterAmountMl: amount,
        feedbackMessageEn: '💧 Logged ${amount}ml of water! Total: $newTotal/${target}ml',
        feedbackMessageSi: '💧 වතුර මිලිලීටර් $amountක් සටහන් කළා! එකතුව: $newTotal/${target}ml',
      );
    }

    // 2. Pause / Stop Audio
    if (_isStopCommand(lower)) {
      await audioNotifier.pause();
      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.pauseSound,
        recognizedText: text,
        feedbackMessageEn: '⏸️ Soundscape paused. Enjoy your peace & quiet.',
        feedbackMessageSi: '⏸️ ශබ්දය නතර කරන ලදී. සන්සුන්ව සිටින්න.',
      );
    }

    // 3. Resume / Unpause Audio
    if (_isResumeCommand(lower)) {
      await audioNotifier.play();
      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.resumeSound,
        recognizedText: text,
        trackTitle: audioNotifier.currentTrack.title,
        feedbackMessageEn: '▶️ Resumed playing "${audioNotifier.currentTrack.title}".',
        feedbackMessageSi: '▶️ "${audioNotifier.currentTrack.title}" නැවත වාදනය වේ.',
      );
    }

    // 4. Bedtime / Deep Sleep Mode
    if (_isBedtimeCommand(lower)) {
      final nightTrack = SoundTrack.defaultTracks.firstWhere(
        (t) => t.id == 'rainfall' || t.id == 'ocean',
        orElse: () => SoundTrack.defaultTracks.first,
      );
      await audioNotifier.selectTrack(nightTrack);
      await audioNotifier.play();
      audioNotifier.setTimerPreset(SleepTimerPreset.min30);

      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.bedtimeMode,
        recognizedText: text,
        trackTitle: nightTrack.title,
        feedbackMessageEn: '🌙 Bedtime Mode activated: Playing "${nightTrack.title}" with a 30-min auto-off timer.',
        feedbackMessageSi: '🌙 නිදන මාදිලිය සක්‍රියයි: විනාඩි 30ක ස්වයංක්‍රීය ටයිමරය සමග "${nightTrack.title}" වාදනය වේ.',
      );
    }

    // 5. Play Specific Sound Tracks
    final matchingTrack = _findMatchingTrack(lower);
    if (matchingTrack != null) {
      await audioNotifier.selectTrack(matchingTrack);
      await audioNotifier.play();
      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.playSound,
        recognizedText: text,
        trackTitle: matchingTrack.title,
        feedbackMessageEn: '🌧️ Now playing "${matchingTrack.title}".',
        feedbackMessageSi: '🌧️ "${matchingTrack.title}" වාදනය ආරම්භ කළා.',
      );
    }

    // 6. Check Hydration Status
    if (_isStatusCommand(lower)) {
      final total = hydrationState.todayTotalMl;
      final target = hydrationState.goal.dailyTargetMl;
      final percent = ((total / target) * 100).toInt();

      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.checkStatus,
        recognizedText: text,
        feedbackMessageEn: '📊 Today: ${total}ml of ${target}ml logged ($percent% completed).',
        feedbackMessageSi: '📊 අද දින: ඉලක්කය ${target}ml න් ${total}ml ($percent%) ක් සම්පූර්ණයි.',
      );
    }

    // Unknown Command
    return VoiceCommandResult(
      success: false,
      actionType: VoiceActionType.unknown,
      recognizedText: text,
      feedbackMessageEn: 'I didn\'t quite catch that. Try saying "Log 250ml water" or "Play rainfall".',
      feedbackMessageSi: 'කරුණාකර නැවත උත්සාහ කරන්න: "Log 250ml water" හෝ "Play rain sounds" පවසා බලන්න.',
    );
  }

  static bool _isWaterCommand(String text) {
    final waterKeywords = [
      'water', 'drink', 'drank', 'cup', 'glass', 'bottle', 'ml', 'hydration',
      'wathura', 'biwwa', 'bonna', 'beewa',
      'වතුර', 'බිව්වා', 'වීදුරුව', 'බෝතලය', 'බොන්න'
    ];
    return waterKeywords.any((k) => text.contains(k));
  }

  static int _extractWaterAmount(String text) {
    // Look for explicit numbers (e.g. "250", "500", "750", "1000")
    final match = RegExp(r'\b(\d{2,4})\b').firstMatch(text);
    if (match != null) {
      final parsed = int.tryParse(match.group(1)!);
      if (parsed != null && parsed >= 50 && parsed <= 3000) {
        return parsed;
      }
    }

    // Check for bottle vs glass keywords
    if (text.contains('bottle') || text.contains('bothal') || text.contains('බෝතල')) {
      return 500;
    }
    if (text.contains('big') || text.contains('loku') || text.contains('ලොකු')) {
      return 500;
    }

    // Default senior-friendly cup size: 250 ml
    return 250;
  }

  static bool _isStopCommand(String text) {
    final stopKeywords = [
      'stop', 'pause', 'quiet', 'mute', 'off', 'silence', 'halt',
      'navaththanna', 'nawaththanna', 'navathanna', 'nawathanna',
      'නවත්තන්න', 'නිහඬ', 'නතර'
    ];
    return stopKeywords.any((k) => text.contains(k));
  }

  static bool _isResumeCommand(String text) {
    final resumeKeywords = [
      'resume', 'unpause', 'continue', 'start sound', 'play again',
      'danna', 'navatha danna', 'නැවත'
    ];
    return resumeKeywords.any((k) => text.contains(k));
  }

  static bool _isBedtimeCommand(String text) {
    final bedtimeKeywords = [
      'bedtime', 'sleep', 'sleepy', 'good night', 'goodnight', 'relax',
      'ninda', 'nidaganna', 'nida ganna', 'නිදාගන්න', 'නින්ද', 'සුභ රාත්‍රියක්'
    ];
    return bedtimeKeywords.any((k) => text.contains(k));
  }

  static bool _isStatusCommand(String text) {
    final statusKeywords = [
      'status', 'how much', 'progress', 'goal', 'summary',
      'keeyada', 'wathura keeyada', 'ප්‍රගතිය', 'කොච්චර'
    ];
    return statusKeywords.any((k) => text.contains(k));
  }

  static SoundTrack? _findMatchingTrack(String text) {
    // Rain
    if (text.contains('rain') || text.contains('rainfall') || text.contains('wassa') || text.contains('wahi') || text.contains('වැස්ස') || text.contains('වැසි')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'rainfall', orElse: () => SoundTrack.defaultTracks[2]);
    }
    // Ocean
    if (text.contains('ocean') || text.contains('sea') || text.contains('wave') || text.contains('muhuda') || text.contains('rala') || text.contains('මුහුද') || text.contains('රළ')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'ocean', orElse: () => SoundTrack.defaultTracks[1]);
    }
    // Waterfall
    if (text.contains('waterfall') || text.contains('falls') || text.contains('stream') || text.contains('diya alla') || text.contains('දිය ඇල්ල')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'waterfall', orElse: () => SoundTrack.defaultTracks[0]);
    }
    // Pink noise
    if (text.contains('pink') || text.contains('pink noise')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'pink_noise', orElse: () => SoundTrack.defaultTracks[3]);
    }
    // Brown noise
    if (text.contains('brown') || text.contains('brown noise') || text.contains('deep noise')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'brown_noise', orElse: () => SoundTrack.defaultTracks[4]);
    }
    // Generic "play sound"
    if (text.contains('play') || text.contains('sound') || text.contains('music') || text.contains('සද්දෙ') || text.contains('වාදනය')) {
      return SoundTrack.defaultTracks[2]; // Default to Rainfall
    }
    return null;
  }
}
