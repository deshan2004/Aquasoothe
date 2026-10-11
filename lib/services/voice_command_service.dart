import 'package:flutter/services.dart';
import '../models/sound_model.dart';
import '../models/medication_model.dart';
import '../models/weather_hydration_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/medication_provider.dart';
import 'audio_service.dart';

enum VoiceActionType {
  logWater,
  playSound,
  pauseSound,
  resumeSound,
  bedtimeMode,
  breathingExercise,
  checkStatus,
  medication,
  gentleAlarm,
  weatherHydration,
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
  static Future<VoiceCommandResult> processCommand({
    required String input,
    required HydrationNotifier hydrationNotifier,
    required HydrationState hydrationState,
    required AudioServiceNotifier audioNotifier,
    MedicationNotifier? medicationNotifier,
    List<MedicationItem>? medicationList,
    WeatherHydrationModel? weatherModel,
  }) async {
    final text = input.trim();
    final lower = text.toLowerCase();

    // Trigger subtle haptic feedback for command recognition
    HapticFeedback.mediumImpact();

    // 1. Medication Command (Senior Priority)
    if (_isMedicationCommand(lower)) {
      if (medicationList != null && medicationList.isNotEmpty && medicationNotifier != null) {
        final pending = medicationList.firstWhere(
          (m) => !m.isTakenToday,
          orElse: () => medicationList.first,
        );
        await medicationNotifier.takeMedication(pending.id, hydrationNotifier);
        return VoiceCommandResult(
          success: true,
          actionType: VoiceActionType.medication,
          recognizedText: text,
          feedbackMessageEn: '💊 Logged "${pending.nameEn}" taken + 250ml water logged!',
          feedbackMessageSi: '💊 "${pending.nameSi}" බී වතුර 250ml සටහන් කළා!',
        );
      } else {
        await hydrationNotifier.logWater(250);
        return VoiceCommandResult(
          success: true,
          actionType: VoiceActionType.medication,
          recognizedText: text,
          feedbackMessageEn: '💊 Medication confirmed and 250ml water intake logged!',
          feedbackMessageSi: '💊 බෙහෙත් පෙත්ත තහවුරු කර වතුර 250ml එකතු කළා!',
        );
      }
    }

    // 2. Gentle Wake-Up Alarm Command
    if (_isAlarmCommand(lower)) {
      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.gentleAlarm,
        recognizedText: text,
        feedbackMessageEn: '🌅 Opening Gentle Nature Wake-Up Alarm settings.',
        feedbackMessageSi: '🌅 මෘදු ස්වභාවික නාද ඇලාම් සැකසුම් විවෘත වේ.',
      );
    }

