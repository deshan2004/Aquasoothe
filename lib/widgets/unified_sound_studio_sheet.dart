import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../screens/ai_sound_generator_screen.dart';
import 'ai_sound_matcher_dialog.dart';
import 'soundscape_mixer_dialog.dart';
import 'scale_button.dart';
import 'glass_card.dart';

/// Unified All-in-One Sound Studio Hub for Seniors & All Users
class UnifiedSoundStudioSheet extends ConsumerWidget {
  const UnifiedSoundStudioSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF13272C).withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.7),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title and senior-friendly description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C4648),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sound Studio Hub',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'All sound creation & mixing tools in one place',
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tool 1: AI Sound Creator
              _buildStudioOptionCard(
                context: context,
                isDark: isDark,
                textColor: textColor,
                subtitleColor: subtitleColor,
                icon: Icons.auto_fix_high_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
                title: 'Create Sound with AI',
                description: 'Describe any sound (e.g. rain on a roof) and AI synthesizes it',
                badgeText: 'Generative AI',
                badgeColor: const Color(0xFF0284C7),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AISoundGeneratorScreen()),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Tool 2: Dual Layer Sound Mixer
              _buildStudioOptionCard(
                context: context,
                isDark: isDark,
                textColor: textColor,
                subtitleColor: subtitleColor,
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF0C4648),
                iconBg: const Color(0xFFE1F2F0),
                title: 'Mix Two Sounds Together',
                description: 'Blend rain with ocean waves or crickets with independent volume',
                badgeText: audioNotifier.isMixerEnabled ? 'Active Mix' : null,
                badgeColor: const Color(0xFF16A34A),
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    builder: (_) => const SoundscapeMixerDialog(),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Tool 3: Smart Mood Matcher
              _buildStudioOptionCard(
                context: context,
                isDark: isDark,
                textColor: textColor,
                subtitleColor: subtitleColor,
                icon: Icons.psychology_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Find Sound for My Mood',
                description: 'Quick recommendations for deep sleep, stress relief, or focus',
                badgeText: 'Smart Match',
                badgeColor: const Color(0xFFD97706),
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    builder: (_) => const AISoundMatcherDialog(),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudioOptionCard({
    required BuildContext context,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ScaleButton(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 20,
        blur: 14,
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.65),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.18) : iconBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: iconColor.withValues(alpha: isDark ? 0.35 : 0.25),
                ),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? const Color(0xFF0C4648)).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (badgeColor ?? const Color(0xFF0C4648)).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeColor ?? textColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 24),
          ],
        ),
      ),
    );
  }
}
