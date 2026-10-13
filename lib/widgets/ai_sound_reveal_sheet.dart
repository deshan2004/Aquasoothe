import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

/// Shows an ultra-modern frosted glass modal revealing the user's newly generated AI sound.
void showAISoundRevealModal(
  BuildContext context, {
  required SoundTrack soundTrack,
  required double matchPercentage,
  required String reasoning,
  required VoidCallback onContinue,
}) {
  HapticFeedback.heavyImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (_) => AISoundRevealSheet(
      soundTrack: soundTrack,
      matchPercentage: matchPercentage,
      reasoning: reasoning,
      onContinue: onContinue,
    ),
  );
}

class AISoundRevealSheet extends ConsumerStatefulWidget {
  final SoundTrack soundTrack;
  final double matchPercentage;
  final String reasoning;
  final VoidCallback onContinue;

  const AISoundRevealSheet({
    super.key,
    required this.soundTrack,
    required this.matchPercentage,
    required this.reasoning,
    required this.onContinue,
  });

  @override
  ConsumerState<AISoundRevealSheet> createState() => _AISoundRevealSheetState();
}

class _AISoundRevealSheetState extends ConsumerState<AISoundRevealSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _togglePreview() async {
    final audioNotifier = ref.read(audioServiceProvider);
    HapticFeedback.mediumImpact();

    if (_isPlaying) {
      await audioNotifier.pause();
      setState(() => _isPlaying = false);
    } else {
      await audioNotifier.selectTrack(widget.soundTrack);
      await audioNotifier.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSi = ref.watch(settingsProvider).isSinhala;

    final primaryTeal = const Color(0xFF0C4648);
    final accentTeal = isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B);
    final titleColor = isDark ? const Color(0xFFE3F5F3) : primaryTeal;
    final bodyColor = isDark ? const Color(0xFF9DC2C0) : const Color(0xFF5B787A);

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.5 : 0.2),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF132B30).withValues(alpha: 0.88),
                        const Color(0xFF0A181C).withValues(alpha: 0.94),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.88),
                        const Color(0xFFEFF8F6).withValues(alpha: 0.82),
                      ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.5,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag pill
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sparkle AI Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentTeal.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentTeal.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 16, color: accentTeal),
                        const SizedBox(width: 6),
                        Text(
                          isSi ? 'ඔබටම වෙන්වූ AI ශබ්දය සූදානම්' : 'AI Bespoke Sound Generated',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: accentTeal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Main Heading
                  Text(
                    widget.soundTrack.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Match percentage pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.matchPercentage.toStringAsFixed(1)}% ${isSi ? 'පුද්ගලීකෘත ගැළපීම' : 'Personal Acoustic Match'}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: accentTeal,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Interactive Frosted Audio Visualizer Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF183B42).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.85),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.25 : 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Sound Icon & Animated Equalizer Waves
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentTeal.withValues(alpha: 0.15),
                                border: Border.all(color: accentTeal.withValues(alpha: 0.3)),
                              ),
                              child: Icon(widget.soundTrack.icon, size: 36, color: accentTeal),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Animated Wave Bars
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, _) {
                            final heights = [16.0, 28.0, 42.0, 32.0, 48.0, 24.0, 36.0, 20.0];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(heights.length, (i) {
                                final animVal = _isPlaying
                                    ? ((heights[i] * (0.4 + (_waveController.value * 0.6)))).clamp(8.0, 50.0)
                                    : (heights[i] * 0.35).clamp(6.0, 20.0);
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 6,
                                  height: animVal,
                                  decoration: BoxDecoration(
                                    color: _isPlaying
                                        ? accentTeal
                                        : (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Preview Audio Button
                        ScaleButton(
                          onTap: _togglePreview,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            decoration: BoxDecoration(
                              color: _isPlaying
                                  ? accentTeal
                                  : (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isPlaying
                                    ? accentTeal
                                    : (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: _isPlaying ? Colors.white : titleColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isPlaying
                                      ? (isSi ? 'නවතන්න' : 'Pause Preview')
                                      : (isSi ? 'ශබ්දය අසන්න (Preview)' : 'Listen to Preview'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _isPlaying ? Colors.white : titleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // AI Reasoning Note Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 20, color: accentTeal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.reasoning,
                            style: TextStyle(
                              fontSize: 13,
                              color: bodyColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Primary Button to Enter the App
                  ScaleButton(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      widget.onContinue();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0C4648), Color(0xFF1B706E), Color(0xFF00897B)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C4648).withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSi ? 'AquaSoothe වෙත පිවිසෙන්න' : 'Continue to AquaSoothe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
