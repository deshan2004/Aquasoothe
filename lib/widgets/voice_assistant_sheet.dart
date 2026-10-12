import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/audio_provider.dart';
import '../providers/hydration_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/weather_hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../services/voice_command_service.dart';
import 'glass_card.dart';
import 'breathing_exercise_sheet.dart';
import 'gentle_alarm_sheet.dart';
import 'medication_schedule_sheet.dart';
import 'weather_hydration_sheet.dart';

/// Shows the interactive Voice Assistant Sheet with full Glassmorphic design.
void showVoiceAssistantModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
    ),
    builder: (_) => const VoiceAssistantSheet(),
  );
}

class VoiceAssistantSheet extends ConsumerStatefulWidget {
  const VoiceAssistantSheet({super.key});

  @override
  ConsumerState<VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends ConsumerState<VoiceAssistantSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  final TextEditingController _textController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentWords = '';
  VoiceCommandResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (val) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
          });
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'listening') {
            setState(() => _isListening = true);
          } else if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
            if (_currentWords.trim().isNotEmpty && !_isProcessing) {
              _handleCommand(_currentWords);
            }
          }
        },
      );

      if (mounted) {
        setState(() {
          _speechEnabled = available;
        });
        if (available) {
          _startListening();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _speechEnabled = false;
        });
      }
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(settingsProvider).isSinhala
                    ? 'මයික්‍රෆෝනය සක්‍රිය කර ගැනීමට කරුණාකර App එක Stop කර නැවත run කරන්න.'
                    : 'Please rebuild & run the app to activate the new microphone plugin.',
              ),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _currentWords = '';
      _lastResult = null;
    });

    HapticFeedback.mediumImpact();

    try {
      final isSi = ref.read(settingsProvider).isSinhala;
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _currentWords = result.recognizedWords;
            _textController.text = result.recognizedWords;
          });

          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _stopListening();
            _handleCommand(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true,
          localeId: isSi ? 'si_LK' : null,
        ),
      );
    } catch (e) {
      debugPrint('Speech error: $e');
    }
  }

  Future<void> _stopListening() async {
    if (_speechEnabled) {
      try {
        await _speech.stop();
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
      if (_currentWords.trim().isNotEmpty) {
        _handleCommand(_currentWords);
      }
    } else {
      _startListening();
    }
    HapticFeedback.selectionClick();
  }

  Future<void> _handleCommand(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isListening = false;
      _currentWords = text;
    });

    final hydrationNotifier = ref.read(hydrationProvider.notifier);
    final hydrationState = ref.read(hydrationProvider);
    final audioNotifier = ref.read(audioServiceProvider);
    final medicationNotifier = ref.read(medicationProvider.notifier);
    final medicationList = ref.read(medicationProvider);
    final weatherModel = ref.read(weatherHydrationProvider);

    await Future.delayed(const Duration(milliseconds: 320));

    final result = await VoiceCommandService.processCommand(
      input: text,
      hydrationNotifier: hydrationNotifier,
      hydrationState: hydrationState,
      audioNotifier: audioNotifier,
      medicationNotifier: medicationNotifier,
      medicationList: medicationList,
      weatherModel: weatherModel,
    );

    if (result.actionType == VoiceActionType.breathingExercise) {
      if (mounted) {
        Navigator.of(context).pop();
        showBreathingExerciseModal(context);
      }
      return;
    }

    if (result.actionType == VoiceActionType.gentleAlarm) {
      if (mounted) {
        Navigator.of(context).pop();
        showGentleAlarmModal(context);
      }
      return;
    }

    if (result.actionType == VoiceActionType.medication &&
        (text.toLowerCase().contains('schedule') ||
            text.toLowerCase().contains('බලන්න') ||
            text.toLowerCase().contains('කාලසටහන'))) {
      if (mounted) {
        Navigator.of(context).pop();
        showMedicationScheduleModal(context);
      }
      return;
    }

    if (result.actionType == VoiceActionType.weatherHydration &&
        text.toLowerCase().contains('open')) {
      if (mounted) {
        Navigator.of(context).pop();
        showWeatherHydrationModal(context);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastResult = result;
        _textController.text = text;
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    _waveController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glowTeal = isDark ? const Color(0xFF5ED1C7) : const Color(0xFF1E676B);
    const coral = Color(0xFFF8AB80);
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F2024).withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.86),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4648).withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Stack(
            children: [
              // Subtle Atmospheric Glass Orbs
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowTeal.withValues(alpha: isDark ? 0.18 : 0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: coral.withValues(alpha: isDark ? 0.12 : 0.16),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top drag handle
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header Title with Close Button (Fixed: No right overflow!)
                    Row(
                      children: [
                        // Left Icon & Title (Expanded to avoid any overflow)
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: glowTeal.withValues(alpha: 0.14),
                                  border: Border.all(
                                    color: glowTeal.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(Icons.mic_rounded, size: 22, color: glowTeal),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSi ? 'හඬ සහායක' : 'Voice Assistant',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      isSi ? 'කතා කර විධාන ලබා දෙන්න' : 'Speak or tap to control AquaSoothe',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: subtitleColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close button
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Ultra-Modern Frosted Glass Glowing Microphone
                    GestureDetector(
                      onTap: _toggleListening,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = _isListening
                              ? 1.0 + (_pulseController.value * 0.12)
                              : 1.0;
                          final ringOpacity = _isListening
                              ? (0.35 - (_pulseController.value * 0.22)).clamp(0.08, 0.4)
                              : 0.0;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Glass Aura Ring
                              if (_isListening)
                                Container(
                                  width: 136 * scale,
                                  height: 136 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: coral.withValues(alpha: ringOpacity),
                                  ),
                                ),
                              // Middle Glass Aura Ring
                              if (_isListening)
                                Container(
                                  width: 112 * scale,
                                  height: 112 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: glowTeal.withValues(alpha: ringOpacity + 0.1),
                                  ),
                                ),

                              // Center Glass Orb
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: _isListening
                                        ? [
                                            const Color(0xFF1E676B),
                                            const Color(0xFF0C4648),
                                          ]
                                        : [
                                            glowTeal.withValues(alpha: 0.85),
                                            const Color(0xFF0C4648),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: glowTeal.withValues(alpha: _isListening ? 0.5 : 0.28),
                                      blurRadius: 26,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Animated Soundwave Indicator when listening
                    if (_isListening) ...[
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final wavePhase = (_waveController.value + (index * 0.2)) % 1.0;
                              final height = 8.0 + (wavePhase * 16.0);
                              return Container(
                                width: 3.5,
                                height: height,
                                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                decoration: BoxDecoration(
                                  color: glowTeal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Live Status Text
                    Text(
                      _isProcessing
                          ? (isSi ? 'විධානය සකසමින් පවතී...' : 'Processing command...')
                          : _isListening
                              ? (isSi ? 'අසමින් පවතී... දැන් කතා කරන්න' : 'Listening... Speak now')
                              : (isSi ? 'මයික්‍රෆෝනය ඔබා කතා කරන්න' : 'Tap microphone to speak'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _isListening
                          ? (isSi ? 'පැහැදිලිව කතා කරන්න' : 'Speak clearly or tap a prompt below')
                          : (isSi ? 'හෝ පහතින් කැමති විධානයක් තෝරන්න' : 'Or tap a quick command below'),
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Live Spoken Words Frosted Glass Card
                    GlassCard(
                      borderRadius: 20,
                      blur: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      margin: EdgeInsets.zero,
                      borderColor: _isListening
                          ? glowTeal.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: isDark ? 0.12 : 0.6),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isListening ? Colors.redAccent : glowTeal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isListening
                                    ? (isSi ? 'හඬ හඳුනාගැනීම:' : 'Listening:')
                                    : (isSi ? 'හඬ විධානය:' : 'Voice Query:'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentWords.isNotEmpty
                                ? '"$_currentWords"'
                                : (_isListening
                                    ? (isSi ? 'කතා කරන විට මෙහි දිස්වේ...' : 'Your speech appears here...')
                                    : (isSi ? '"වතුර 250ml බිව්වා" හෝ "වැසි නාදය"' : '"Log 250ml water" or "Play rain"')),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _currentWords.isNotEmpty ? 16 : 13,
                              fontStyle: _currentWords.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                              fontWeight: _currentWords.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                              color: _currentWords.isNotEmpty
                                  ? textColor
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Elegant Frosted Glass Voice Chips (Fast, clean 1-touch execution)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildGlassChip(
                            icon: '💧',
                            label: isSi ? 'වතුර 250ml' : 'Log 250ml',
                            command: 'Log 250ml water',
                            glowTeal: glowTeal,
                            isDark: isDark,
                          ),
                          _buildGlassChip(
                            icon: '🌧️',
                            label: isSi ? 'වැසි නාදය' : 'Play Rain',
                            command: 'Play soothing rainfall sound',
                            glowTeal: glowTeal,
                            isDark: isDark,
                          ),
                          _buildGlassChip(
                            icon: '🌊',
                            label: isSi ? 'මුහුදු රළ' : 'Ocean Waves',
                            command: 'Play gentle ocean waves',
                            glowTeal: glowTeal,
                            isDark: isDark,
                          ),
                          _buildGlassChip(
                            icon: '🌙',
                            label: isSi ? 'නිදන මාදිලිය' : 'Bedtime Mode',
                            command: 'Start bedtime sleep mode',
                            glowTeal: glowTeal,
                            isDark: isDark,
                          ),
                          _buildGlassChip(
                            icon: '💊',
                            label: isSi ? 'බෙහෙත් බිව්වා' : 'Took Pill',
                            command: 'Took my medication pill',
                            glowTeal: glowTeal,
                            isDark: isDark,
                          ),
                          _buildGlassChip(
                            icon: '⏸️',
                            label: isSi ? 'නවත්වන්න' : 'Stop Audio',
                            command: 'Stop audio playback',
                            glowTeal: glowTeal,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Command Result Feedback Card
                    if (_lastResult != null) ...[
                      GlassCard(
                        borderRadius: 18,
                        blur: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 14),
                        gradient: LinearGradient(
                          colors: _lastResult!.success
                              ? [
                                  const Color(0xFF0C4648).withValues(alpha: 0.92),
                                  const Color(0xFF1A585B).withValues(alpha: 0.92),
                                ]
                              : [
                                  const Color(0xFF8A3428).withValues(alpha: 0.92),
                                  const Color(0xFF6B2217).withValues(alpha: 0.92),
                                ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _lastResult!.success
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isSi
                                    ? _lastResult!.feedbackMessageSi
                                    : _lastResult!.feedbackMessageEn,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Manual Text Field with Glass Styling
                    GlassCard(
                      borderRadius: 18,
                      blur: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      margin: EdgeInsets.zero,
                      borderColor: Colors.white.withValues(alpha: isDark ? 0.15 : 0.65),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: isSi
                                    ? 'විධානයක් මෙහි ලියන්න...'
                                    : 'Or type a command here...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: subtitleColor.withValues(alpha: 0.6),
                                ),
                              ),
                              onSubmitted: (val) => _handleCommand(val),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send_rounded, color: glowTeal, size: 20),
                            onPressed: () => _handleCommand(_textController.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassChip({
    required String icon,
    required String label,
    required String command,
    required Color glowTeal,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GlassCard(
        borderRadius: 14,
        blur: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.zero,
        borderColor: glowTeal.withValues(alpha: 0.22),
        onTap: () => _handleCommand(command),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
