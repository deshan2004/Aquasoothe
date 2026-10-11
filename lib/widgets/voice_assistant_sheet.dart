import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../services/voice_command_service.dart';
import 'glass_card.dart';
import 'scale_button.dart';

/// Shows the interactive Voice Assistant Sheet from anywhere in the app.
void showVoiceAssistantModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _textController = TextEditingController();

  bool _isListening = true;
  bool _isProcessing = false;
  VoiceCommandResult? _lastResult;

  List<Map<String, String>> _getQuickCommands(bool isSi) {
    if (isSi) {
      return const [
        {
          'title': '💧 වතුර 250ml එකතු කරන්න',
          'sub': 'වීදුරුවක්',
          'cmd': 'Log 250ml water',
        },
        {
          'title': '💧 වතුර 500ml එකතු කරන්න',
          'sub': 'බෝතලයක්',
          'cmd': 'Log 500ml bottle of water',
        },
        {
          'title': '🌧️ වැසි නාදය වාදනය කරන්න',
          'sub': 'සන්සුන් වැස්ස',
          'cmd': 'Play soothing rainfall sound',
        },
        {
          'title': '🌊 මුහුදු රළ වාදනය කරන්න',
          'sub': 'මෘදු රළ නාදය',
          'cmd': 'Play gentle ocean waves',
        },
        {
          'title': '⏸️ ශබ්දය නවත්වන්න',
          'sub': 'නිහඬ කරන්න',
          'cmd': 'Stop audio playback',
        },
        {
          'title': '🌙 නිදන මාදිලිය',
          'sub': 'විනාඩි 30 ටයිමරය',
          'cmd': 'Start bedtime sleep mode',
        },
        {
          'title': '📊 අද ජල ප්‍රමාණය බලන්න',
          'sub': 'දෛනික ඉලක්කය',
          'cmd': 'Check today water status',
        },
      ];
    } else {
      return const [
        {
          'title': '💧 Log 250ml Water',
          'sub': 'One glass',
          'cmd': 'Log 250ml water',
        },
        {
          'title': '💧 Log 500ml Bottle',
          'sub': 'One bottle',
          'cmd': 'Log 500ml bottle of water',
        },
        {
          'title': '🌧️ Play Rain Sounds',
          'sub': 'Soothing rainfall',
          'cmd': 'Play soothing rainfall sound',
        },
        {
          'title': '🌊 Play Ocean Waves',
          'sub': 'Gentle waves',
          'cmd': 'Play gentle ocean waves',
        },
        {
          'title': '⏸️ Pause Audio',
          'sub': 'Silence playback',
          'cmd': 'Stop audio playback',
        },
        {
          'title': '🌙 Bedtime Mode',
          'sub': '30-minute timer',
          'cmd': 'Start bedtime sleep mode',
        },
        {
          'title': '📊 Check Water Goal',
          'sub': 'Daily progress',
          'cmd': 'Check today water status',
        },
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _lastResult = null;
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
      }
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _handleCommand(String rawText) async {
    if (rawText.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isListening = false;
    });

    final hydrationNotifier = ref.read(hydrationProvider.notifier);
    final hydrationState = ref.read(hydrationProvider);
    final audioNotifier = ref.read(audioServiceProvider);

    // Short delay for realistic speech interpretation
    await Future.delayed(const Duration(milliseconds: 350));

    final result = await VoiceCommandService.processCommand(
      input: rawText,
      hydrationNotifier: hydrationNotifier,
      hydrationState: hydrationState,
      audioNotifier: audioNotifier,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastResult = result;
        _textController.text = rawText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTeal = const Color(0xFF0C4648);
    final coral = const Color(0xFFF8AB80);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final quickCommands = _getQuickCommands(isSi);

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13272C).withValues(alpha: 0.94) : Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 36,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
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
                const SizedBox(height: 16),

                // Header Title with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryTeal.withValues(alpha: 0.12),
                          ),
                          child: Icon(Icons.mic_rounded, size: 22, color: isDark ? Colors.white : primaryTeal),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSi ? 'හඬ සහායක' : 'Voice Assistant',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : primaryTeal,
                              ),
                            ),
                            Text(
                              isSi ? 'ඔබට අවශ්‍ය දේ කතා කර කියන්න' : 'Speak to log water or play sounds',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Pulsing Interactive Microphone Bubble
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final scale = _isListening ? 1.0 + (_animController.value * 0.12) : 1.0;
                      final pulseOpacity = _isListening ? (0.28 - (_animController.value * 0.18)).clamp(0.05, 0.3) : 0.0;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ripple ring
                          if (_isListening)
                            Container(
                              width: 110 * scale,
                              height: 110 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: coral.withValues(alpha: pulseOpacity),
                              ),
                            ),
                          // Middle ripple ring
                          if (_isListening)
                            Container(
                              width: 95 * scale,
                              height: 95 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryTeal.withValues(alpha: pulseOpacity + 0.1),
                              ),
                            ),
                          // Center Microphone Button
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? [const Color(0xFF1E676B), const Color(0xFF0C4648)]
                                    : [const Color(0xFF7A8E91), const Color(0xFF4A5C5E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? const Color(0xFF0C4648) : Colors.black26).withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Status Text
                Text(
                  _isProcessing
                      ? (isSi ? 'විධානය සකසමින් පවතී...' : 'Processing command...')
                      : _isListening
                          ? (isSi ? 'අසමින් පවතී... දැන් කතා කරන්න' : 'Listening... Speak now')
                          : (isSi ? 'මයික්‍රෆෝනය ඔබා කතා කරන්න' : 'Tap microphone to speak'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primaryTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isListening
                      ? (isSi ? '"වතුර 250ml බිව්වා" හෝ "වැසි නාදය" කියන්න' : 'Say e.g. "Log 250ml water" or "Play rain"')
                      : (isSi ? 'හෝ පහතින් ඉක්මන් විධානයක් තෝරන්න' : 'Or choose a quick prompt below'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                  ),
                ),

                const SizedBox(height: 18),

                // Command Result Feedback Card (Single Language Only!)
                if (_lastResult != null) ...[
                  GlassCard(
                    borderRadius: 18,
                    blur: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    margin: const EdgeInsets.only(bottom: 18),
                    gradient: LinearGradient(
                      colors: _lastResult!.success
                          ? [
                              const Color(0xFF0C4648).withValues(alpha: 0.9),
                              const Color(0xFF1A585B).withValues(alpha: 0.9),
                            ]
                          : [
                              const Color(0xFF8A3428).withValues(alpha: 0.9),
                              const Color(0xFF6B2217).withValues(alpha: 0.9),
                            ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _lastResult!.success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          size: 26,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isSi ? _lastResult!.feedbackMessageSi : _lastResult!.feedbackMessageEn,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Quick Tap Commands for Seniors
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isSi ? 'ඉක්මන් හඬ විධාන' : 'QUICK VOICE PROMPTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white60 : const Color(0xFF5A7275),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickCommands.map((cmd) {
                    return ScaleButton(
                      onTap: () => _handleCommand(cmd['cmd']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.16),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cmd['title']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : primaryTeal,
                              ),
                            ),
                            Text(
                              cmd['sub']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : const Color(0xFF5A7275),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // Manual Input / Custom Voice Prompt Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: isSi ? 'විධානයක් ටයිප් කරන්න හෝ කතා කරන්න...' : 'Type or speak a custom command...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          onSubmitted: (val) => _handleCommand(val),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send_rounded, color: primaryTeal, size: 20),
                        onPressed: () => _handleCommand(_textController.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