    // 3. Weather Hydration Status
    if (_isWeatherCommand(lower)) {
      final temp = weatherModel?.temperatureCelsius.toStringAsFixed(1) ?? '32.5';
      final bonus = weatherModel?.calculatedBonusMl ?? 500;
      final target = hydrationState.goal.dailyTargetMl;

      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.weatherHydration,
        recognizedText: text,
        feedbackMessageEn: '🌡️ Temperature is $temp°C. Target is ${target}ml (+$bonus ml heat bonus).',
        feedbackMessageSi: '🌡️ උෂ්ණත්වය $temp°C. අද ඉලක්කය ${target}ml (රස්නය නිසා +$bonus ml).',
      );
    }

    // 4. Water Intake Logging
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

    // 5. Pause / Stop Audio
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

    // 6. Resume / Unpause Audio
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

    // 7. Bedtime / Deep Sleep Mode
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

    // 8. Guided Breathing Exercise
    if (_isBreathingCommand(lower)) {
      return VoiceCommandResult(
        success: true,
        actionType: VoiceActionType.breathingExercise,
        recognizedText: text,
        feedbackMessageEn: '🌬️ Opening Guided Breathing Exercise. Take a deep breath.',
        feedbackMessageSi: '🌬️ සන්සුන් හුස්ම ගැනීමේ අභ්‍යාසය ආරම්භ වේ. සන්සුන් වන්න.',
      );
    }

    // 9. Play Specific Sound Tracks
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

    // 10. Check Hydration Status
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
      feedbackMessageEn: 'I didn\'t quite catch that. Try saying "Pill taken" or "Log 250ml water".',
      feedbackMessageSi: 'කරුණාකර නැවත උත්සාහ කරන්න: "බෙහෙත් බිව්වා" හෝ "වතුර 250ml" පවසා බලන්න.',
    );
  }

  static bool _isMedicationCommand(String text) {
    final medKeywords = [
      'pill', 'medicine', 'medication', 'tablet', 'took pill', 'took medicine',
      'beheth', 'pethi', 'beheth biwwa', 'pethi biwwa',
      'බෙහෙත්', 'පෙති', 'බෙහෙත් බිව්වා', 'පෙති බිව්වා'
    ];
    return medKeywords.any((k) => text.contains(k));
  }

  static bool _isAlarmCommand(String text) {
    final alarmKeywords = [
      'alarm', 'wake up', 'wake', 'gentle wake',
      'alarm eka', 'elam', 'aharanna',
      'ඇලාම්', 'ඇහැරෙන්න', 'නැගිටින්න', 'නින්දෙන්'
    ];
    return alarmKeywords.any((k) => text.contains(k));
  }

  static bool _isWeatherCommand(String text) {
    final weatherKeywords = [
      'weather', 'temperature', 'heat', 'climate', 'hot',
      'kalagune', 'rasne', 'ushnathwaya',
      'කාලගුණය', 'උෂ්ණත්වය', 'රස්නය', 'තාපය'
    ];
    return weatherKeywords.any((k) => text.contains(k));
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
    final match = RegExp(r'\b(\d{2,4})\b').firstMatch(text);
    if (match != null) {
      final parsed = int.tryParse(match.group(1)!);
      if (parsed != null && parsed >= 50 && parsed <= 3000) {
        return parsed;
      }
    }

    if (text.contains('bottle') || text.contains('bothal') || text.contains('බෝතල')) {
      return 500;
    }
    if (text.contains('big') || text.contains('loku') || text.contains('ලොකු')) {
      return 500;
    }

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
      'bedtime', 'sleep', 'sleepy', 'good night', 'goodnight',
      'ninda', 'nidaganna', 'nida ganna', 'නිදාගන්න', 'නින්ද', 'සුභ රාත්‍රියක්'
    ];
    return bedtimeKeywords.any((k) => text.contains(k));
  }

  static bool _isBreathingCommand(String text) {
    final breathingKeywords = [
      'breath', 'breathe', 'breathing', 'deep breath', 'in out',
      'husma', 'husma ganna', 'husma ganeema',
      'හුස්ම', 'හුස්ම ගන්න', 'අභ්‍යාසය'
    ];
    return breathingKeywords.any((k) => text.contains(k));
  }

  static bool _isStatusCommand(String text) {
    final statusKeywords = [
      'status', 'how much', 'progress', 'goal', 'summary',
      'keeyada', 'wathura keeyada', 'ප්‍රගතිය', 'කොච්චර'
    ];
    return statusKeywords.any((k) => text.contains(k));
  }

  static SoundTrack? _findMatchingTrack(String text) {
    if (text.contains('rain') || text.contains('rainfall') || text.contains('wassa') || text.contains('wahi') || text.contains('වැස්ස') || text.contains('වැසි')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'rainfall', orElse: () => SoundTrack.defaultTracks[2]);
    }
    if (text.contains('ocean') || text.contains('sea') || text.contains('wave') || text.contains('muhuda') || text.contains('rala') || text.contains('මුහුද') || text.contains('රළ')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'ocean', orElse: () => SoundTrack.defaultTracks[1]);
    }
    if (text.contains('waterfall') || text.contains('falls') || text.contains('stream') || text.contains('diya alla') || text.contains('දිය ඇල්ල')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'waterfall', orElse: () => SoundTrack.defaultTracks[0]);
    }
    if (text.contains('pink') || text.contains('pink noise')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'pink_noise', orElse: () => SoundTrack.defaultTracks[3]);
    }
    if (text.contains('brown') || text.contains('brown noise') || text.contains('deep noise')) {
      return SoundTrack.defaultTracks.firstWhere((t) => t.id == 'brown_noise', orElse: () => SoundTrack.defaultTracks[4]);
    }
    if (text.contains('play') || text.contains('sound') || text.contains('music') || text.contains('සද්දෙ') || text.contains('වාදනය')) {
      return SoundTrack.defaultTracks[2];
    }
    return null;
  }
}
